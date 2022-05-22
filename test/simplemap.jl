using EarthDataPlots
using GLMakie, YAXArrays, Dates, NetCDF
using Colors

dsarr = Cube("./data/ETOPO1_halfdegree.nc")
heatmap(dsarr.lon.values, dsarr.lat.values,
    dsarr[variable="ETOPO1avg"].data[:,:])
mapplot(dsarr)
sphereplot(dsarr; kind = :mesh, varname=:ETOPO1avg)
mapplot(dsarr; kind=:contour, varname=:ETOPO1avg)
