---
name: address-pr-comments
description: Use when addressing pull request review comments, implementing reviewer feedback, or drafting replies to review threads.
---

# Address PR comments

Help the user work through PR feedback and prepare clear, friendly responses.
Assess each comment on its merits, make appropriate changes when requested,
and explain the outcome in plain language.

## Gather context

1. Identify the PR and the comments the user wants addressed.
2. Read each comment and its surrounding discussion. When available, note
   the reviewer, thread link, and whether the thread is resolved or outdated.
3. Inspect the relevant code, the PR changes, and any related tests. Look
   for the concern behind the suggestion.
4. If a comment is ambiguous or conflicts with another requirement,
   identify what needs clarification. Continue with independent comments
   where possible.

If the PR or comments cannot be accessed, explain what is missing and use
any context the user has provided. Do not guess at missing details.

## Assess and address feedback

For each requested comment, choose an outcome:

- **Changed:** Implemented the requested change.
- **Partially addressed:** Made part of the change; work or a decision remains.
- **Alternative:** Addressed the concern in a different way.
- **Recommend keeping:** Recommend leaving the current approach in place.
- **Needs clarification:** Cannot confidently decide without more context.

Evaluate suggestions against the code and the user's requirements. Explain
the practical reason for your decision.

When the user has asked you to make changes:

- Keep changes focused on the feedback and the PR's scope.
- Check for the same issue elsewhere in the PR's changed code and address
  matching instances when appropriate.
- Flag related issues outside the requested scope rather than silently
  expanding the work.
- Add or update tests when needed to verify meaningful behavior.
- Run relevant checks using the repository's documented commands. Report
  failures and checks that could not be run.

Inspect outdated but unresolved threads. Determine whether later changes
already addressed the concern before making another change.

## Draft reviewer replies

Draft one ready-to-post response for each requested comment. Write like a
helpful teammate: casual, respectful, and concise. Use plain language, with
technical terms where they make the explanation clearer.

Each reply should state what happened or what you recommend, briefly explain
why, and include a relevant code or commit reference when it helps the
reviewer find the evidence.

Prefer a link to relevant PR lines or a commit when available. Otherwise,
give the file and relevant function or line. For a recommendation to keep the
current approach, reference the existing code or other supporting evidence.

Say "Done" only after a change has actually been made. For partial work, say
what remains. For an unclear request, ask a specific question. Keep replies
natural; mention checks when they directly help answer the reviewer.

### Examples

**Changed**

> Done — the button now stays disabled while the request is running, so it
> can't be submitted twice. See [relevant code link].

**Alternative**

> Good point. I kept the existing button but added a loading state, so people
> can see that the save is still running. See [relevant code link].

**Partially addressed**

> I've added the check for new records. Existing records still need a
> decision on how we want to handle missing values. See [relevant code link].

**Recommend keeping**

> I think we should keep the retry here because a brief connection issue can
> otherwise make the save fail. It's limited to one retry in [relevant code
> link].

**Needs clarification**

> Should this apply to existing records too? Right now the change only
> affects new ones.

Use these examples as patterns, not wording that must be repeated.

## Summary for the user

For each requested comment, provide the comment or thread reference, its
outcome, a ready-to-post reply, the relevant code reference when available,
and any remaining decision or follow-up. For many comments, use a compact
list or table.

Summarize checks run and their results, including relevant checks that were
not run. Do not invent changes, links, line numbers, test results, or reviewer
intent. If a reliable reference is unavailable, say so.

Draft replies for the user to review. Commit, push, post replies, request
another review, or resolve threads only when the user has asked for those
actions.
