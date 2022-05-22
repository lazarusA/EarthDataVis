"""
datacubeplot(ds::YAXArray)

Creates a plot as cube. Several options are available via Attributes..

## Attributes
- `kind = :volume`: possible options, volume, contour and voxel
- `xname = :lon`: this should usually be longitude
- `yname = :lat`: this should usually be latitude
- `tname = :time`
- `varname = nothing `: Don't forget to pass your own
- `colormap=:Hiroshige`
- `color=nothing`: voxel colors
- `levels=50`: contour levels
- `axvals=:counts`: axis values by :counts, :vals and :vals_tscale
- `markersize=nothing`
- `shading=false`
- `transparency=false`
"""
@recipe(DataCubePlot, yaxarray) do scene
    #=
    Theme(
        Axis3=(
            zlabelrotation=0π,
            xlabeloffset=50,
            ylabeloffset=55,
            zlabeloffset=70,
            xgridcolor=(:black, 0.07),
            ygridcolor=(:black, 0.07),
            zgridcolor=(:black, 0.07),
            perspectiveness=0.5f0,
            azimuth=1.275π * 1.77,
        )
    )
    =# 
    Attributes(;
        kind=:volume,
        xname=:lon,
        yname=:lat,
        tname=:time,
        varname=nothing,
        colormap=:Hiroshige,
        color=nothing,
        levels=50,
        axvals=:counts, # be careful with your axis values, :vals is the only one showing the original data
        markersize=nothing,
        shading=false,
        transparency=false,
    )
end

function Makie.plot!(p::DataCubePlot{<:Tuple{<:YAXArray}})
    dset = p[:yaxarray]
    xname = p[:xname][]
    yname = p[:yname][]
    tname = p[:tname][]
    varname = p[:varname][]
    varname = isnothing(varname) ? @lift(first($dset.Variable.values)) : varname
    sx = @lift(size(getproperty($dset, xname), 1))
    sy = @lift(size(getproperty($dset, yname), 1))
    st = @lift(size(getproperty($dset, tname), 1))
    if p[:axvals][] == :counts
        y = @lift(1:$sx)
        z = @lift(1:$sy)
        t = @lift(1:$st)
    elseif p[:axvals][] == :vals
        y = @lift(getproperty($dset, xname).values)
        z = @lift(getproperty($dset, yname).values)
        t = @lift(1:size(getproperty($dset, tname),1))
    elseif p[:axvals][] == :vals_tscale
        y = @lift(getproperty($dset, xname).values)
        z = @lift(getproperty($dset, yname).values)
        t = @lift(range(1, max(last($y), last($z)), length=size(getproperty($dset, tname),1)))
    else
        error("not a known data method for your axis")
    end
    d = @lift($dset[variable=String($varname)].data[:, :, :])
    ms = @lift(Vec3f($t[2] - $t[1], $y[2] - $y[1], $z[2] - $z[1]))

    if p[:kind][] == :contour
        contour!(p, t, y, z, d; colormap=p.colormap[], levels=p.levels[],
            shading=p.shading[],
            transparency=p.transparency[]
        )
    elseif p[:kind][] == :volume
        volume!(p, t, y, z, d; colormap=p.colormap[])
    elseif p[:kind][] == :voxel
        ps = @lift([Point3f(i, j, k) for i in $t, j in $y for k in $z])
        meshscatter!(p, ps; color=isnothing(p.color[]) ? @lift(vec($d)) : p.color[],
            colormap=p.colormap[],
            marker=Rect3f(Vec3f(-0.5), Vec3f(1)),
            markersize=isnothing(p.markersize[]) ? ms : p.markersize[],
            shading=p.shading[],
            transparency=p.transparency[]
        )
    end
    return p
end