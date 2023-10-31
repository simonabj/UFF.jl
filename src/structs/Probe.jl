export Probe, AbstractProbe

abstract type AbstractProbe end

@kwdef mutable struct Probe <: AbstractProbe
    origin::Point = Point()
    geometry::Array{Float32, 2} = Array{Float32, 2}(undef, 0, 7)
end


"Return the number of elements in the Probe"
Base.length(p::Probe) = size(p.geometry, 1)

"Forwarded `Base.size` to `Probe.geometry`"
Base.size(p::Probe, args...; kwargs...) = size(p.geometry, args...; kwargs...)

"Forwarded `Base.getindex` to `Probe.geometry`"
Base.getindex(p::Probe, args...; kwargs...) = getindex(p.geometry, args...; kwargs...)

"Forwarded `Base.setindex!` to `Probe.geometry`"
Base.setindex!(p::Probe, args...; kwargs...) = setindex!(p.geometry, args...; kwargs...)

const _probe_symbol_map = Dict(
    :x => 1,
    :y => 2,
    :z => 3,
    :θ => 4, :az => 4, :azimuth => 4,
    :ϕ => 5, :alt => 5, :elevation => 5,
    :w => 6, :width => 6,
    :h => 7, :height => 7,
)

"Implement the property interface for the same variables used by MATLAB"
Base.propertynames(::Probe, private::Bool=false) = union(collect(keys(_probe_symbol_map)), [:r, :xyz, :N_elements], fieldnames(Probe))

"""
    Base.getproperty(p::Probe, s::Symbol)

```
:x                    = p.geometry[:, 1]  # center of the element in the x axis[m]
:y                    = p.geometry[:, 2]  # center of the element in the y axis[m]
:z                    = p.geometry[:, 3]  # center of the element in the z axis[m]
:θ [:az, :azimuth]    = p.geometry[:, 4]  # orientation of the element in the azimuth direction [rad]
:ϕ [:alt, :elevation] = p.geometry[:, 5]  # orientation of the element in the elevation direction [rad]
:w [:width]           = p.geometry[:, 6]  # element width [m]
:h [:height]          = p.geometry[:, 7]  # element height [m]
:r [:distance]        = norm(p.geometry[:,1:3], dims=2) # Distance from elements to origin [m] 
:N_elements           = Analogous to length(p::Probe)
```
"""
function Base.getproperty(p::Probe, s::Symbol)
    if s ∈ fieldnames(Probe)
        getfield(p, s)
    elseif s ∈ keys(_probe_symbol_map)
        p.geometry[:, _probe_symbol_map[s]]
    elseif s == :r || s == :distance
        mapslices(norm, p.geometry[:, 1:3], dims=2)
    elseif s == :xyz
        p.geometry[:, 1:3]
    elseif s == :N_elements
        length(p)
    else
        error("Symbol '$s' is not a valid property of Probe")
    end
end

"Set property function"
function Base.setproperty!(p::Probe, s::Symbol, value)
    if s in fieldnames(Probe)
        setfield!(p, s, convert(fieldtype(Probe, s), value))
    elseif s ∈ keys(_probe_symbol_map)
        p.geometry[:, _probe_symbol_map[s]] = value
    else
        error("Symbol '$s' is not a valid property of Probe")
    end
end

