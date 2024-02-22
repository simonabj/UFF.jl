export Probe, LinearArray, CurvilinearArray, MatrixArray, CurvilinearMatrixArray, ProbeType
import Statistics: mean

module ProbeType
@enum T begin
    Basic = 1
    LinearArray = 2
    CurvilinearArray = 3
    MatrixArray = 4
    CurvilinearMatrixArray = 5
end
end

"""
"""
@kwdef mutable struct Probe
    type::ProbeType.T = ProbeType.Basic
    origin::Point = Point()
    geometry::Array{Float32,2} = Array{Float32,2}(undef, 0, 7)
end

Base.propertynames(::Probe, private::Bool=false) = union(
    fieldnames(Probe), collect(keys(_probe_symbol_map)), [:r, :distance]
)

## Define composite scan types
abstract type CompositeProbe end
Base.convert(::Type{Probe}, probe::CompositeProbe) = probe.probe

####################
# Utility functions#
####################

"Return the number of elements in the Probe"
Base.length(p::Probe) = size(p.geometry, 1)
Base.length(p::CompositeProbe) = length(p.probe)

"Forwarded `Base.size` to `Probe.geometry`"
Base.size(p::Probe, args...; kwargs...) = size(p.geometry, args...; kwargs...)
Base.size(p::CompositeProbe, args...; kwargs...) = size(p.probe, args...; kwargs...)

"Forwarded `Base.getindex` to `Probe.geometry`"
Base.getindex(p::Probe, args...; kwargs...) = getindex(p.geometry, args...; kwargs...)
Base.getindex(p::CompositeProbe, args...; kwargs...) = getindex(p.probe, args...; kwargs...)

"Forwarded `Base.setindex!` to `Probe.geometry`"
Base.setindex!(p::Probe, args...; kwargs...) = setindex!(p.geometry, args...; kwargs...)
Base.setindex!(p::CompositeProbe, args...; kwargs...) = setindex!(p.probe, args...; kwargs...)

"""
"""
@kwdef mutable struct LinearArray <: CompositeProbe
    probe::Probe = Probe(; type=ProbeType.LinearArray)

    N::Int64 = 0
    pitch::Float32 = 1.0
    element_width::Float32 = 0.0
    element_height::Float32 = 0.0
end

"""
"""
@kwdef mutable struct CurvilinearArray <: CompositeProbe
    probe::Probe = Probe(; type=ProbeType.CurvilinearArray)

    N::Int = 0
    pitch::Float32 = 1.0
    radius::Float32 = 1.0
    element_width::Float32 = 0.0
    element_height::Float32 = 0.0
end

"""
"""
@kwdef mutable struct MatrixArray <: CompositeProbe
    probe::Probe = Probe(; type=ProbeType.MatrixArray)

    pitch_x::Float32 = 1.0
    pitch_y::Float32 = 1.0
    N_x::Int64 = 0
    N_y::Int64 = 0

    element_width::Float32 = 0.0
    element_height::Float32 = 0.0
end

"""
"""
@kwdef mutable struct CurvilinearMatrixArray <: CompositeProbe
    probe::Probe = Probe(; type=ProbeType.CurvilinearMatrixArray)

    radius_x::Float32 = 1.0
end


####################
# Property names   #
####################


Base.propertynames(::LinearArray, private::Bool=false) = union(
    fieldnames(LinearArray), propertynames(Probe()), []
)
Base.propertynames(::CurvilinearArray, private::Bool=false) = union(
    fieldnames(CurvilinearArray), propertynames(Probe()), []
)
Base.propertynames(::MatrixArray, private::Bool=false) = union(
    fieldnames(MatrixArray), propertynames(Probe()), []
)
Base.propertynames(::CurvilinearMatrixArray, private::Bool=false) = union(
    fieldnames(CurvilinearMatrixArray), propertynames(Probe()), []
)

####################
# Get property     #
####################
const _probe_symbol_map = Dict(
    :x => 1,
    :y => 2,
    :z => 3,
    :xyz => 1:3,
    :θ => 4, :az => 4, :azimuth => 4,
    :ϕ => 5, :alt => 5, :elevation => 5,
    :w => 6, :width => 6,
    :h => 7, :height => 7,
)

function Base.getproperty(probe::Probe, s::Symbol)
    if s in fieldnames(typeof(probe))
        getfield(probe, s)
    elseif s in keys(_probe_symbol_map)
        getindex(probe.geometry, :, _probe_symbol_map[s])
    elseif s == :r || s == :distance
        sqrt.(sum(probe.geometry[:, 1:3] .^ 2, dims=2))[:]
    else
        throw(ArgumentError("No property $s exists in Probe"))
    end
end

function Base.getproperty(probe::CompositeProbe, s::Symbol)
    if s in fieldnames(typeof(probe))
        getfield(probe, s)
    elseif s in propertynames(Probe())
        getproperty(probe.probe, s)
    else
        throw(ArgumentError("No property $s exists in CompositeProbe"))
    end
end

####################
# Set property     #
####################
function Base.setproperty!(probe::Probe, s::Symbol, v)
    if s in fieldnames(typeof(probe))
        setfield!(probe, s, convert(fieldtype(Probe, s), v))
    elseif s in keys(_probe_symbol_map)
        setindex!(probe.geometry, v, :, _probe_symbol_map[s])
    else
        throw(ArgumentError("No property $s exists in Probe"))
    end
end

# By default, we want to update the probe geometry when setting a property
function Base.setproperty!(probe::CompositeProbe, s::Symbol, v)
    set!(probe, s, true, v)
end

# We need this function to control whether or not to update the probe geometry.
function set!(probe::CompositeProbe, s::Symbol, update::Bool, v)
    if s in fieldnames(typeof(probe))
        setfield!(probe, s, convert(fieldtype(typeof(probe), s), v))
        if update
            update!(probe)
        end
    elseif s in propertynames(Probe())
        setproperty!(probe.probe, s, v)
    else
        throw(ArgumentError("No property $s exists in CompositeProbe"))
    end
end

####################
# Update functions #
####################

function update!(probe::LinearArray)
    if probe.element_width == 0.0
        setfield!(probe, :element_width, probe.pitch)
    end
    if probe.element_height == 0.0
        setfield!(probe, :element_height, 10 * probe.pitch)
    end

    x0 = (1:probe.N) .* probe.pitch
    x0 = x0 .- mean(x0)

    probe.probe.geometry = hcat(
        x0,
        zeros(Float32, probe.N, 4), # y, z, θ, ϕ
        probe.element_width .* ones(Float32, probe.N, 1),
        probe.element_height .* ones(Float32, probe.N, 1)
    )
end

function update!(probe::CurvilinearArray)
    if probe.element_width == 0.0
        setfield!(probe, :element_width, probe.pitch)
    end
    if probe.element_height == 0.0
        setfield!(probe, :element_height, 10 * probe.pitch)
    end

    dθ = 2 * asin(probe.pitch / (2 * probe.radius))
    θ = (0:probe.N-1) .* dθ
    θ = θ .- mean(θ)

    x0 = probe.radius .* sin.(θ)
    z0 = probe.radius .* cos.(θ) .- probe.radius

    probe.probe.geometry = hcat(
        x0,
        zeros(Float32, probe.N), # y
        z0,
        θ,
        zeros(Float32, probe.N), # ϕ
        probe.element_width .* ones(Float32, probe.N),
        probe.element_height .* ones(Float32, probe.N)
    )
end

function update!(probe::CompositeProbe)
    throw(ArgumentError("$(typeof(probe)) is not fully implemented"))
end