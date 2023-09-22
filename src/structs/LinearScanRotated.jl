export LinearScanRotated

@kwdef mutable struct LinearScanRotated <: AbstractScan
    x::Array{Float64, 1} = Array{Float64, 1}(undef, 0)
    y::Array{Float64, 1} = Array{Float64, 1}(undef, 0)
    z::Array{Float64, 1} = Array{Float64, 1}(undef, 0)

    x_axis::Array{Float64, 1} = Array{Float64, 1}(undef, 0)
    z_axis::Array{Float64, 1} = Array{Float64, 1}(undef, 0)
    rotation_angle::Float64 = 0.0
    center_of_rotation::Point = Point()
end