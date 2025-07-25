# Notes for Contributors

The developments of [`DIVAnd`](https://github.com/gher-uliege/DIVAnd.jl/) and the present set of notebooks are lost of the time user-driven:        
if you consider something is missing and should be improved, don't hesitate to make your voice heard!      
First you need to know whether your chance is related to
1. `DIVAnd`: need of new functionalities, improved documentation, bug...
2. The notebooks: please follow the instructions below.

## Improving `DIVAnd`

[Submit an issue](https://github.com/gher-uliege/DIVAnd.jl/issues/new/choose) or contact the main developers by mail.      

## Improving the notebooks

### Contributing to the module

If you have a notebook showing a `DIVAnd` application that doesn't appear in the present set of notebooks, or would like to have an exemple notebook providing a workflow not described in other notebooks, you can either:
1. Submit a pull-request.
2. Open a [new issue](https://github.com/gher-uliege/Diva-Workshops/issues/new/choose) describing your application.
3. Contact the developers by mail, if you don't have a GitHub account.

Ideally, the datasets used in the notebooks should be publicly available.

### Reporting issues or problems with the repository 

The preferred way to report an issue is also through the GitHub Issue.           
The relevant pieces of information that should appear in the issue are:
✅ The Julia version:
```julia
VERSION
v"1.11.5"       
```        
✅ The `DIVAnd` version:
```julia
using Pkg
Pkg.status("DIVAnd")        
```
✅ The name of the notebook that lead to the problem.      
✅ The full screen output, preferably obtained after setting `ENV["JULIA_DEBUG"] = "DIVAnd"`.        
✅ Full stack trace with error message.              

### Seeking support

The main Julia documentation is available from https://docs.julialang.org/en/v1/ while the `DIVAnd` documentation is available from https://gher-uliege.github.io/DIVAnd.jl/stable/.      
The notebooks are supposed to be self-explanatory, but if some parts are not clear enough, indicate the part of the notebook that has to be improved.

When help is needed with a specific application, it is always good to have access to the original data (or a subset of it) and the notebook that lead to the problem.
