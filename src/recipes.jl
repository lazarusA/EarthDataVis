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
        transparency=false
    )
end

function Makie.plot!(p::DataCubePlot{<:Tuple{<:YAXArray}})
    dset = p[:yaxarray]
    xname = p[:xname][]
    yname = p[:yname][]
    tname = p[:tname][]
    varname = isnothing(p[:varname][]) ? @lift(first($dset.Variable.values)) : p[:varname]
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
        t = @lift(1:size(getproperty($dset, tname), 1))
    elseif p[:axvals][] == :vals_tscale
        y = @lift(getproperty($dset, xname).values)
        z = @lift(getproperty($dset, yname).values)
        t = @lift(range(1, max(last($y), last($z)), length=size(getproperty($dset, tname), 1)))
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
        colorvals = @lift([$d[i, j, k] for (i, _) in enumerate($t) for (j, _) in enumerate($y) for (k, _) in enumerate($z)])
        meshscatter!(p, ps; color=isnothing(p.color[]) ? colorvals : p.color[],
            colormap=p.colormap[],
            marker=Rect3f(Vec3f(-0.5), Vec3f(1)),
            markersize=isnothing(p.markersize[]) ? ms : p.markersize[],
            shading=p.shading[],
            transparency=p.transparency[]
        )
    end
    return p
end

"""
mapplot(ds::YAXArray)

Creates a map plot. Several options are available via Attributes..

## Attributes
- `kind = :heatmap`: possible options, heatmap, scatter and contour
- `xname = :lon`: this should usually be longitude
- `yname = :lat`: this should usually be latitude
- `timeindex = "xxxx-xx-xx`: Date format, i.e., "2002-01-29"
- `varname = nothing `: Don't forget to pass your own
- `colormap=:Hiroshige`
- `color=nothing`: voxel colors
- `levels=25`: contour levels
- `markersize=nothing`
- `shading=false`
- `transparency=false`
"""
@recipe(MapPlot, yaxarray) do scene
    Attributes(;
        kind=:heatmap,
        xname=:lon,
        yname=:lat,
        timestep=nothing,
        varname=nothing,
        colormap=:Hiroshige,
        color=nothing,
        levels=100,
        markersize=nothing,
        shading=false,
        transparency=false,
        interpolate=false,
        mspace=:data # markerspace
    )
end
function Makie.plot!(p::MapPlot{<:Tuple{<:YAXArray}})
    dset = p[:yaxarray]
    xname = p[:xname][]
    yname = p[:yname][]
    varname = isnothing(p[:varname][]) ? @lift(first($dset.Variable.values)) : p[:varname]

    y = @lift(getproperty($dset, xname).values)
    z = @lift(getproperty($dset, yname).values)
    if :time in propertynames(dset)
        timestep = isnothing(p[:timestep]) ? @lift(first($dset.time.values)) : p[:timestep]
        d = @lift($dset[time=Date($timestep), variable=String($varname)].data[:, :])
    else
        d = @lift(replace($dset[variable=String($varname)].data[:, :], missing => NaN))
    end
    ms = @lift(Vec2f($y[2] - $y[1], $z[2] - $z[1]))

    if p[:kind][] == :heatmap
        heatmap!(p, y, z, d; colormap=p.colormap[],
            transparency=p.transparency[], interpolate=p.interpolate[]
        )
    elseif p[:kind][] == :contour
        contour!(p, y, z, d; colormap=p.colormap[], level=p.levels[])
    elseif p[:kind][] == :scatter
        ps = @lift([Point2f(j, k) for j in $y for k in $z])
        colorvals = @lift([$d[i, j] for (i, _) in enumerate($y) for (j, _) in enumerate($z)])
        scatter!(p, ps; color=isnothing(p.color[]) ? colorvals : p.color[],
            colormap=p.colormap[],
            markerspace=p.mspace[],
            marker=Rect2f(Vec2f(-0.5), Vec2f(1)),
            markersize=isnothing(p.markersize[]) ? ms : p.markersize[],
            transparency=p.transparency[])
    end
    return p
end

