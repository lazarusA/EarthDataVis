using EarthDataPlots
using GLMakie, YAXArrays, Dates
using Colors

# fake data
dates = Date(2021, 1, 1):Day(1):Date(2021, 1, 31)
axlist = [
    RangeAxis("time", dates),
    RangeAxis("lon", range(1, 10, length=15)),
    RangeAxis("lat", range(1, 15, length=20)),
    CategoricalAxis("Variable", ["var1", "var2"])]
data = rand(length(dates), 15, 20, 2)
dsarr = YAXArray(axlist, data)
# some rgb colors also per data point.
rgb = [RGBA(rand(3)...,) for r in 1:length(dates), g in 1:15, b in 1:20];

datacubeplot(dsarr; kind=:voxel, colormap=:linear_bmy_10_95_c71_n256)
save("../imgs/voxel.png", current_figure())

fig = with_theme(theme_dark()) do
    fig = Figure(resolution = (1400, 1200))
    axs = [LScene(fig[i,j]; show_axis = false) for i in 1:2 for j in 1:2]
    for (k,kind) in enumerate([:volume, :contour, :voxel])
        datacubeplot!(axs[k], dsarr; kind)
    end
    datacubeplot!(axs[4], dsarr; kind = :voxel, color =vec(rgb))
    fig
end
save("../imgs/simpleVCVrgb.png", fig)