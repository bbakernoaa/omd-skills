#!/usr/bin/env bash
#
# install.sh — install the genesis-skills catalog into a local project for AI agents.
#
# Installs catalog skills into each selected agent's project skills location and
# catalog code-review instructions in the form each agent consumes them: verbatim
# Copilot instruction files, translated Cursor .mdc rules, or a managed block in
# CLAUDE.md / AGENTS.md / GEMINI.md. Re-running refreshes and prunes stale
# entries; uninstall removes exactly what was installed. Installer state lives
# in <project>/.ompd/ (nothing else outside the managed paths is touched).
#
# Usage:
#   ./install.sh [install] [options] [DOMAIN|SKILL ...]
#   ./install.sh uninstall [options]
#   ./install.sh list
#
# Options:
#   --agents LIST        comma list of {claude,codex,opencode,gemini,cursor,
#                        copilot} or "all". Required with --no-interactive.
#   --mode {symlink|copy}  symlink (default; stays in sync with this clone)
#                        or copy (self-contained snapshot).
#   --project PATH       target project directory (default: current dir).
#   --domains LIST       comma list of domain dirs to limit skills (same
#                        vocabulary as unpack.sh); default: everything.
#   --skills LIST        comma list of individual skill names.
#   --no-interactive     never prompt; --agents is then mandatory.
#   --uninstall          synonym for the uninstall command.
#   --list               synonym for the list command.
#   -h, --help           show this help.
#
set -euo pipefail
unset CDPATH

TAB="$(printf '\t')"
NL="
"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
CATALOG_ROOT="$SCRIPT_DIR"
TOOLS_DIR="$CATALOG_ROOT/tools/installer"
SKILLS_SRC="$CATALOG_ROOT/skills"
INSTR_SRC="$CATALOG_ROOT/.github/instructions"

# shellcheck source=tools/installer/lib.sh
. "$TOOLS_DIR/lib.sh"
# shellcheck source=tools/installer/adapters.sh
. "$TOOLS_DIR/adapters.sh"
# shellcheck source=tools/installer/catalog.sh
. "$TOOLS_DIR/catalog.sh"
# shellcheck source=tools/installer/record.sh
. "$TOOLS_DIR/record.sh"
# shellcheck source=tools/installer/rules.sh
. "$TOOLS_DIR/rules.sh"
# shellcheck source=tools/installer/formats.sh
. "$TOOLS_DIR/formats.sh"

usage() { usage_from "${BASH_SOURCE[0]}"; }
SUPPORTED_MSG="(supported: claude, codex, opencode, gemini, cursor, copilot)"

# ---------------------------------------------------------------------------
# Arguments
# ---------------------------------------------------------------------------
OP="install"; MODE="symlink"; PROJECT="$PWD"
AGENTS_IN=""; DOMAINS_IN=""; SKILLS_IN=""; NO_INTERACTIVE=0
POSITIONS=""

while [ $# -gt 0 ]; do
  case "$1" in
    install)   OP="install"; shift ;;
    uninstall) OP="uninstall"; shift ;;
    list)      OP="list"; shift ;;
    --agents)    [ $# -ge 2 ] || die "--agents requires a value" 2; AGENTS_IN="$2"; shift 2 ;;
    --agents=*)  AGENTS_IN="${1#*=}"; shift ;;
    --mode)      [ $# -ge 2 ] || die "--mode requires a value" 2; MODE="$2"; shift 2 ;;
    --mode=*)    MODE="${1#*=}"; shift ;;
    --project)   [ $# -ge 2 ] || die "--project requires a value" 2; PROJECT="$2"; shift 2 ;;
    --project=*) PROJECT="${1#*=}"; shift ;;
    --domains)   [ $# -ge 2 ] || die "--domains requires a value" 2; DOMAINS_IN="$2"; shift 2 ;;
    --domains=*) DOMAINS_IN="${1#*=}"; shift ;;
    --skills)    [ $# -ge 2 ] || die "--skills requires a value" 2; SKILLS_IN="$2"; shift 2 ;;
    --skills=*)  SKILLS_IN="${1#*=}"; shift ;;
    --no-interactive) NO_INTERACTIVE=1; shift ;;
    --force-collisions) die "--force-collisions is reserved, not implemented; collisions always refuse" 2 ;;
    --uninstall) OP="uninstall"; shift ;;
    --list)      OP="list"; shift ;;
    -h|--help)   usage; exit 0 ;;
    -*)          die "unknown option: $1" 2 ;;
    *)           POSITIONS="${POSITIONS}${1}${NL}"; shift ;;
  esac
done

interactive() {
  [ "$NO_INTERACTIVE" -eq 0 ] && { [ -t 0 ] || [ -n "${GENESIS_FORCE_INTERACTIVE:-}" ]; }
}

hash_init
[ -d "$SKILLS_SRC" ] || die "skills/ not found next to install.sh ($SKILLS_SRC)" 5
INSTR_ALL="$(discover_instructions "$INSTR_SRC" | LC_ALL=C sort)"
[ -n "$INSTR_ALL" ] || die "no instruction files found in $INSTR_SRC" 5

# ---------------------------------------------------------------------------
# Skill rows + selection scope (FR-004; default = everything)
# ---------------------------------------------------------------------------
ROWS_ALL="$(discover_leaves "$SKILLS_SRC" '*')"
validate_unique_names "$ROWS_ALL"

