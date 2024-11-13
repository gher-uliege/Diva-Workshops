- [x] __Steps executed so far leading to an error or issue__

- [x] __Full error message__
  (in particular file names and line numbers of the stack-trace).

- [x] __Operating system__ [e.g. Ubuntu XX.YY]
  
- [x] __CPU architecture__ (Intel/AMD x86_64, PowerPC, ARM, Appel M1,...)

- [x] __Julia version__  include the output of:

```julia
versioninfo()
```
- [x] __Packages (and versions)__ include the output of:

```julia
using Pkg; Pkg.status(mode=PKGMODE_MANIFEST)
```

- [x] __Notebook file__ (or a link to that file) file that produces the issue (unless it is an unmodified version of the sample notebooks).
- [ ] 
- [x] __Subset of the data__ to reproduce the problem (unless it is an example data set).

- [x] __Directory from which the code is run__      
  Check if you have permission to write to this directory (and enough disk space)? Include the output of:
```julia
pwd()
```

It is very important to provide the full error message and the lines following the error message because it contains valuable information where the error/issue was produced.

Windows users can have a look at this link to enable the quick edit mode and to facilitate copying and pasting commands and text in the terminal: https://blogs.msdn.microsoft.com/adioltean/2004/12/27/useful-copypaste-trick-in-cmd-exe/
