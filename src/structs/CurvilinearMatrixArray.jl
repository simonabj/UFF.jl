export CurvilinearMatrixArray

@kwdef mutable struct CurvilinearMatrixArray <: AbstractProbe
    origin::Point = Point()
    geometry::Array{Float32, 2} = Array{Float32, 2}(undef, 0, 7)

    radius_x::Float32 = 0.0
end