"""
sphereplot(ds::YAXArray)

Creates a map plot. Several options are available via Attributes..

## Attributes
- `kind = :mesh`: possible options, surface, meshscatter and maybe mesh?
- `xname = :lon`: this should usually be longitude
- `yname = :lat`: this should usually be latitude
- `timeindex = "xxxx-xx-xx`: Date format, i.e., "2002-01-29"
- `varname = nothing `: Don't forget to pass your own
- `colormap=:Hiroshige`
- `color=nothing`: voxel colors
- `markersize=nothing`
- `shading=false`
- `transparency=false`
- `omesh = Point3f(0)`: origin mesh sphere
- `radius = 1`: Sphere radius
- `tess = 64`: Sphere Tesselation
"""
@recipe(SpherePlot, yaxarray) do scene
    Attributes(;
        kind=:mesh,
        xname=:lon,
        yname=:lat,
        timestep=nothing,
        varname=nothing,
        colormap=:Hiroshige,
        color=nothing,
        markersize=nothing,
        shading=false,
        transparency=false,
        omesh=Point3f(0),
        radius=1,
        tess=64
    )
end
function toCartesian(lon, lat; r=1, cxyz=(0, 0, 0))
    x = cxyz[1] + r * cosd(lat) * cosd(lon)
    y = cxyz[2] + r * cosd(lat) * sind(lon)
    z = cxyz[3] + r * sind(lat)
    return (x, y, z)
end
function lonlat3D(lon, lat, data; cxyz=(0, 0, 0))
    xyzw = zeros(size(data)..., 3)
    for (i, lon) in enumerate(lon), (j, lat) in enumerate(lat)
        x, y, z = toCartesian(lon, lat; cxyz=cxyz)
        xyzw[i, j, 1] = x
        xyzw[i, j, 2] = y
        xyzw[i, j, 3] = z
    end
    return xyzw
end
function SphereTess(; o=Point3f(0), r=1, tess=64)
    return uv_normal_mesh(Tesselation(Sphere(o, r), tess))
end
function Makie.plot!(p::SpherePlot{<:Tuple{<:YAXArray}})
    dset = p[:yaxarray]
    xname = p[:xname][]
    yname = p[:yname][]
    varname = isnothing(p[:varname][]) ? @lift(first($dset.Variable.values)) : p[:varname]

    lon = @lift(getproperty($dset, xname).values)
    lat = @lift(getproperty($dset, yname).values)
    if :time in propertynames(dset)
        timestep = isnothing(p[:timestep]) ? @lift(first($dset.time.values)) : p[:timestep]
        d = @lift($dset[time=Date($timestep), variable=String($varname)].data[:, :])
    else
        d = @lift(replace($dset[variable=String($varname)].data[:, :], missing => NaN))
    end

    if p[:kind][] == :surface
        lonext = @lift(vcat(collect($lon), $lon[1]))
        dext = @lift([$d; $d[1, :]'])
        xyz = lift(lonext, lat, dext) do lonext, lat, dext
            lonlat3D(lonext, lat, dext)
        end
        surface!(p, @lift($xyz[:, :, 1]), @lift($xyz[:, :, 2]), @lift($xyz[:, :, 3]);
            color=dext, colormap=p.colormap[],
            transparency=p.transparency[],
            shading=p.shading[])
    elseif p[:kind][] == :mesh
        mesh!(p, SphereTess(; o=p.omesh[], r=p.radius[], tess=p.tess[]);
            color=@lift(transpose($d)), colormap=p.colormap[],
            transparency=p.transparency[],
            shading=p.shading[])
    end
    return p
end

"""
namesplot(ds::YAXArray)

Creates a map plot. Several options are available via Attributes..

## Attributes
- `kind = :tree`: possible options, surface, meshscatter and maybe mesh?
- `colormap=:Hiroshige`
- `color=nothing`: voxel colors
- `markersize=nothing`
- `transparency=false`
"""
@recipe(NamesPlot, yaxarray) do scene
    Attributes(;
        kind=:tree,
        colormap=:Hiroshige,
        color=nothing,
        markersize=nothing,
        transparency=false,
    )
end
function Makie.plot!(p::NamesPlot{<:Tuple{<:YAXArray}})
    dset = p[:yaxarray]
    allnames = YAXArrayBase.dimnames(dset[])
    s = length(allnames)
    text!(p, [String.(allnames)...], position=@.(Point2f(1:s, 0)),
        align = (:center, :center), color = rand(RGB, s))
end