SEL_TOKENS="$(printf '%s' "$POSITIONS" | LC_ALL=C awk 'NF')"
for csv in "$DOMAINS_IN" "$SKILLS_IN"; do
  [ -n "$csv" ] || continue
  SEL_TOKENS="${SEL_TOKENS}${NL}$(printf '%s' "$csv" | tr ',' '\n')"
done
SEL_TOKENS="$(printf '%s' "$SEL_TOKENS" | LC_ALL=C awk 'NF' | LC_ALL=C sort -u)"

UNFILTERED=1; ROWSEL=""
if [ -n "$SEL_TOKENS" ]; then
  UNFILTERED=0
  while IFS= read -r tk; do
    [ -n "$tk" ] || continue
    case "$tk" in
      .*|*/*) die "unknown domain or flat skill: $tk (check: install.sh list)" 2 ;;
    esac
    matchrows="$(printf '%s\n' "$ROWS_ALL" | awk -F'\t' -v t="$tk" '$1==t || $2==t')"
    [ -n "$matchrows" ] || die "unknown domain or flat skill: $tk (check: install.sh list)" 2
    ROWSEL="${ROWSEL}${matchrows}${NL}"
  done <<EOF
$SEL_TOKENS
EOF
  ROWSEL="$(printf '%s' "$ROWSEL" | LC_ALL=C awk 'NF' | LC_ALL=C sort -u)"
else
  ROWSEL="$(printf '%s\n' "$ROWS_ALL")"
fi

SCOPE_D="$(printf '%s\n' "$ROWSEL" | cut -f1 | LC_ALL=C sort -u)"
source_in_scope() { # lock entry source (skills/... form); instruction sources always in scope
  [ "$UNFILTERED" -eq 1 ] && return 0
  case "$1" in skills/*) : ;; *) return 0 ;; esac
  rel="${1#skills/}"
  printf '%s\n' "$SCOPE_D" | grep -qxF -- "${rel%%/*}" || \
    printf '%s\n' "$SCOPE_D" | grep -qxF -- "${rel##*/}"
}

# ---------------------------------------------------------------------------
# list command
# ---------------------------------------------------------------------------


if [ "$OP" = "list" ]; then
  printf 'skills (%d):\n' "$(printf '%s\n' "$ROWSEL" | grep -c .)"
  printf '%s\n' "$ROWSEL" | awk -F'\t' '{
      if ($1=="(flat)") printf "  %-34s (flat)\n", $2;
      else             printf "  %-34s [%s]\n", $2, $1 }' | LC_ALL=C sort
  printf '\ninstruction files (%d):\n' "$(printf '%s\n' "$INSTR_ALL" | grep -c .)"
  printf '%s\n' "$INSTR_ALL" | sed 's|.*/||; s/^/  /'
  exit 0
fi


# Agent selection (FR-002; interactive detection is confirmation-gated, R8)
# ---------------------------------------------------------------------------
# Contract: uninstall without --agents means every recorded agent.
if [ "$OP" = uninstall ] && [ -z "$AGENTS_IN" ] && ! interactive; then
  AGENTS_IN=all
fi
AGENT_IDS=""
if [ -n "$AGENTS_IN" ]; then
  if [ "$AGENTS_IN" = "all" ]; then
    # shellcheck disable=SC2086
    AGENT_IDS="$(printf '%s\n' $ADAPTER_IDS)"
  else
    AGENT_IDS="$(printf '%s' "$AGENTS_IN" | tr ',' '\n')"
  fi
  AGENT_IDS="$(printf '%s' "$AGENT_IDS" | LC_ALL=C awk 'NF' | LC_ALL=C sort -u)"
  # shellcheck disable=SC2086
  adapter_valid $AGENT_IDS || die "bad agent id in --agents $SUPPORTED_MSG" 2
elif interactive; then
  detected=""
  for id in $ADAPTER_IDS; do
    for fp in $(adapter_fingerprints "$id"); do
      # shellcheck disable=SC2086
      [ -e "$PROJECT/$fp" ] && { detected="$(csv_add "$detected" "$id")"; break; }
    done
  done
  while :; do
    if [ -n "$detected" ]; then
      printf 'Detected project markers -> suggested agents: %s\n' "$detected"
      printf 'Use suggested agents [Y], or ids (comma list / all), or n to quit: '
    else
      printf 'Enter agent ids (comma list or all): '
    fi
    IFS= read -r ans || die "stdin closed before a selection was made" 2
    case "$ans" in
      n|N) echo "Nothing selected; exiting." >&2; exit 2 ;;
      ""|y|Y|yes|YES) sel="$detected" ;;
      all|ALL) sel="$(printf '%s' "$ADAPTER_IDS" | tr ' ' ',')" ;;
      *) sel="$ans" ;;
    esac
    cand="$(printf '%s' "$sel" | tr -d ' \t' | tr ',' '\n' | LC_ALL=C awk 'NF')"
    # shellcheck disable=SC2086  # ids are validated tokens; splitting intended
    if [ -n "$cand" ] && adapter_valid $cand; then
      AGENT_IDS="$(printf '%s' "$cand" | LC_ALL=C sort -u)"; break
    fi
    echo "Unknown agent id; try again." >&2
    detected=""
  done
else
  die "--agents is required when not running interactively $SUPPORTED_MSG" 2
fi

[ "$MODE" = symlink ] || [ "$MODE" = copy ] || die "--mode must be symlink or copy" 2
[ -d "$PROJECT" ] || die "project directory not found: $PROJECT" 2
PROJECT_CANON="$(canonical_dir "$PROJECT")"

