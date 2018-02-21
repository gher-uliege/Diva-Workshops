## Content

Simple 2D surface analysis (Black Sea), Black Sea data in ODV format:
* Including error field (JMB)
* Manual calibration (JMB)
* Calibration tools (JMB)

2D per levels or 3D (lon,lat,depth) for Black Sea (Alex)

Full 4D analysis on user data (Alex)

Visualization (Charles)

Generation of XML for sextant (Alex)


## How to download .ipynb files from GitHub

1. Click on the .ipynb file you want to download, then click on *Raw*
2. Then, press `ctrl+s` to save it as .ipynb
3. Open jupyter notebook
4. Go to thr location where you saved .ipynb file
5. Open file, you will see the code

## Upgrade divand

In a julia terminal or in a Jupyter notebook cell, type:

```julia
Pkg.update("divand")
```

If `divand` is already up-to-date, this command will not make any change.
It is usually necessary to restart julia (in jupyter notebook you select `Kernel -> Restart`) if `divand` was updated, unless:
  * you did not yet import divand
  * or if you use `import divand` (as opposed to `using divand`), it is sufficient to reload divand with the command `reload("divand")`.

To update all Julia package, use the following command:

```julia
Pkg.update()
```

## Need help?

If you have a problem when running these notebooks, please sure that you are using the latest version of `divand` (see section Upgrade divand) and include a sufficient amount of information that would allow somebody else to reproduce the issue, in particular:

* The full error message that you are seeing (in particular file names and line numbers of the stack-trace).
* Which version of Julia are you using? Please include the output of:

```julia
versioninfo()
```
* Which package are installed and in which version? Please include the output of:

```julia
print(join(["$p: $v\n" for (p,v) in Pkg.installed()]))
```
* Your .ipynb file that produces the issue (unless it is an unmodified version of the sample notebooks).
* An subset of you data to reproduce the problem (unless it is an example data set).

* From which directory are you running the script and do you have permission to write to this directory (and enough disk space)? Please include the output of:

```julia
pwd()
```

<!--  LocalWords:  ODV JMB lon ipynb GitHub ctrl jupyter
 -->
<!--  LocalWords:  divand julia versioninfo pwd
 -->
