# Copyright (C) 2005,2013,2017, 2018 Alexander Barth <barth.alexander@gmail.com>
# Copyright (C) 2006 David Saunders (NASA Ames Research Center)
# Copyright (C) 2008 Gian Franco Marras (CINECA) <g.marras@cineca.it>
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, see <http://www.gnu.org/licenses/>.
#
# This file is based on
# git checkout 09894063e966ed8addf49cdbe300bfe2ab4f44dc (9 November 2011)
# released under GPLv2 (or later)


module OptimInterp


# Adapted from Julia 0.6 (MIT)
# Symmetric (real) eigensolvers

@static if VERSION < v"0.7"
    const BLAS = Base.LinAlg.BLAS
    const BlasInt = BLAS.BlasInt
    const chkstride1 = Base.LinAlg.chkstride1
    const checksquare = Base.LinAlg.checksquare
    const liblapack = Base.LinAlg.LAPACK.liblapack
    const chklapackerror = Base.LinAlg.LAPACK.chklapackerror
else
    using LinearAlgebra
    const BLAS = LinearAlgebra.BLAS
    const BlasInt = LinearAlgebra.BLAS.BlasInt
    const chkstride1 = LinearAlgebra.chkstride1
    const checksquare = LinearAlgebra.checksquare
    const liblapack = LinearAlgebra.LAPACK.liblapack
    const chklapackerror = LinearAlgebra.LAPACK.chklapackerror
end
using Compat

@static if VERSION < v"0.7"

for (syev, elty) in
    ((:dsyev_,:Float64),
     (:ssyev_,:Float32))
    @eval begin
        #       SUBROUTINE DSYEV( JOBZ, UPLO, N, A, LDA, W, WORK, LWORK, INFO )
        # *     .. Scalar Arguments ..
        #       CHARACTER          JOBZ, UPLO
        #       INTEGER            INFO, LDA, LWORK, N
        # *     .. Array Arguments ..
        #       DOUBLE PRECISION   A( LDA, * ), W( * ), WORK( * )
        function syev_work(jobz::Char, uplo::Char, A::StridedMatrix{$elty})
            chkstride1(A)
            n = checksquare(A)
            W     = similar(A, $elty, n)
            work  = Vector{$elty}(1)
            lwork = BlasInt(-1)
            info  = Ref{BlasInt}()

            ccall((BLAS.@blasfunc($syev), liblapack), Void,
                  (Ptr{UInt8}, Ptr{UInt8}, Ptr{BlasInt}, Ptr{$elty}, Ptr{BlasInt},
                   Ptr{$elty}, Ptr{$elty}, Ptr{BlasInt}, Ptr{BlasInt}),
                  &jobz, &uplo, &n, A, &max(1,stride(A,2)), W, work, &lwork, info)
            chklapackerror(info[])

            return Int(work[1])
        end

        function syev!(jobz::Char, uplo::Char, A::StridedMatrix{$elty},W::Vector{$elty},work::Vector{$elty})
            chkstride1(A)
            n = checksquare(A)
            lwork = BlasInt(length(work))
            info  = Ref{BlasInt}()

            ccall((BLAS.@blasfunc($syev), liblapack), Void,
                  (Ptr{UInt8}, Ptr{UInt8}, Ptr{BlasInt}, Ptr{$elty}, Ptr{BlasInt},
                   Ptr{$elty}, Ptr{$elty}, Ptr{BlasInt}, Ptr{BlasInt}),
                  &jobz, &uplo, &n, A, &max(1,stride(A,2)), W, work, &lwork, info)
            chklapackerror(info[])
        end

    end
end
end

function select_nearest!(x,ox,param,m,index,distance,d)

    #     Select the m observations from ox(1:nd,1:on) closest to point x(1:nd).

    #     Arguments:


    #     Calculate a measure of (squared) distance to each observation:
    #d = zeros(size(ox,2))
    nd = size(ox,1)

    for i=1:size(ox,2)
        d[i] = zero(eltype(x))

        for j = 1:nd
            d[i] += ((x[j] - ox[j,i]) * param[j])^2
        end
    end

    mysort!(d,m,index)
    distance[:] = d[index]
end


#     --------------------------------------------------------------------------

