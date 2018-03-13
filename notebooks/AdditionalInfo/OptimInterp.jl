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

const BlasInt = Base.LinAlg.BLAS.BlasInt
const chkstride1 = Base.LinAlg.chkstride1
const checksquare = Base.LinAlg.checksquare
const liblapack = Base.LinAlg.LAPACK.liblapack
const chklapackerror = Base.LinAlg.LAPACK.chklapackerror

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
            
            ccall((Base.LinAlg.BLAS.@blasfunc($syev), liblapack), Void,
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

            ccall((Base.LinAlg.BLAS.@blasfunc($syev), liblapack), Void,
                  (Ptr{UInt8}, Ptr{UInt8}, Ptr{BlasInt}, Ptr{$elty}, Ptr{BlasInt},
                   Ptr{$elty}, Ptr{$elty}, Ptr{BlasInt}, Ptr{BlasInt}),
                  &jobz, &uplo, &n, A, &max(1,stride(A,2)), W, work, &lwork, info)
            chklapackerror(info[])
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
            
        #d[i] = sum(((x - ox[:,i]) .* param).^2)
    end

    #index[:] = sortperm(d)[1:m]
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
    syev!('V', 'U', A, D, work)

    
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
"""

function optiminterp!(ox,of,ovar,param,m,gx,gf,gvar)


      # real(wp), intent(in)  :: ox(:,:), of(:,:)  # Observations (size(of,2) is the number of different parameters to analyse)
      # real(wp), intent(in)  :: ovar(:)           # Observation error variances
      # real(wp), intent(in)  :: param(:)          # inverse of correlation lengths
      # integer,  intent(in)  :: m                 # # nearest observations used
      # real(wp), intent(in)  :: gx(:,:)           # Target grid coords.
      # real(wp), intent(out) :: gf(:,:), gvar(:)  # Interpolated fields.
      #                                            # and error variances
# #     Local variables:

    #       real(wp) :: PH(m)

    gn = size(gx,2)
    nf = size(of,1)  # parameters at each observation point
    
    T = eltype(of)
    PHiA = Array{T,1}(m)
    D = Array{T,1}(m)
    
    #,A(m,m),D(m)

# #ifdef DIAG_OBS_COVAR
#       real(wp) :: R(m)
# #else
#       real(wp) :: R(m,m)
# #endif

#       integer  :: gn,nf,index(m)
#       real(wp) :: distance(m)

#       integer  :: i,j1,j2,j,lwork
    tolerance = 1e-5

# #     ifdef VERBOSE
#       integer  :: percentage_done
# #     endif
# #     ifdef STATIC_WORKSPACE
#       real(wp) :: work((m+2)*m)
# #     else
#       real(wp), allocatable :: work(:)
# #     endif

# #     Execution:

    index = Array{Int,1}(m)
    distance = Array{T,1}(m)
    A = Array{T,2}(m,m)
    PH = Array{T,1}(m)
    R = Array{T,1}(m)
    workd = Vector{T}(size(ox,2))

    #$omp parallel  default(none) private(work,i,PH,PHiA,index,distance,j1,j2,R,D,A) &
#$omp shared(gf,gn,gvar,gx,lwork,m,of,ovar,ox,param,tolerance)

#     ifndef STATIC_WORKSPACE
#      allocate(work(lwork))
#     endif
      
#     ifdef VERBOSE
      percentage_done = 0
#     endif

    lwork = syev_work('V','U',A)
    work = Vector{eltype(A)}(lwork)
    

    
#$omp do 
#      @inbounds for i = 1:gn
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
          #ifdef DIAG_OBS_COVAR
          for j = 1:m
              A[j,j] = A[j,j] + R[j]
          end
          #else
          #        A  = A + R
          #endif
          

          
          # pseudo inverse of the covariance matrix of the innovation
          mypinv!(A, tolerance, work, D)
          
          # F = eigfact(Symmetric(A))
          # A[:,:] = F[:vectors] :: Array{Float64,2}
          # D[:,:] = F[:values] :: Array{Float64,1}
          # for j = 1:m
          #     if (D[j] > tolerance)
          #         D[j] = 1/D[j]
          #     else
          #         D[j] = 0
          #     end
          # end
          
          # now (H P H' + R)^(-1) = A * D * A'
          #D = pinv(A,tolerance)    

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
#$omp end do

#     ifndef STATIC_WORKSPACE
#      deallocate(work)
#     endif
 
#$omp end parallel 
end

function optiminterp{T}(ox::Array{T,2},of::Array{T,2},ovar::Vector{T},param,m,gx::Array{T,2})
    gn = size(gx,2)
    nf = size(of,1)  # parameters at each observation point

    gf = Array{T,2}(nf,gn)
    gvar = Array{T,1}(gn)
    
    optiminterp!(ox,of,ovar,param,m,gx,gf,gvar)
    return gf,gvar
end


function optiminterp{T,N}(x::NTuple{N,Vector{T}},
                           f::Vector{T},
                           var::Vector{T},len,m,xi::NTuple{N,Array{T,N}})

    # number of observations
    on = length(var)

    # number of target grid points
    gsz = size(xi[1])
    gn = length(xi[1])
    
    #ox = Array{T,2}(N,on)
    ox = zeros(T,N,on)
    gx = Array{T,2}(N,gn)

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

    param = 1./len

    fi = Array{T,N}(gsz)
    vari = Array{T,N}(gsz)
    
    fi[:],vari[:] = optiminterp(ox,f,var,param,m,gx);

    return fi,vari
end    

export optiminterp

end # module
