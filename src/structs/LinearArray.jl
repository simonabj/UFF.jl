export LinearArray

@kwdef mutable struct LinearArray <: AbstractProbe
    origin::Point = Point()
    geometry::Array{Float64, 2} = Array{Float64, 2}(undef, 0, 7)

    N::Int64 = 0
    pitch::Float64 = 0.0
    element_width::Float64 = 0.0
    element_height::Float64 = 0.0
end