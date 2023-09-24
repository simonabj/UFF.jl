export LinearScan

@kwdef mutable struct LinearScan <: AbstractScan
    x::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    y::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    z::Array{Float32, 1} = Array{Float32, 1}(undef, 0)

    x_axis::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    z_axis::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
end