using Revise
using EarthDataVis
using GLMakie, YAXArrays, Dates, NetCDF
using Colors

dsarrC = Cube("./data/34JBM1608_2017-06.nc")

fig = Figure(resolution = (800,800))
ax = Axis3(fig[1,1], aspect = (1,1,1), perspectiveness= 0.5)
datacubeplot!(ax, dsarrC; kind=:voxel, xname = :longitude, yname = :latitude,
    axvals=:vals, varname="ndvi_target", shading = false,
    colormap=:fastie, colorrange=(-1,1))
fig
save("../imgs/realcube.png", fig)

#heatmap(dsarr.lon.values, dsarr.lat.values,
#    dsarr[variable="ETOPO1avg"].data[:,:])
dsarr = Cube("./data/ETOPO1_halfdegree.nc")
fig = mapplot(dsarr)
save("../imgs/mapplot.png", fig)

fig = sphereplot(dsarr; kind = :mesh, varname=:ETOPO1avg)
save("../imgs/sphereplot.png", fig)

fig = mapplot(dsarr; kind=:contour, varname=:ETOPO1avg)
save("../imgs/mapplot_contour.png", fig)

fig = bar3dplot(dsarr; varname=:ETOPO1avg, scalez = 1/100)
save("../imgs/bar3dplot.png", fig)






   