function mysort!(d,m,pannier)

    #     Return the indices of the m smallest elements in d(:).
    #     The algorithm is succinctly coded, but would a heap sort be faster?


    #      integer :: i,max_pannier(1)

    for i=1:m
        pannier[i] = i
    end

    dummy,max_pannier = findmax(d[pannier])

    for i=m+1:size(d,1)
        if d[i] < d[pannier[max_pannier[1]]]
            pannier[max_pannier[1]] = i
            dummy,max_pannier = findmax(d[pannier])

        end
    end

end

# #     --------------------------------------------------------------------------

#       subroutine observation_covariance(ovar,index,R)
#       implicit none
#       real(wp),intent(in) ::ovar(:)
#       integer,intent(in) :: index(:)
# #     ifdef DIAG_OBS_COVAR
#       real(wp),    intent (out) :: R(size(index))
# #     else
#       real(wp),    intent (out) :: R(size(index),size(index))
#       integer :: i
# #     endif


# #     ifdef DIAG_OBS_COVAR
#       R = ovar(index)
# #     else
#       R = 0
#       do i=1,size(index)
#         R(i,i) = ovar(index(i))
#       end do
# #     endif

#       end subroutine observation_covariance

# #     --------------------------------------------------------------------------

#       function  background_covariance_diva(x1,x2,param) result(c)
#       implicit none
#       real(wp),intent(in) :: x1(:),x2(:),param(:)
#       real(wp) :: c

#       real(wp) :: d(size(x1))
#       real(wp) :: rn

#       d = (x1 - x2)*param
#       rn = sqrt(sum(d**2))

#       if (rn == 0) then
#         c = 1
#       else
#         c = rn * mod_bessel_K1(rn)
#       end if

#       end function background_covariance_diva


# #     --------------------------------------------------------------------------

function mypinv!(A, tolerance, work, D)

    #     Compute pseudo-inverse A+ of symmetric A in factored form U D+ U', where
    #     U overwrites A and D is diagonal matrix D+.

    #     Saunders notes: Working with the factors of the pseudo-inverse is
    #                     preferable to multiplying them together (more stable,
    #                     less arithmetic).  Also, the choice of tolerance is
    #                     not straightforward.  If A is noisy, try 1.e-2 * || A ||,
    #                     else machine-eps. * || A ||  (1 norms).
    #     Arguments:

    #      real(wp), intent (inout) :: A(:,:)  # Upper triangle input; orthogonal U out
    #      real(wp), intent (in)    :: tolerance
    #      real(wp), intent (out)   :: work(:), D(:)

    #     Local variables:

    #      integer :: i, info, N

    #     Execution:

    N = size(A,1)

    # Eigendecomposition/SVD of symmetric A:
    #D[:],A[:,:] = LAPACK.syev!('V', 'U', A)

    #lwork = syev_work('V','U',A)
    #@show lwork
    #work = Vector{eltype(A)}(lwork)
    @static if VERSION < v"0.7"
        syev!('V', 'U', A, D, work)
    else
        D[:],A[:,:] = LAPACK.syev!('V', 'U', A)
#        F = eigen(UpperTriangular(A))
#        A .= F.vectors
#        D = F.values
    end


    #call dsyev ('V', 'U', N, A, N, D, work, size (work), info)

    #     Diagonal factor D+ of pseudo-inverse:
    for j = 1:N
        if D[j] > tolerance
            D[j] = 1/D[j]
        else
            D[j] = 0
        end
    end

end


function  background_covariance(x1,x2,param)
    c = zero(eltype(x1))
    for j = 1:size(x1,1)
        c += ((x1[j] - x2[j]) * param[j])^2
    end
    c = exp(-c)

    #d = (x1 - x2).*param
    #c = exp(-sum(d.^2))
    return c
end


#     --------------------------------------------------------------------------

"""
n: number of dimensions
nobs: number of observations
ng: number of grid cells on target grid

ox: array n x nobs
gx: array n x ng
ox, of    : Observations (size(of,2) is the number of different parameters to analyse)
ovar      : Observation error variances
param     : inverse of correlation lengths
m         : number of nearest observations used
gx        : Target grid coords.
gf, gvar  : Interpolated fields and error variances
"""

