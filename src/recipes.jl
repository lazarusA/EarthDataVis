"""
datacubeplot(ds::YAXArray)
datacubeplot!(ds::YAXArray)

Creates a plot as cube. Several options are available via Attributes..

## Attributes
- `xname = :lon`: this should usually be longitude
- `yname = :lat`: this should usually be latitude
- `tname = :time`
- `varname = nothing `: Don't forget to pass your own
"""
@recipe(DataCubePlot, yaxarray) do scene
    Attributes(;
        kind = :volume,
        # possible options, volume, contour and voxel
        xname=:lon,
        yname=:lat,
        tname=:time,
        varname=nothing,
        colormap=:Hiroshige,
        color = nothing,
        levels = 50,
    )
end

function Makie.plot!(dcp::DataCubePlot{<:Tuple{<:YAXArray}})
    dset = dcp[:yaxarray]
    xname = dcp[:xname][]
    yname = dcp[:yname][]
    tname = dcp[:tname][]
    varname = dcp[:varname][]
    varname = isnothing(varname) ? @lift(first($dset.Variable.values)) : varname
    y = @lift(1:size(getproperty($dset, xname), 1))
    z = @lift(1:size(getproperty($dset, yname), 1))
    t = @lift(1:size(getproperty($dset, tname), 1))
    d = @lift($dset[variable=String($varname)].data[:, :, :])
    if dcp[:kind][] == :contour
        contour!(dcp, t, y, z, d; colormap=dcp.colormap[], levels = dcp.levels[])
    elseif dcp[:kind][] == :volume
        volume!(dcp, t, y, z, d; colormap=dcp.colormap[])
    elseif dcp[:kind][] == :voxel
        ps = @lift([Point3f(i,j,k) for i in $t, j in $y for k in $z])
        meshscatter!(dcp, ps; color= isnothing(dcp.color[]) ? @lift(vec($d)) : dcp.color[],
            colormap=dcp.colormap[],
            marker = Rect3f(Vec3f(-0.5), Vec3f(1)),
            markersize = 1, # this needs to be calculated dynamically from t,y,z.
            )
    end
    return dcp
end