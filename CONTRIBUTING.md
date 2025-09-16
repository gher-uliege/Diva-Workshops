# Notes for Contributors

The developments of [`DIVAnd`](https://github.com/gher-uliege/DIVAnd.jl/) and the present set of notebooks are most of the time user-driven:        
if you consider something is missing and should be improved, don't hesitate to make your voice heard!    

This document helps you find the best way to make this project better.

## Code of Conduct

We are committed to fostering an open, inclusive, and respectful community for all contributors to the `Diva-Workshops` project. 

We ask every contributor to follow the guidelines: 
- Treat all participants with respect, kindness, and professionalism, regardless of their background, experience, or perspectives. 
- Engage in constructive and collaborative communication, avoiding any form of harassment, discrimination, or offensive behavior. 
- Provide feedback thoughtfully and accept it gracefully. 

These principles have to be applied in all interactions: code, documentation, issues, and pull requests. 

## Seeking support
 
The notebooks are supposed to be self-explanatory, but if some parts are not clear enough, indicate the part of the notebook that has to be improved.

When help is needed with a specific application, it is always good to have access to the original data (or a subset of it) and the notebook that lead to the problem.

## Got a Question?

If the question relates to 
- the notebooks from this repos: feel free to [open a new issue](https://github.com/gher-uliege/Diva-Workshops/issues/new?template=question.md).
- to `DIVAnd`: check the [corresponding documentation](https://gher-uliege.github.io/DIVAnd.jl/stable/) and if needed, [submit an issue](https://github.com/gher-uliege/DIVAnd.jl/issues/new/choose).
- to the Julia language: ask your question on the [Discourse channel](https://discourse.julialang.org/).     

## Missing a feature?

We've done our best to guide you through the process of creating a climatology, from data ingestion to generating the final product.      
If you find that:
- a notebook lacks clear explanations or needs improvement,
- a new notebook is needed to address a specific part of the workflow,
- a notebooks should be added to support additional data types (other than oceanography),

please share your suggestions by opening a [new issue](https://github.com/gher-uliege/Diva-Workshops/issues/new?template=contributing-to-the-module.md). 

Ideally, the datasets used in the notebooks should be publicly available.

### Found a bug? 

The preferred way to report an issue is also through the [GitHub Issue]((https://github.com/gher-uliege/Diva-Workshops/issues/new?template=contributing-to-the-module.md)).           
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


