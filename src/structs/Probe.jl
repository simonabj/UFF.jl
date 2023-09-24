export Point, AbstractProbe

abstract type AbstractProbe end

@kwdef mutable struct Probe <: AbstractProbe
    origin::Point = Point()
    geometry::Array{Float32, 2} = Array{Float32, 2}(undef, 0, 7)
end