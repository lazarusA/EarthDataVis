using EarthDataVis
using YAXArrays
using CairoMakie
CairoMakie.activate!(type = "svg") #hide

# ## Unique location

# Let's consider a simple case, with only one location

axlist = [
    RangeAxis("time", range(1, 20, length=20)),
    RangeAxis("lon", [-67.4598]),
    RangeAxis("lat", [34.4648]),
    ]
data = rand(20, 1, 1)
ds = YAXArray(axlist, data)

# Getting the data back from YAXArray

d = ds.data[:,1,1]

# ## Simple Plot

lines(d)

# Adding labels

fig, ax, obj = lines(d;
    label = "y1",
    axis = (;
        xlabel = "x",
        ylabel = ""),
    figure = (;
        resolution=(600,400))
        )
axislegend(ax)
fig

# ## Selecting one location

axlist = [
    RangeAxis("time", range(1, 20, length=20)),
    RangeAxis("lon", range(-67.4598,-66.4598, length=2)),
    RangeAxis("lat", range(-34.4648, -33.4648, length=2)),
    ]
data = rand(20, 2, 2)
ds = YAXArray(axlist, data)

d = subsetcube(ds, lon = -67.4598, lat =-34.4648 ).data

lines(d)

fig, ax, obj = lines(d;
    label = "y1",
    axis = (;
        xlabel = "x",
        ylabel = ""),
    figure = (;
        resolution=(600,400))
        )
axislegend(ax)
fig

# ## Selecting location with an extra axis

axlist = [
    RangeAxis("other", 1:4),
    RangeAxis("time", range(1, 20, length=20)),
    RangeAxis("lon", range(-67.4598,-66.4598, length=2)),
    RangeAxis("lat", range(-34.4648, -33.4648, length=2)),
    ]
data = rand(4, 20, 2, 2)
ds = YAXArray(axlist, data)

d = subsetcube(ds, lon = -67.4598, lat =-34.4648 ).data

series(d)

# adding labels and colors

fig, ax, obj = series(d;
    labels = ["y$(i)" for i in 1:4], # list of labels
    color = resample_cmap(:mk_12, 4), # list of colors for each line
    axis = (;
        xlabel = "time",
        ylabel = ""),
    figure = (;
        resolution=(600,400))
    )
axislegend(ax)
fig