# FR-011 — refuse targets overlapping the catalog clone (either direction).
case "$CATALOG_ROOT/" in "$PROJECT_CANON"/*) die "refusing: target project contains the catalog clone" 3 ;; esac
case "$PROJECT_CANON/" in "$CATALOG_ROOT"/*) die "refusing: target project is the catalog clone or inside it" 3 ;; esac

OMPD_DIR="$PROJECT_CANON/.ompd"
LOCK_FILE="$OMPD_DIR/genesis.lock"
STAGE_DIR="$OMPD_DIR/genesis.lock.d"
export OMPD_DIR LOCK_FILE STAGE_DIR

# ---------------------------------------------------------------------------

# ---------------------------------------------------------------------------
# Shared row/record helpers
# ---------------------------------------------------------------------------
agents_csv_of() { # lock line -> sorted comma list of agent ids
  printf '%s' "$1" | sed -n 's/.*"agents":\[\([^]]*\)\].*/\1/p' | tr -d '"' | tr ',' '\n' | LC_ALL=C awk 'NF' | LC_ALL=C sort -u | paste -sd, -
}
reagents() { # $1 = lock line, $2 = new agents csv -> line with agents array replaced
  local repl
  repl="$(printf '%s' "$2" | sed -e 's/^/"/' -e 's/,/","/g' -e 's/$/"/')"
  printf '%s\n' "$1" | sed "s/\"agents\":\[[^]]*\]/\"agents\":[$repl]/"
}

# keep the caller's stdin available for prompts (loop heredocs consume stdin)
exec 3<&0

TMPB="$(mktemp -d "${TMPDIR:-/tmp}/genesis-install.XXXXXX")" || die "cannot create temp dir" 4
trap 'rm -rf -- "$TMPB"' EXIT
TRACK_OPS="$TMPB/ops"; : > "$TRACK_OPS"
STG="$TMPB/stage"; mkdir -p "$STG" || die "cannot create temp staging" 4
LOCK_NEW="$TMPB/lock.new"; : > "$LOCK_NEW"
SKIPPED_LOCAL=0

# ---------------------------------------------------------------------------
# Summary bookkeeping (FR-013)
# ---------------------------------------------------------------------------
SUMMARY=""
sum_note() { SUMMARY="${SUMMARY}${1}|${2}${NL}"; }
sum_emit() {
  [ -n "$SUMMARY" ] || return 0
  printf '%s\n' "$SUMMARY" | LC_ALL=C awk 'NF' | cut -d'|' -f1 | LC_ALL=C sort -u | while IFS= read -r dest; do
    line="  $dest"
    for st in created refreshed unchanged removed skipped-local-edit; do
      c=$(printf '%s\n' "$SUMMARY" | LC_ALL=C awk -F'|' -v d="$dest" -v s="$st" '$1==d && $2==s{print}' | LC_ALL=C awk 'END{print NR+0}')
      [ "$c" -gt 0 ] && line="$line $st=$c"
    done
    printf '%s\n' "$line"
  done
}

# ---------------------------------------------------------------------------
# Destination tables (shared paths deduped; research R3)
# ---------------------------------------------------------------------------
DEST_SKILLS=""; BLOCK_FILES=""; FILE_DIRS=""; FILE_DIR_FMT=""
while IFS= read -r a; do
  [ -n "$a" ] || continue
  sdir="$(adapter_skills_dir "$a")"; [ -n "$sdir" ] && DEST_SKILLS="${DEST_SKILLS}${sdir}${NL}"
  iv="$(adapter_instruction "$a")"
  case "$iv" in
    block\|*)  BLOCK_FILES="${BLOCK_FILES}${iv#block|}${NL}" ;;
    files\|*)  tgt="${iv#files|}"; dir="${tgt%%|*}"; fmtv="${tgt##*|}"
               FILE_DIRS="${FILE_DIRS}${dir}${NL}"
               case "$FILE_DIR_FMT" in "$dir"${TAB}*) ;; *) FILE_DIR_FMT="${FILE_DIR_FMT}${dir}${TAB}${fmtv}${NL}" ;; esac ;;
  esac
done <<AGT1
$AGENT_IDS
AGT1
DEST_SKILLS="$(printf '%s' "$DEST_SKILLS" | LC_ALL=C awk 'NF' | LC_ALL=C sort -u)"
BLOCK_FILES="$(printf '%s' "$BLOCK_FILES" | LC_ALL=C awk 'NF' | LC_ALL=C sort -u)"
FILE_DIRS="$(printf '%s' "$FILE_DIRS" | LC_ALL=C awk 'NF' | LC_ALL=C sort -u)"

