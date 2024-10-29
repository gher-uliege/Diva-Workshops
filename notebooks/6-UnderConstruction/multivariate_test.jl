using PyPlot
using LinearAlgebra
using Statistics
using Pkg
using DIVAnd
@show pathof(DIVAnd)

#   Prepare data
#   ==============

ND=159
NX=200
NY=250
NV=2
len=0.2
# obs. error variance normalized by the background error variance
epsilon2 = 1.0;

# function to interpolate
fun(x,y,v) = 2*(sin.(6x) * cos.(6y))*(1.5-v) .+ (v.-1.0) .* x .* y

# observations
x = 0.5.+0.25.*randn(ND);
y = 0.5  .+ 0.25 .* randn(ND);
v = mod.(rand(Int,ND),2).+1

x[v.>1.5] .+= 0.2
x[v.<1.5] .+= -0.2
f = fun.(x,y,v)+0.2*randn(ND)
# final grid
xi,yi,vi = ndgrid(range(0,stop=1,length=NX),range(0,stop=1,length=NY),1:2);

# reference field
fref = fun.(xi,yi,vi)

# all points are valid points
mask = trues(size(xi));
mask[10:30,20:50,:].=false

pm = ones(size(xi)) / (xi[2,1,1]-xi[1,1,1]);
pn = ones(size(xi)) / (yi[1,2,1]-yi[1,1,1]);
pv = ones(size(xi)) / (vi[1,1,2]-vi[1,1,1]);

# univariate analysis
@time fi0,s = DIVAndrun(mask[:,:,1],(pm[:,:,1],pn[:,:,1]),(xi[:,:,1],yi[:,:,1]),(x,y),f,(len,len),epsilon2);
# 'multivariate' analysis but with zero for the correlation length
@time fi,s = DIVAndrun(mask,(pm,pn,pv),(xi,yi,vi),(x,y,v),f,(len,len,0.0),epsilon2);

ax = plt.subplot(121)
ax.scatter(x, y, s=5, c=f, vmin=-1, vmax=1, zorder=3)
ax.pcolor(xi[:,:,1],yi[:,:,1], fi0, vmin=-1, vmax=1, zorder=2)
ax.set_xlim(0., 1.)
ax.set_ylim(0., 1.)

ax = plt.subplot(122)
ax.scatter(x, y, s=5, c=f, vmin=-1, vmax=1, zorder=3)
ax.pcolor(xi[:,:,1],yi[:,:,1], fi[:,:,1], vmin=-1, vmax=1)
ax.set_xlim(0., 1.)
ax.set_ylim(0., 1.)
