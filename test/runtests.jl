using EarthDataPlots
using Test
using GLMakie, YAXArrays, Dates

# fake data
dates = Date(2021, 1, 1):Day(1):Date(2021, 1, 31)
axlist = [
    RangeAxis("time", dates),
    RangeAxis("lon", range(1, 10, length=15)),
    RangeAxis("lat", range(1, 15, length=20)),
    CategoricalAxis("Variable", ["var1", "var2"])]
data = rand(length(dates), 15, 20, 2)
dsarr = YAXArray(axlist, data)

# datacubeplot(dsarr; kind=:voxel)

@testset "EarthDataPlots.jl" begin
    # Write your tests here.
end