agents_for() { # $1 kind (skillsdir|block|files) $2 value -> csv of selected agents owning it
  local out="" a iv
  while IFS= read -r a; do
    [ -n "$a" ] || continue
    case "$1" in
      skillsdir) [ "$(adapter_skills_dir "$a")" = "$2" ] && out="$(csv_add "$out" "$a")" ;;
      block) iv="$(adapter_instruction "$a")"
             [ "${iv%%|*}" = block ] && [ "${iv#block|}" = "$2" ] && out="$(csv_add "$out" "$a")" ;;
      files) iv="$(adapter_instruction "$a")"
             [ "${iv%%|*}" = files ] && [ "$(printf '%s' "${iv#files|}" | cut -d'|' -f1)" = "$2" ] && out="$(csv_add "$out" "$a")" ;;
    esac
  done <<AGT2
$AGENT_IDS
AGT2
  printf '%s' "$out"
}
fmt_for_dir() { printf '%s' "$FILE_DIR_FMT" | awk -F"\t" -v d="$1" '$1==d{print $2; exit}'; }

record_load

# ---------------------------------------------------------------------------
# ---------------------------------------------------------------------------
# Writability preflight for managed destinations (all refusals pre-write)
# ---------------------------------------------------------------------------
preflight_dirs() { # nearest existing ancestor of every managed dest must be writable
  local d p
  for d in $DEST_SKILLS $FILE_DIRS $BLOCK_FILES; do
    p="$PROJECT_CANON/$d"
    while [ ! -e "$p" ] && [ "$p" != "$PROJECT_CANON" ] && [ "$p" != "/" ]; do p="$(dirname "$p")"; done
    if [ -d "$p" ]; then
      [ -w "$p" ] || die "destination not writable: $d" 3
    else
      [ -e "$p" ] || die "destination not writable: $d" 3
    fi
  done
  return 0
}

# copy a staged temp file into the persistent stage tree (after successful write)
stage_promote() { # $1 = stage-relative path, $2 = source temp file
  mkdir -p "$STAGE_DIR/$(dirname "$1")" || return 1
  cp "$2" "$STAGE_DIR/$1"
}

# ---------------------------------------------------------------------------
# Local-edit prompt helper (FR-010). rc 0 => replace, rc 1 => skip.
# ---------------------------------------------------------------------------
prompt_replace() { # $1 = path
  if ! interactive; then
    warn "local edit at $1: skipped (non-interactive). Fix your copy or re-run interactively."
    return 1
  fi
  warn "local edit detected at $1 (your copy differs from the last installed catalog content)"
  printf 'replace %s with catalog version? [y/N] ' "$1"
  local ans
  IFS= read -r ans <&3 || ans=""
  case "$ans" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac
}

track_rm() { printf '%s\n' "$1" >> "$TRACK_OPS"; }   # created-by-us path: safe to delete on rollback
# shellcheck disable=SC2317,SC2329  # invoked by fail_apply
rollback() {
  [ -s "$TRACK_OPS" ] || return 0
  warn "apply failed; removing content created by this run before the error"
  while IFS= read -r p; do
    [ -n "$p" ] || continue
    rm -rf -- "${PROJECT_CANON:?}/$p" 2>/dev/null || true
  done < "$TRACK_OPS"
}

# ---------------------------------------------------------------------------
# Stale pruning (US3): entries recorded under in-scope sources but no longer
# desired. Out-of-scope entries (invariant 4) and other-selection entries are
# kept verbatim.
# ---------------------------------------------------------------------------
stale_skill() { # $1 = path, $2 = recorded agents csv, $3 = recorded mode, $4 = content_hash
  local abs="$PROJECT_CANON/$1" nm leaf
  nm="$(basename "$1")"
  if [ -L "$abs" ]; then
    rm -f -- "$abs" || return 1
  elif [ -d "$abs" ]; then
    leaf="$STAGE_DIR/skills/$nm"
    if [ -d "$leaf" ] && [ "$(tree_hash "$abs")" = "$(tree_hash "$leaf")" ]; then
      rm -Rf -- "$abs" || return 1
    else
      warn "$1 has files this installer did not create; leaving it in place, removed from the install record"
    fi
  fi
  rm -Rf -- "$leaf" 2>/dev/null || true
  return 0
}
stale_file() { # $1 = path, $2 = content_hash
  local abs="$PROJECT_CANON/$1" cur
  if [ ! -e "$abs" ]; then return 0; fi
  cur="$(file_hash "$abs")"
  if [ "$cur" = "$2" ]; then
    rm -f -- "$abs" || return 1
  else
    warn "$1 was edited locally after installation; leaving it in place, removed from the install record"
  fi
  return 0
}
stale_block() { # $1 = path, $2 = created(true|false)
  local abs="$PROJECT_CANON/$1"
  [ -f "$abs" ] || return 0
  block_remove "$abs"
  if [ "$2" = true ] && [ ! -s "$abs" ]; then
    rm -f -- "$abs"
  fi
  return 0
}

remove_entry() { # $1 = lock line
  local typ pth md hsh crt
  typ="$(lock_field_str "$1" type)"; pth="$(lock_field_str "$1" path)"
  md="$(lock_field_str "$1" mode)";  hsh="$(lock_field_str "$1" content_hash)"
  crt="$(lock_field_bool "$1" created)"
  case "$typ" in
    skill) stale_skill "$pth" "" "$md" "$hsh" ;;
    instruction-file) stale_file "$pth" "$hsh" ;;
    rules-block) stale_block "$pth" "$crt" ;;
    *) die "unknown entry type in install record: $typ" 4 ;;
  esac
}


# lock line rewriting when an entry is kept but agents shrank:

prune_empty_dirs() { # remove now-empty dirs among managed destinations (safe: -type d -empty only)
  local d
  for d in $DEST_SKILLS $FILE_DIRS; do
    d="$PROJECT_CANON/$d"
    [ -d "$d" ] || continue
    while [ -d "$d" ] && [ "$d" != "$PROJECT_CANON" ]; do
      rmdir "$d" 2>/dev/null || break
      d="$(dirname "$d")"
    done
  done
  return 0
}

