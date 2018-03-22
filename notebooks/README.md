## Content

List of notebooks discussed during the DIVA workshop.

1. [01-Julia-introduction.ipynb](01-Julia-introduction.ipynb) (Alexander)
1. [01-netCDF.ipynb](01-netCDF.ipynb) (Charles)
1. [DIVAnd-overview.ipynb](DIVAnd-overview.ipynb) (Alexander)
1. [topography.ipynb](topography.ipynb) (Alexander)
1. [data-downloading.ipynb](data-downloading.ipynb) (Alexander)
1. [ODV-data-import.ipynb](ODV-data-import.ipynb) (Jean-Marie)
1. [processing-quality-check.ipynb](processing-quality-check.ipynb) (Jean-Marie)
1. [L-and-epsilon-effect.ipynb](L-and-epsilon-effect.ipynb) (Jean-Marie)
1. [correlation-length.ipynb](correlation-length.ipynb) (Alexander)
1. [processing-parameter-optimization.ipynb](processing-parameter-optimization.ipynb) (Jean-Marie)
1. [analysis-with-cycles.ipynb](analysis-with-cycles.ipynb) (Jean-Marie)
1. [cpme-demo.ipynb](cpme-demo.ipynb) (Jean-Marie)
1. [open-boundary-conditions.ipynb](open-boundary-conditions.ipynb) (Jean-Marie)
1. [example-analysis.ipynb](example-analysis.ipynb) (Alexander)
1. [generation-XML-metadata.ipynb](generation-XML-metadata.ipynb) (Alexander)
1. [Visualization and post-processing](./postprocessing/README.md) (Charles)


## How to download .ipynb files from GitHub

### Download individual files
1. Click on the .ipynb file you want to download, then click on *Raw*
2. Then, press `ctrl+s` to save it as .ipynb
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

## Upgrade divand

In a julia terminal or in a Jupyter notebook cell, type:

```julia
Pkg.update("divand")
```

If `divand` is already up-to-date, this command will not make any change.
It is usually necessary to restart julia (in Jupyter notebook you select `Kernel -> Restart`) if `divand` was updated, unless:
  * you did not yet import divand
  * or if you use `import divand` (as opposed to `using divand`), it is sufficient to reload divand with the command `reload("divand")`.

To update all Julia package, use the following command:

```julia
Pkg.update()
```

## Need help?

If you have a problem when running these notebooks, please make sure that you are using the latest version of `divand` (see section [Upgrade divand](#upgrade-divand)) and include a sufficient amount of information that would allow somebody else to reproduce the issue, in particular:

- [x] The full error message that you are seeing (in particular file names and line numbers of the stack-trace).
- [x] Which version of Julia are you using? Please include the output of:

```julia
versioninfo()
```
- [x] Which package are installed and in which version? Please include the output of:

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
<!--  LocalWords:  divand julia versioninfo pwd
 -->
