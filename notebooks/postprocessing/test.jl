using Test
include("mergingclim.jl")

# Test depth selection
dmin, dmax =  get_closer_depth([-10., -5., 7., 20], 1.);
@test dmin == -5.
@test dmax == 7.

# Test when outside the depth interval
dmin, dmax =  get_closer_depth([-10., -5., 7., 20], 100.);
@test dmin == nothing
@test dmax == nothing

# Testing the linear interp
w1, w2 = get_depth_weights(15., 10., 30.)
a = [[1 2]; [3 4]]
b = [[5 3]; [3 4]]
ab = w1 * a + w2 * b
@test ab == [[4.0  2.75]; [3.0  4.0]]

# Testing the depth calculation
w1, w2 = get_depth_weights(-10., -20., 0.)
@test w1 == 0.5
@test w2 == 0.5
w1, w2 = get_depth_weights(-5., -20., 0.)
@test w1 == 0.75
@test w2 == 0.25
w1, w2 = get_depth_weights(100., 125., 150.)
@test w1 == nothing
@test w2 == nothing

# Testing the vertical interpolation

function make4D_test(I, J, K, L)
    field4D = zeros(I, J, K, L)
    for i = 1:I
        for j = 1:J
            for k = 1:K
                for l = 1:L
                    field4D[i, j, k, l] = k * l;
                end
            end
        end
    end
    return field4D
end

f4 = make4D_test(2, 4, 3, 2)
depthregion = [0., 10., 20., 30.]
depthinterp = 7.5;
f4interp = depth_interp(depthinterp, depthregion, f4)
@test f4interp[:,:,1] == 1.25 * ones(2, 4)
@test f4interp[:,:,2] == 2.5 * ones(2, 4)

# Test the function to get the depth indices
depthgrid = [0, 5.3, 10.2, 24.]
indmin, indmax = get_depth_indices(6.6, depthgrid)
@test indmin == 2
@test indmax == 3
