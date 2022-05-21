# EarthDataPlots
WIP: Adding features on request :D

## Installation

```julia
julia>]
pkg> add https://github.com/lazarusA/EarthDataPlots.git
```

## Quick start

```julia
using EarthDataPlots, GLMakie
```

Note, that you will also need GLMakie in order to create the plots. And,
since the recipes are designed to work with lazy loading from YAXArrays
we will need input in that format.

```julia
using YAXArrays, Dates, Colors
```

```julia
dates = Date(2021, 1, 1):Day(1):Date(2021, 1, 31)
axlist = [
    RangeAxis("time", dates),
    RangeAxis("lon", range(1, 10, length=15)),
    RangeAxis("lat", range(1, 15, length=20)),
    CategoricalAxis("Variable", ["var1", "var2"])]
data = rand(length(dates), 15, 20, 2)
dsarr = YAXArray(axlist, data)
```

Then, plotting our first cube is done with

```julia
datacubeplot(dsarr; kind=:voxel, colormap=:linear_bmy_10_95_c71_n256)
save("./imgs/voxel.png", current_figure())
```
<img src="./imgs/voxel.png" width = "100%">


Currently, 3 options are supported, :volume, :contour and :voxel. In the
:voxel mode you can pass also an array of RGB color per box.

```julia
fig = with_theme(theme_dark()) do
    fig = Figure(resolution = (1400, 1200))
    axs = [LScene(fig[i,j]; show_axis = false) for i in 1:2 for j in 1:2]
    for (k,kind) in enumerate([:volume, :contour, :voxel])
        datacubeplot!(axs[k], dsarr; kind)
    end
    datacubeplot!(axs[4], dsarr; kind = :voxel, color =vec(rgb))
    fig
end
save("./imgs/simpleVCVrgb.png", fig)
```
<img src="./imgs/simpleVCVrgb.png" width = "100%">

More features will come soon!