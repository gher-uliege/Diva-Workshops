## Content

Downloding and preparing a topography

Loading data with some simple selection examples

Simple 2D analysis:
* Effect of changing analysis parameters 
* Calibration tools 
* Error fields
* Data quality check in postprocessing

2D per levels or 3D (lon,lat,depth) for Black Sea (Alex)

Full 4D analysis on user data (Alex)

[Visualization and post-processing](./postprocessing/README.md) (Charles)

Generation of XML for sextant (Alex)

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
- [x] An subset of you data to reproduce the problem (unless it is an example data set).

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
