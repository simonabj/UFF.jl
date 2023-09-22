export CurvilinearMatrixArray

@kwdef mutable struct CurvilinearMatrixArray <: AbstractProbe
    origin::Point = Point()
    geometry::Array{Float64, 2} = Array{Float64, 2}(undef, 0, 7)

    radius_x::Float64 = 0.0
end