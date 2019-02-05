using Test

# Test depth selection
dmin, dmax =  get_closer_depth([-10., -5., 7., 20], 1.);
@test dmin == -5.
@test dmax == 7.

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
