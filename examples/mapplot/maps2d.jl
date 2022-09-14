## Single line 

using EarthDataVis
using GLMakie, YAXArrays
using CairoMakie
CairoMakie.activate!(type = "svg") #hide
## a .nc file in your data folder
scatter(1:10)