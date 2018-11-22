## Content

List of notebooks discussed during the DIVA workshop.

1. [01-notebooks-basics.ipynb](01-notebooks-basics.ipynb): how to use a jupyter-notebook.
1. [02-Julia-introduction.ipynb](02-Julia-introduction.ipynb): starting with the Julia language.
1. [03-netCDF.ipynb](03-netCDF.ipynb): reading and writing a netCDF file with Julia.
1. [04-OI-variational-analysis-introduction.ipynb](04-OI-variational-analysis-introduction.ipynb): an intro to variational analysis.
1. [05-DIVAnd-overview.ipynb](05-DIVAnd-overview.ipynb): an overview on the `DIVAnd` interpolation tool.
1. [06-topography.ipynb](06-topography.ipynb): reading and editing a topography to create the land-sea mask.
1. [07-reading-data.ipynb](07-reading-data.ipynb): different tools to read different types of data.
1. [08-data-downloading.ipynb](08-data-downloading.ipynb): getting data from databases such as WOD or CMEMS.
1. [09-ODV-data-import.ipynb](09-ODV-data-import.ipynb): reading `ODV` spreadsheet files.
1. [10-processing-quality-check.ipynb](10-processing-quality-check.ipynb): data quality check using the analysis itself.
1. [11-L-and-epsilon-effect.ipynb](11-L-and-epsilon-effect.ipynb): showing the effect of the 2 main analysis parameters.
1. [12-correlation-length.ipynb](12-correlation-length.ipynb): how to estimate the correlation length.
1. [13-processing-parameter-optimization.ipynb](13-processing-parameter-optimization.ipynb): how to further optimise the analysis parameters. 
1. [14-cpme-demo.ipynb](14-cpme-demo.ipynb): computation of the error field using the so-called CPME method.
1. [15-example-analysis.ipynb](15-example-analysis.ipynb): how to run a simple analysis?
1. [16-plot-results.ipynb](16-plot-results.ipynb): plotting the results and the mask.
1. [17-relative-correlation-length.ipynb](17-relative-correlation-length.ipynb): working with a relative correlation length.
1.	[18-defining-time-periods.ipynb](18-defining-time-periods.ipynb): how to select time periods?
1.	[90-full-analysis.ipynb](90-full-analysis.ipynb): a full example, from data to 4D netCDF and XML for the catalog.


## How to download .ipynb files from GitHub

### Download all files

Follow [this link](https://github.com/gher-ulg/Diva-Workshops/archive/master.zip) and uncompress the zip file.
The notebooks are in the folder `Diva-Workshops-master/notebooks/`.

### Download individual files
1. Click on the .ipynb file you want to download, then click on *Raw*
2. Then, press `CTRL + s` to save it as .ipynb
3. Open jupyter notebook
4. Go to the location where you saved .ipynb file
5. Click on the file, you will see the code in your browser

![github_download](https://user-images.githubusercontent.com/11868914/36780897-9db97b3a-1c74-11e8-8278-42b61fa0b57f.png)


### For GitHub users

You can directly clone the whole project:
```bash
git clone git@github.com:gher-ulg/Diva-Workshops.git
```
and then navigate into the notebooks directory.

## Open a notebook file

There are different ways to open a `ipynb` file, the following works on all platforms.

* Start Julia
* In the Julia terminal:

```julia
cd("path")
using IJulia
notebook()
```

where `path` is the file path containing the notebook files on your system.

## Upgrade DIVAnd

In a julia terminal or in a Jupyter notebook cell, type:
* For Julia 0.6:
```julia-repl
Pkg.update("DIVAnd")
```
* For Julia 0.7 and above, open the [Pkg REPL-mode](https://docs.julialang.org/en/v1/stdlib/Pkg/index.html#Getting-Started-1):
```julia
update DIVAnd
```

If `DIVAnd` is already up-to-date, this command will not make any change.
It is usually necessary to restart julia (in Jupyter notebook you select `Kernel -> Restart`) if `DIVAnd` was updated, unless:
  * you did not yet import `DIVAnd`
  * or if you use `import DIVAnd` (as opposed to `using DIVAnd`), it is sufficient to reload DIVAnd with the command `reload("DIVAnd")`.

To update all Julia package, use the following command:

* For Julia 0.6
```julia
Pkg.update()
```
* For Julia 0.7 and above:
```julia
update()
```

## Need help?

If you have a problem when running these notebooks, please make sure that you are using the latest version of `DIVAnd` (see section [Upgrade DIVAnd](#upgrade-DIVAnd)) and include a sufficient amount of information that would allow somebody else to reproduce the issue, in particular:

- [x] The full error message that you are seeing (in particular file names and line numbers of the stack-trace).
- [x] Which version of Julia are you using? Include the output of:

```julia
versioninfo()
```
- [x] Which packages (and version) are installed? Include the output of:

```julia
print(join(["$p: $v\n" for (p,v) in Pkg.installed()]))
```
- [x] Your .ipynb file that produces the issue (unless it is an unmodified version of the sample notebooks).
- [x] A subset of your data to reproduce the problem (unless it is an example data set).

- [x] From which directory are you running the script and do you have permission to write to this directory (and enough disk space)? Please include the output of:

```julia
pwd()
```

### GitHub users

Submit an issue with the details mentioned in the previous sections.

<!--  LocalWords:  ODV JMB lon ipynb GitHub ctrl jupyter
 -->
<!--  LocalWords:  DIVAnd julia versioninfo pwd
 -->
