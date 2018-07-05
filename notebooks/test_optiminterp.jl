# Copyright (C) 2006,2017 Alexander Barth <barth.alexander@gmail.com>
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along with
# this program; if not, see <http://www.gnu.org/licenses/>.

# Tests 1D, 2D, 3D and 4D optimal interpolation.
# All tests should pass; any error indicates that either 
# there is a bug in the optimal interpolation package or 
# that it is incrorrectly installed.

import DIVAnd
import OptimInterp
using Base.Test
#function test_optiminterp
# grid of background field

# From Julia 0.6 MIT
# https://github.com/JuliaLang/julia/blob/05037f51b6258397dc3ba6a4ac8e1de198d4ad5a/examples/ndgrid.jl
# ---

function ndgrid_fill(a, v, s, snext)
    for j = 1:length(a)
        a[j] = v[div(rem(j-1, snext), s)+1]
    end
end

function ndgrid(vs::AbstractVector{T}...) where T
    n = length(vs)
    sz = map(length, vs)
    out = ntuple(i->Array{T}(sz), n)
    s = 1
    for i=1:n
        a = out[i]::Array
        v = vs[i]
        snext = s*size(a,i)
        ndgrid_fill(a, v, s, snext)
        s = snext
    end
    out
end

# ---


function mytest(szi,sz)
    xi = ndgrid([linspace(0,1,s) for s in szi]...)
    fi_ref = .*([cos.(6*c) for c in xi]...)

    # grid of observations

    x = ndgrid([linspace(0,1,s) for s in sz]...)
    x = ([c[:] for c in xi]...)
    f = .*([cos.(6*c) for c in x]...)
    
    var = 0.01 * ones(f)

    m = 20
    
    len = ntuple(i -> 1/10,length(sz))
    
    fi = zeros(szi)
    vari = zeros(szi)


    @time begin
    #@profile begin
        fi[:],vari[:] = optimal_interpolation.optiminterpn(x,f,var,len,m,xi);
    end

    rms = sqrt(mean((fi_ref[:] - fi[:]).^2));

    @test rms ≈ 0 atol=0.05
end

nd = 4


mytest((8,8,8,8),(10,10,10,10))

szi = (8,8,8,8)
xi = ndgrid([linspace(0,1,s) for s in szi]...)
fi_ref = .*([cos.(6*c) for c in xi]...)

# grid of observations

sz = (10,10,10,10)
x = ndgrid([linspace(0,1,s) for s in sz]...)
x = ([c[:] for c in xi]...)
f = .*([cos.(6*c) for c in x]...)

var = 0.01 * ones(f)

m = 20

len = ntuple(i -> 1/10,length(sz))

fi = zeros(szi)
vari = zeros(szi)


#@time begin
@profile begin
fi[:],vari[:] = OptimInterp.optiminterp(x,f,var,len,m,xi);
end

rms = sqrt(mean((fi_ref[:] - fi[:]).^2));

#if (rms > 0.04) 
#    error("unexpected large difference with reference field");
#end

@show rms

