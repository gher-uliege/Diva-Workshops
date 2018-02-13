## Content

Simple 2D surface analysis (Black Sea), Black Sea data in ODV format:
* Including error field (JMB)
* Manual calibration (JMB)
* Calibration tools (JMB)

2D per levels or 3D (lon,lat,profondeur) for Black Sea (Alex)

Full 4D analysis on user data (Alex)

Visualization (Charles)

Generation of XML for sextant (Alex)


## How to download .ipynb files from GitHub

1. Click on the .ipynb file you want to download, then click on Raw
2. Then, press ctrl+s to save it as .ipynb
3. Open jupyter notebook
4. Go to location where you saved .ipynb file
5. Open file, you will see the code

## Upgrade divand


In a julia terminal, type:

```julia
Pkg.update("divand")
```

If `divand` is already up-to-date, this command will not make any change.

To update all Julia package, use the following command:

```julia
Pkg.update()
```

## Need help?

If you have a problem when running these notebooks, please sure that you are using the latest version of `divand` (see section Upgrade divand) and include a sufficient amont of information that would allow somebody else to reproduce the issue, in particular:

* The full error message that you are seeing (in particular file names and line numbers of the stack-trace).
* Which version of Julia are you using? Please include the output of:

```julia
versioninfo()
```
* Which package are installed and in which version? Please include the output of:

```julia
print(join(["$p: $v\n" for (p,v) in Pkg.installed()]))
```
* Your .ipynb file that produces the issue.
* An subset of you data to reproduce the problem.
