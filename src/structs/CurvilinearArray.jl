export CurvilinearArray

@kwdef mutable struct CurvilinearArray <: AbstractProbe
    origin::Point = Point()
    geometry::Array{Float32, 2} = Array{Float32, 2}(undef, 0, 7)

    N::Int = 0
    pitch::Float32 = 0.0
    radius::Float32 = 0.0
    element_width::Float32 = 0.0
    element_height::Float32 = 0.0
end