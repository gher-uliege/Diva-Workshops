## Content

The notebooks are now organised into 5 categories, separated in folders:
* [1-Intro](./1-Intro/readme.md)
* [2-Preprocessing](./2-Preprocessing/readme.md)
* [3-Analysis](./3-Analysis/readme.md)
* [4-Postprocessing](./4-Postprocessing/readme.md)
* [5-AdvancedTopics](./5-AdvancedTopics/readme.md)

## How to download .ipynb files from GitHub

### Download all files

Follow [this link](https://github.com/gher-uliege/Diva-Workshops/archive/master.zip) and uncompress the zip file.
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
git clone git@github.com:gher-uliege/Diva-Workshops.git
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

```julia-repl
using Pkg
Pkg.update("DIVAnd")
```

If `DIVAnd` is already up-to-date, this command will not make any change.
It is usually necessary to restart julia (in Jupyter notebook you select `Kernel -> Restart`) if `DIVAnd` was updated, unless:
  * you did not yet import `DIVAnd`
  * or if you use `import DIVAnd` (as opposed to `using DIVAnd`), it is sufficient to reload DIVAnd with the command `reload("DIVAnd")`.

To update all the Julia packages, use the following command:

```julia
using Pkg
Pkg.update()
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