function optiminterp!(ox,of,ovar,param,m,gx,gf,gvar)
    gn = size(gx,2)
    nf = size(of,1)  # parameters at each observation point

    T = eltype(of)
    PHiA = Array{T,1}(undef,m)
    D = Array{T,1}(undef,m)

    tolerance = 1e-5

    index = Array{Int,1}(undef,m)
    distance = Array{T,1}(undef,m)
    A = Array{T,2}(undef,m,m)
    PH = Array{T,1}(undef,m)
    R = Array{T,1}(undef,m)
    workd = Vector{T}(undef,size(ox,2))

    percentage_done = 0

    if VERSION < v"0.7"
        lwork = syev_work('V','U',A)
    else
        lwork = 0
    end
    work = Vector{eltype(A)}(undef,lwork)

    for i = 1:gn
        # get the indexes of the nearest observations

        select_nearest!(gx[:,i],ox,param,m,index,distance,workd)

        # form compute the error covariance matrix of the observation

        #@show index
        R[:] = ovar[index]

        # form the error covariance matrix background field
        # A = H P H' and PH = P H'

        for j2 = 1:m
            # Upper triangle only

            for j1 = 1:j2
                A[j1,j2] = background_covariance(ox[:,index[j1]],ox[:,index[j2]],param)
            end

            PH[j2] = background_covariance(gx[:,i],ox[:,index[j2]],param)
        end

        # covariance matrix of the innovation

        # now A = H P H' + R
        for j = 1:m
            A[j,j] = A[j,j] + R[j]
        end

        # pseudo inverse of the covariance matrix of the innovation
        mypinv!(A, tolerance, work, D)

        # i-th row of the Kalman gain:
        # PHiA = P H' (H P H' + R)^(-1)
        #      = P H' A  diag(D)  A'
        # PHiA' = A diag(D) (PH' A)'

        #@show size(A), size(PH), size(D)
        # only transposes on vectors here
        PHiA[:,:] = A * (D .* (PH' * A)')

        # compute the analysis for all fields

        gf[:,i] = of[:,index] * PHiA

        # compute the error variance of the analysis
        gvar[i] = 1 - PHiA ⋅ PH

    end
end

function optiminterp(ox::Array{T,2},of::Array{T,2},ovar::Vector{T},param,m,gx::Array{T,2}) where T
    gn = size(gx,2)
    nf = size(of,1)  # parameters at each observation point

    gf = Array{T,2}(undef,(nf,gn))
    gvar = Array{T,1}(undef,gn)

    optiminterp!(ox,of,ovar,param,m,gx,gf,gvar)
    return gf,gvar
end

"""
    fi,vari = optiminterp(x,f,var,len,m,xi)

Interpolate the data `f` (vector of floats) defined on the grid `x` (tuple of
vector of floats) on the grid defined by `xi` (tuple of arrays).
Observations are assumed to have an error variance of `var` and a correlation
length-scale of `len`. The data are assumed to be anomalied, i.e.
the relevant mean must be substracted before-hand.
The local analysis scheme is implemented which mean that for every grid point
the `m` closest data points are used.
All variances are scaled by an assumed constant background variance.
"""
function optiminterp(x::NTuple{N,Vector{T}},
                     f::Vector{T},
                     var::Vector{T},len,m,xi::NTuple{N,Array{T,N}}) where {T,N}

    # number of observations
    on = length(var)

    # number of target grid points
    gsz = size(xi[1])
    gn = length(xi[1])

    #ox = Array{T,2}(N,on)
    ox = zeros(T,N,on)
    gx = Array{T,2}(undef,(N,gn))

    for i=1:N
        if on != length(x[i])
            error("optiminterpn: x, y,... must have the same number of elements");
        end

        #@show typeof(x[i]),size(ox[i,:])
        ox[i,:] = x[i]
        #@show typeof(ox[i,:])

        if (length(xi[i]) != gn)
            error("optiminterpn: xi, yi, ... must have the same number of elements");
        end

        gx[i,:] = xi[i][:]
    end


    nf = 1
    if (on*nf != length(f) && on != length(var))
        error("optiminterpn: x,y,...,var must have the same number of elements");
    end

    f = reshape(f,nf,on) :: Array{T,2}

    param = 1 ./ len

    fi = Array{T,N}(undef,gsz)
    vari = Array{T,N}(undef,gsz)

    fi[:],vari[:] = optiminterp(ox,f,var,param,m,gx);

    return fi,vari
end

export optiminterp

end # module
