export Probe, LinearArray, CurvilinearArray, MatrixArray, CurvilinearMatrixArray

"""
"""
@kwdef mutable struct Probe
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


## Define composite scan types
abstract type CompositeProbe end
Base.convert(::Type{Probe}, scan::CompositeProbe) = probe.probe

"""
"""
@kwdef mutable struct LinearArray <: CompositeProbe
    probe::Probe = Probe()

    N::Int64 = 0
    pitch::Float32 = 0.0
    element_width::Float32 = 0.0
    element_height::Float32 = 0.0
end

@kwdef mutable struct CurvilinearArray <: CompositeProbe
    probe::Probe = Probe()

    N::Int = 0
    pitch::Float32 = 0.0
    radius::Float32 = 0.0
    element_width::Float32 = 0.0
    element_height::Float32 = 0.0
end

@kwdef mutable struct MatrixArray <: CompositeProbe
    probe::Probe = Probe()

    pitch_x::Float32 = 0.0
    pitch_y::Float32 = 0.0
    N_x::Int64 = 0
    N_y::Int64 = 0

    element_width::Float32 = 0.0
    element_height::Float32 = 0.0
end

@kwdef mutable struct CurvilinearMatrixArray <: CompositeProbe
    probe::Probe = Probe()

    radius_x::Float32 = 0.0
end

####################

Base.propertynames(::Probe, private::Bool = false) = union(
    fieldnames(Probe), [:N_pixels, :xyz]
)
Base.propertynames(::LinearArray, private::Bool = false) = union(
    fieldnames(LinearArray), propertynames(Probe()) , []
)
Base.propertynames(::CurvilinearArray, private::Bool = false) = union(
    fieldnames(CurvilinearArray), propertynames(Probe()), []
)
Base.propertynames(::MatrixArray, private::Bool = false) = union(
    fieldnames(MatrixArray), propertynames(Probe()), []
)
Base.propertynames(::CurvilinearMatrixArray, private::Bool = false) = union(
    fieldnames(CurvilinearMatrixArray), propertynames(Probe()), []
)