# ---------------------------------------------------------------------------
# Uninstall (US3 / FR-012): delete recorded paths only; shared paths keep the
# tags (and content) of agents outside the selection; blocks are stripped and
# installer-created files removed only when the file is now empty.
# ---------------------------------------------------------------------------
do_uninstall() {
  if [ ! -f "$LOCK_FILE" ]; then
    printf 'Uninstall: no install record at %s; nothing to do.\n' "$LOCK_FILE"
    return 0
  fi
  record_load
  local AGENT_IDS_CSV line pth typ a left keepit
  local KEPT="$TMPB/lock.kept" p f nm leaf ours cur
  local nremoved=0 nuntagged=0
  AGENT_IDS_CSV=",$(printf '%s' "$AGENT_IDS" | paste -sd, -),"
  : > "$KEPT"
  local i
  for i in $(idx_range "${#LOCK_LINES[@]}"); do
    line="${LOCK_LINES[$i]}"
    [ -n "$line" ] || continue
    pth="$(lock_field_str "$line" path)"
    typ="$(lock_field_str "$line" type)"
    left=""; keepit=0
    for a in $(printf '%s' "$(agents_csv_of "$line")" | tr ',' ' '); do
      case "$AGENT_IDS_CSV" in
        *",$a,"*) : ;;                    # dropping this agent's ownership
        *) left="$(csv_add "$left" "$a")"; keepit=1 ;;
      esac
    done
    if [ "$keepit" = 1 ]; then
      reagents "$line" "$left" >> "$KEPT"
      nuntagged=$((nuntagged + 1))
      continue
    fi
    if [ "$typ" = skill ] && ! source_in_scope "$(lock_field_str "$line" source)"; then
      printf '%s
' "$line" >> "$KEPT"      # outside the --domains scope: untouched
      continue
    fi
    p="$PROJECT_CANON/$pth"
    case "$typ" in
      skill)
        nm="$(basename "$pth")"; leaf="$STAGE_DIR/skills/$nm"
        if [ -L "$p" ]; then
          rm -f -- "$p" || fail_apply "failed to remove $pth"
        elif [ -d "$p" ]; then
          ours=1
          if [ -d "$leaf" ]; then
            while IFS= read -r f; do
              [ -e "${p}/${f#"$leaf"/}" ] || ours=0
            done <<FEOF
$(find "$leaf" -type f | LC_ALL=C sort)
FEOF
            while IFS= read -r f; do
              [ -e "$leaf/${f#"$p"/}" ] || { ours=0; break; }
            done <<PFEF
$(find "$p" -mindepth 1 | LC_ALL=C sort)
PFEF
          else
            ours=0
          fi
          if [ "$ours" = 1 ]; then
            rm -Rf -- "$p" || fail_apply "failed to remove $pth"
          else
            warn "$pth contains files this installer did not create; install-record entry dropped, files kept"
          fi
        fi
        stage_clear_skill "$nm" ;;
      instruction-file)
        if [ -f "$p" ]; then
          cur="$(file_hash "$p")"
          if [ "$cur" = "$(lock_field_str "$line" content_hash)" ]; then
            rm -f -- "$p" || fail_apply "failed to remove $pth"
          else
            warn "$pth was edited after install; left in place, install-record entry dropped"
          fi
        fi
        rm -f -- "$STAGE_DIR/instructions/$pth" 2>/dev/null || true ;;
      rules-block)
        block_remove "$p" || fail_apply "failed to strip managed block from $pth"
        if [ "$(lock_field_bool "$line" created)" = true ] && [ ! -s "$p" ]; then
          rm -f -- "$p" || true
        fi ;;
      *) die "unknown entry type in install record: $typ" 4 ;;
    esac
    nremoved=$((nremoved + 1))
  done
  lock_commit "$KEPT"
  [ -s "$LOCK_FILE" ] || lock_teardown
  prune_empty_dirs
  printf 'Uninstall: project=%s removed=%d shared-untagged=%d\n' "$PROJECT_CANON" "$nremoved" "$nuntagged"
}


