# Introduction

Since EarthDataPlots requires YAXArrays and GLMakie, we also install those and start using them as follows:

```julia
using EarthDataPlots, GLMakie, YAXArrays, Dates
```

First, let's start by creating some test data for EDP.

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

Then using `datacubeplot` will generate a cube for one of the variables in `dsarr`. Note that different options are available. We will take a look at one of them.

```@docs
datacubeplot(ds::YAXArray)
```
