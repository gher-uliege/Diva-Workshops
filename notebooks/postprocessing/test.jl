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

"""
Create a 2D field for the tests
"""
function make2D_test(I, J)
    field2D = zeros(I, J)
    for i = 1:I
        for j = 1:J
            field2D[i, j] = i * j;
        end
    end
    return field2D
end

# Testing the horizontal interpolation
lon = collect(10.:.5:16.);
lat = collect(22.:.25:30.);
f2 = make2D_test(length(lon), length(lat));
longrid = collect(9:.1:16);
latgrid = collect(21:.2:24);
loninterp, latinterp, finterp = interp_horiz(lon, lat, f2, longrid, latgrid);
longrid2 = collect(16.5:0.1:17)
loninterp2, latinterp2, finterp2 = interp_horiz(lon, lat, f2, longrid2, latgrid);

@test loninterp[1] == maximum((lon[1], longrid[1]))
@test loninterp[end] == minimum((lon[end], longrid[end]))
@test latinterp[1] == maximum((lat[1], latgrid[1]))
@test latinterp[end] ==  minimum((lat[end], latgrid[end]))
@test finterp[4, 3] ≈ 4.16
@test finterp[end-4, end-3] ≈ 80.52
@test length(loninterp2) == 0
@test size(finterp2) == (0, 11)