# ---------------------------------------------------------------------------
# Install orchestration (deferred writes: all planning/preflight above, only
# apply below touches the project besides our .ompd state)
# ---------------------------------------------------------------------------
do_install() {

# ---------------------------------------------------------------------------
# Desired-entry table. TAB fields:
# 1 action(new|refresh|unchanged|local)  2 path  3 type  4 source(rel)
# 5 mode  6 agents-csv  7 hash  8 staged-or-source(abs)  9 created  10 preimage
# ---------------------------------------------------------------------------
DESIRED=""
add_row() { DESIRED="${DESIRED}${1}${TAB}${2}${TAB}${3}${TAB}${4}${TAB}${5}${TAB}${6}${TAB}${7}${TAB}${8}${TAB}${9}${TAB}${10}${NL}"; }
f_of() { printf '%s' "$1" | cut -d"$TAB" -f"$2"; }

VERSION_TOKEN="$(date -u +%Y-%m-%d)"

# ---- skills (US1) ----
while IFS= read -r dsk; do
  [ -n "$dsk" ] || continue
  ag="$(agents_for skillsdir "$dsk")"
  # shellcheck disable=SC2034 # dom kept for TAB field alignment
  while IFS="$(printf '\t')" read -r dom nm leafdir; do
    [ -n "${nm:-}" ] || continue
    p="$dsk/$nm"; rel="${leafdir#"$CATALOG_ROOT"/}"
    rec="$(record_find_line "$p" || true)"
    stage_dst="$leafdir"
    if [ "$MODE" = copy ]; then
      # copy mode materializes a composite tree (leaf + domain license extras)
      tstage="$STG/skills/$nm"
      rm -rf -- "$tstage"
      mkdir -p "$tstage" || die "cannot build temp staging" 4
      cp -R "$leafdir/." "$tstage/" || die "cannot stage skill $nm" 4
      while IFS= read -r extra; do
        [ -n "$extra" ] || continue
        cp "$extra" "$tstage/$(basename "$extra")" || die "cannot stage license material for $nm" 4
      done <<EXEOF
$(extras_for_leaf "$leafdir")
EXEOF
      newhash="$(tree_hash "$tstage")"
      stage_dst="$tstage"
    else
      newhash="$(tree_hash "$leafdir")"
    fi
    if [ -z "$rec" ]; then
      if [ -e "$PROJECT_CANON/$p" ] || [ -L "$PROJECT_CANON/$p" ]; then
        printf 'install.sh: refusing: %s exists in the project and was not installed by this tool\n' "$p" >&2
        printf 'install.sh: resolve the collision (e.g. rename your directory) or remove it, then re-run.\n' >&2
        exit 3
      fi
      add_row new "$p" skill "$rel" "$MODE" "$ag" "$newhash" "$stage_dst" true "pre:-"
      continue
    fi
    recmode="$(lock_field_str "$rec" mode)"; rechash="$(lock_field_str "$rec" content_hash)"
    recreate="$(lock_field_bool "$rec" created)"
    a2="$(csv_union "$(agents_csv_of "$rec")" "$ag")"
    abs="$PROJECT_CANON/$p"; ok=0
    if [ "$recmode" = symlink ]; then
      if [ -L "$abs" ]; then tgt="$(resolve_path "$abs")"; case "$tgt/" in "$CATALOG_ROOT/"*) ok=1 ;; esac; fi
    else
      [ -d "$abs" ] && ! [ -L "$abs" ] && [ "$(tree_hash "$abs")" = "$rechash" ] && ok=1
    fi
    if [ "$rechash" != "$newhash" ] || [ "$recmode" != "$MODE" ]; then
      if [ "$ok" = 1 ] && [ "$recmode" = "$MODE" ]; then
        : # source changed vs recorded -> catalog refresh, not a local edit
      fi
      add_row refresh "$p" skill "$rel" "$MODE" "$a2" "$newhash" "$stage_dst" "$recreate" "pre:-"
    elif [ "$ok" = 1 ]; then
      if [ "$MODE" != "$recmode" ]; then
        add_row refresh "$p" skill "$rel" "$MODE" "$a2" "$newhash" "$stage_dst" "$recreate" "pre:-"
      else
        add_row unchanged "$p" skill "$rel" "$recmode" "$a2" "$rechash" "$stage_dst" "$recreate" "pre:-"
      fi
    else
      if [ -e "$abs" ] || [ -L "$abs" ]; then
        add_row local "$p" skill "$rel" "$recmode" "$a2" "$rechash" "$stage_dst" "$recreate" "pre:-"
      else
        add_row refresh "$p" skill "$rel" "$MODE" "$a2" "$newhash" "$stage_dst" "$recreate" "pre:-"
      fi
    fi
  done <<ROWS
$ROWSEL
ROWS
done <<DESTS
$DEST_SKILLS
DESTS

# ---- instruction files: verbatim or mdc (US2 files) ----
while IFS= read -r fdir; do
  [ -n "$fdir" ] || continue
  fmt="$(fmt_for_dir "$fdir")"
  ag="$(agents_for files "$fdir")"
  while IFS= read -r src; do
    [ -n "$src" ] || continue
    stem="$(inst_name "$src")"
    rel="${src#"$CATALOG_ROOT"/}"
    if [ "$fmt" = mdc ]; then dst="$fdir/$stem.mdc"; else dst="$fdir/$stem.instructions.md"; fi
    staged_src="$STG/instructions/$dst"
    mkdir -p "$(dirname "$staged_src")" || die "cannot create staging directory" 4
    if [ "$fmt" = mdc ]; then emit_mdc "$src" > "$staged_src"; else cat "$src" > "$staged_src"; fi
    newhash="$(file_hash "$staged_src")"
    rec="$(record_find_line "$dst" || true)"
    if [ -z "$rec" ]; then
      if [ -e "$PROJECT_CANON/$dst" ]; then
        printf 'install.sh: refusing: %s exists in the project and was not installed by this tool\n' "$dst" >&2
        exit 3
      fi
      add_row new "$dst" instruction-file "$rel" copy "$ag" "$newhash" "$staged_src" true "pre:-"
    else
      rechash="$(lock_field_str "$rec" content_hash)"; recreate="$(lock_field_bool "$rec" created)"
      a2="$(csv_union "$(agents_csv_of "$rec")" "$ag")"
      cur_hash=""; [ -f "$PROJECT_CANON/$dst" ] && cur_hash="$(file_hash "$PROJECT_CANON/$dst")"
      if [ "$rechash" != "$newhash" ]; then
        add_row refresh "$dst" instruction-file "$rel" copy "$a2" "$newhash" "$staged_src" "$recreate" "pre:-"
      elif [ ! -f "$PROJECT_CANON/$dst" ] || [ "$cur_hash" != "$rechash" ]; then
        add_row local "$dst" instruction-file "$rel" copy "$a2" "$rechash" "$staged_src" "$recreate" "pre:-"
      else
        add_row unchanged "$dst" instruction-file "$rel" copy "$a2" "$rechash" "$staged_src" "$recreate" "pre:-"
      fi
    fi
  done <<SRCS
$INSTR_ALL
SRCS
done <<DIRS
$FILE_DIRS
DIRS

