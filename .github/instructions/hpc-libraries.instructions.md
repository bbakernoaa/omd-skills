---
description: Guidance for scientific libraries used in ocean and atmosphere modeling
applyTo: "**/*.{f90,F90,f,for,ftn,cpp,hpp,c,h,cc,hh,cxx,hxx,py}"
---

# Scientific library guidance

Follow the project's existing libraries, versions, interfaces, formats, and platform constraints. Introduce dependencies only when warranted. Verify APIs and supported modes in the documentation for the installed version.

- **ESMF:** When used, check return codes and follow the component's coupling, field, grid, and time conventions. See the [ESMF reference](https://earthsystemmodeling.org/docs/release/latest/ESMF_refdoc/).
- **ParallelIO:** When used, verify communicator, initialization, decomposition, and collective requirements against [ParallelIO documentation](https://ncar.github.io/ParallelIO/). Avoid gathering arrays that exceed root-rank memory.
- **NetCDF:** Choose format, compression, chunking, and serial or parallel access based on existing file contracts, library build, access pattern, and measured needs. See [NetCDF-C](https://docs.unidata.ucar.edu/netcdf-c/current/) and [NetCDF-Fortran](https://docs.unidata.ucar.edu/netcdf-fortran/current/).
- **Zarr:** Match chunks, metadata, format version, and synchronization to the storage backend and reader/writer pattern. A lazy task graph alone does not prevent concurrent-write races. Consult the [Zarr documentation](https://zarr.readthedocs.io/).
- **NCEPLIBS:** Use project-approved versions and routines where required by the target; consult [NCEPLIBS](https://github.com/NOAA-EMC/NCEPLIBS).

For NCO/WCOSS delivery verify applicable current standards; for research follow the actual environment. Report unverified assumptions.
