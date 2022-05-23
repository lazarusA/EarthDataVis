using EarthDataPlots
using GLMakie, YAXArrays, Dates
using Colors
using YAXArrayBase

# fake data
dates = Date(2021, 1, 1):Day(1):Date(2021, 1, 31)
axlist = [
    RangeAxis("time", dates),
    RangeAxis("lon", range(1, 2, length=15)),
    RangeAxis("lat", range(1, 4, length=20)),
    CategoricalAxis("Variable", ["var1", "var2"])]
data = rand(length(dates), 15, 20, 2)
dsarr = YAXArray(axlist, data)

allnames = YAXArrayBase.dimnames(dsarr)

namesplot(dsarr)

# some rgb colors also per data point.
rgb = [RGBA(rand(3)...,) for r in 1:length(dates), g in 1:15, b in 1:20];

#ps = [Point3f(i, j, k) for i in 1:length(dates), j in range(1, 2, length=15) for k in range(1, 4, length=20)]
#fig, ax, obj = meshscatter(ps;
#    marker = Rect3f(Vec3f(-0.5), Vec3f(1)), markersize = Vec3f(0.9, 0.05, 0.12))
#scale!(ax.scene, 1,20,15)
#center!(ax.scene)
#fig


datacubeplot(dsarr; kind=:voxel, axvals=:vals_tscale,
    varname="var1",
    colormap=:linear_bmy_10_95_c71_n256)

datacubeplot(dsarr; kind=:voxel, axvals=:vals,
    colormap=:linear_bmy_10_95_c71_n256,
    axis=(; type=Axis3))


save("../imgs/voxel.png", current_figure())
fig = with_theme(theme_dark()) do
    fig = Figure(resolution=(1400, 1200))
    axs = [Axis3(fig[i, j]; perspectiveness=0.5f0, azimuth=1.275π * 1.77) for i in 1:2 for j in 1:2]
    for (k, kind) in enumerate([:volume, :contour, :voxel])
        datacubeplot!(axs[k], dsarr; kind, axvals=:vals)
    end
    datacubeplot!(axs[4], dsarr; kind=:voxel, axvals=:vals, color=vec(rgb))
    fig
end

save("../imgs/simpleVCVrgb_axis3.png", fig)

fig = with_theme(theme_dark()) do
    fig = Figure(resolution=(1400, 1200))
    axs = [LScene(fig[i, j]; show_axis=false) for i in 1:2 for j in 1:2]
    for (k, kind) in enumerate([:volume, :contour, :voxel])
        datacubeplot!(axs[k], dsarr; kind)
    end
    datacubeplot!(axs[4], dsarr; kind=:voxel, color=vec(rgb))
    fig
end

mapplot(dsarr; kind=:scatter)

save("../imgs/simpleVCVrgb.png", fig)