# ---- rules blocks (US2 blocks; one per unique file, agents unioned) ----
while IFS= read -r bf; do
  [ -n "$bf" ] || continue
  ag="$(agents_for block "$bf")"
  mkdir -p "$STG/blocks"
  staged_rule="$STG/blocks/$(printf '%s' "$bf" | tr '/' '%')"
  printf '%s\n' "$INSTR_ALL" | block_generate "$ag" "$VERSION_TOKEN" > "$staged_rule"
  blk_hash="sha256:$(block_extract "$staged_rule" | _h)"
  relsrcs="$(printf '%s\n' "$INSTR_ALL" | sed "s|$CATALOG_ROOT/||" | paste -sd, -)"
  rec="$(record_find_line "$bf" || true)"
  abs="$PROJECT_CANON/$bf"
  if [ -z "$rec" ]; then
    if [ -f "$abs" ] && block_extract "$abs" 2>/dev/null | grep -q 'genesis-skills:begin'; then
      printf 'install.sh: refusing: %s already contains a genesis-skills block that is not recorded as managed\n' "$bf" >&2
      printf 'install.sh: the file is left untouched. Remove the stray markers or use --mode files with a different agent.\n' >&2
      exit 3
    fi
    if [ -f "$abs" ] && [ -s "$abs" ]; then created=false; else created=true; fi
    if [ -f "$abs" ]; then pre="$(file_hash "$abs")"; else pre="sha256:$(printf '' | _h)"; fi
    add_row new "$bf" rules-block "$relsrcs" - "$ag" "$blk_hash" "$staged_rule" "$created" "$pre"
  else
    recreate="$(lock_field_bool "$rec" created)"; pre="$(lock_field_str "$rec" preimage_hash)"
    recblock="$(lock_field_str "$rec" block_hash)"
    a2="$(csv_union "$(agents_csv_of "$rec")" "$ag")"
    if [ ! -f "$abs" ] || ! block_present "$abs"; then
      add_row refresh "$bf" rules-block "$relsrcs" - "$a2" "$blk_hash" "$staged_rule" "$recreate" "$pre"
    else
      cur="sha256:$(block_extract "$abs" | _h)"
      if [ "$cur" = "$recblock" ]; then
        if [ "$blk_hash" != "$recblock" ] || [ "$a2" != "$(agents_csv_of "$rec")" ]; then
          add_row refresh "$bf" rules-block "$relsrcs" - "$a2" "$blk_hash" "$staged_rule" "$recreate" "$pre"
        else
          add_row unchanged "$bf" rules-block "$relsrcs" - "$a2" "$recblock" "$staged_rule" "$recreate" "$pre"
        fi
      elif [ "$cur" = "$blk_hash" ]; then
        add_row refresh "$bf" rules-block "$relsrcs" - "$a2" "$blk_hash" "$staged_rule" "$recreate" "$pre"
      else
        add_row local "$bf" rules-block "$relsrcs" - "$a2" "$blk_hash" "$staged_rule" "$recreate" "$pre"
      fi
    fi
  fi
done <<BLKS
$BLOCK_FILES
BLKS


# ---------------------------------------------------------------------------
# Desired rows -> apply + lock entries. Order: prune stale first so a dest
# freed by pruning is not clobbered, then apply desired rows.
# ---------------------------------------------------------------------------
mkdir -p "$OMPD_DIR" "$STAGE_DIR" || die "cannot create state dir under $OMPD_DIR (project not writable?)" 3
LOCK_NEW="$TMPB/lock.new"
: > "$LOCK_NEW"
SKIPPED_LOCAL=0

DESIRED_PATHS="$(printf '%s' "$DESIRED" | LC_ALL=C awk 'NF' | cut -d"$TAB" -f2 | LC_ALL=C sort -u)"

# Phase: stale pass over the existing lock
if [ -f "$LOCK_FILE" ]; then
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    pth="$(lock_field_str "$line" path)"
    typ="$(lock_field_str "$line" type)"
    src="$(lock_field_str "$line" source)"
    # rules-block sources are arrays; type check makes scope deterministic
    if printf '%s\n' "$DESIRED_PATHS" | grep -qxF -- "$pth"; then
      continue                       # desired loop writes its lock line
    fi
    if [ "$typ" = instruction-file ]; then
      # Only prune stale files for instruction adapters selected in this run.
      # Other agents' destinations stay recorded and untouched.
      if printf '%s\n' "$FILE_DIRS" | grep -qxF -- "$(dirname "$pth")"; then
        if remove_entry "$line"; then
          sum_note "$pth" removed 1
        else
          fail_apply "failed to remove stale managed content for $pth"
        fi
      else
        printf '%s\n' "$line" >> "$LOCK_NEW"
      fi
      continue
    fi
    if [ "$typ" != skill ]; then
      printf '%s\n' "$line" >> "$LOCK_NEW"   # managed blocks are handled below
      continue
    fi
    if ! source_in_scope "$src"; then
      printf '%s\n' "$line" >> "$LOCK_NEW"
      continue
    fi
    if remove_entry "$line"; then
      sum_note "$pth" removed 1
    else
      fail_apply "failed to remove stale managed content for $pth"
    fi
  done < "$LOCK_FILE"
fi

