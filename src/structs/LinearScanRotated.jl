export LinearScanRotated

@kwdef mutable struct LinearScanRotated <: AbstractScan
    x::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    y::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    z::Array{Float32, 1} = Array{Float32, 1}(undef, 0)

    x_axis::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    z_axis::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    rotation_angle::Float32 = 0.0
    center_of_rotation::Point = Point()
end