emit_fresh() { # DESIRED row -> one lock line (stdout)
  local typ pth ag srcs md hsh crt pre s srcjson
  typ="$(f_of "$1" 3)"; pth="$(f_of "$1" 2)"; ag="$(f_of "$1" 6)"
  srcs="$(f_of "$1" 4)"; md="$(f_of "$1" 5)"; hsh="$(f_of "$1" 7)"
  crt="$(f_of "$1" 9)"; pre="$(f_of "$1" 10)"
  # prune agents we no longer selected from the recorded set
  case "$typ" in
    skill)            record_json_skill "$pth" "$ag" "$srcs" "$md" "$hsh" "$crt" ;;
    instruction-file) record_json_instruction_file "$pth" "$ag" "$srcs" "$(fmt_for_dir "$(dirname "$pth")")" "$hsh" "$crt" ;;
    rules-block)
      srcjson="["
      IFS=, read -ra _arr <<< "$srcs" || true
      for s in "${_arr[@]:-}"; do
        [ -n "$s" ] || continue
        srcjson="$srcjson{\"$(json_str "$s")\":\"$(file_hash "$CATALOG_ROOT/$s")\"},"
      done
      srcjson="${srcjson%,}]"
      record_json_rules_block "$pth" "$ag" "$srcjson" "$hsh" "$pre" "$crt" ;;
  esac
}

emit_kept_by_path() { # $1 path: recorded line verbatim (ts stability)
  if [ -f "$LOCK_FILE" ] && rec="$(record_find_line "$1")"; then
    printf '%s\n' "$rec" >> "$LOCK_NEW"
  fi
}

apply_row() { # one DESIRED row
  local act pth typ srcs md ag hsh staged crt abs nm
  act="$(f_of "$1" 1)"; pth="$(f_of "$1" 2)"; typ="$(f_of "$1" 3)"
  srcs="$(f_of "$1" 4)"; md="$(f_of "$1" 5)"; ag="$(f_of "$1" 6)"
  hsh="$(f_of "$1" 7)"; staged="$(f_of "$1" 8)"; crt="$(f_of "$1" 9)"
  abs="$PROJECT_CANON/$pth"; nm="$(basename "$pth")"

  if [ "$act" = unchanged ]; then
    sum_note "$pth" unchanged 1
    if rec="$(record_find_line "$pth")"; then
      if [ "$(agents_csv_of "$rec")" != "$ag" ]; then
        reagents "$rec" "$ag" >> "$LOCK_NEW"
      else
        printf '%s\n' "$rec" >> "$LOCK_NEW"
      fi
    fi
    return 0
  fi
  if [ "$act" = local ]; then
    if ! prompt_replace "$pth"; then
      sum_note "$pth" skipped-local-edit 1
      SKIPPED_LOCAL=1
      emit_kept_by_path "$pth"
      return 0
    fi
    act=refresh
  fi

  case "$typ" in
    skill)
      stage_sync_skill "$nm" "$staged"
      mkdir -p "$(dirname "$abs")"
      if [ -e "$abs" ] || [ -L "$abs" ]; then track_rm "$pth"; fi
      if [ "$act" = new ]; then track_rm "$pth"; fi
      rm -rf -- "$abs" || fail_apply "failed to replace $pth"
      if [ "$md" = symlink ]; then
        ln -s "$staged" "$abs" || fail_apply "failed to link $pth"
      else
        if ! mkdir -p "$abs"; then fail_apply "failed to copy $pth"; fi
        if ! cp -R "$staged/." "$abs/"; then fail_apply "failed to copy $pth"; fi
      fi ;;
    instruction-file)
      mkdir -p "$(dirname "$abs")"
      if [ "$act" = new ]; then track_rm "$pth"; fi
      cp "$staged" "$abs" || fail_apply "failed to write $pth"
      stage_promote "$pth" "$staged" ;;
    rules-block)
      mkdir -p "$(dirname "$abs")"
      if [ ! -e "$abs" ]; then track_rm "$pth"; fi
      block_upsert "$abs" "$staged" || fail_apply "failed to update managed block in $pth"
      stage_promote "blocks/$(printf '%s' "$pth" | tr '/' '%')" "$staged" ;;
  esac

  if [ "$act" = new ]; then sum_note "$pth" created 1; else sum_note "$pth" refreshed 1; fi
  emit_fresh "$1" >> "$LOCK_NEW"
}

while IFS= read -r row; do
  [ -n "$row" ] || continue
  apply_row "$row"
done <<DEOF
$DESIRED
DEOF

# ---------------------------------------------------------------------------
# Commit the lock; tidy the state dir when nothing remains
# ---------------------------------------------------------------------------
lock_commit "$LOCK_NEW"
if [ ! -s "$LOCK_FILE" ]; then
  lock_teardown
fi
  printf 'install: project=%s mode=%s agents=%s\n' "$PROJECT_CANON" "$MODE" "$(printf '%s' "$AGENT_IDS" | paste -sd, -)"
  if [ -z "$DEST_SKILLS" ]; then
    printf '  skills: skipped (no selected agent has a skills location)\n'
  fi
  sum_emit
  printf 'Installed. Record: %s\n' "$LOCK_FILE"
}

# ---------------------------------------------------------------------------
# Dispatch
# ---------------------------------------------------------------------------
lock_refuse_foreign
if [ "$OP" = uninstall ]; then
  do_uninstall
  exit 0
fi
[ -w "$PROJECT_CANON" ] || die "project not writable: $PROJECT_CANON" 3
preflight_dirs
do_install
if [ "${SKIPPED_LOCAL:-0}" = 1 ]; then
  warn "one or more paths were skipped due to local edits; exit 3 signals a partial run"
  exit 3
fi
exit 0
