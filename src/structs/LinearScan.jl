export LinearScan

@kwdef mutable struct LinearScan <: AbstractScan
    x::Array{Float64, 1} = Array{Float64, 1}(undef, 0)
    y::Array{Float64, 1} = Array{Float64, 1}(undef, 0)
    z::Array{Float64, 1} = Array{Float64, 1}(undef, 0)

    x_axis::Array{Float64, 1} = Array{Float64, 1}(undef, 0)
    z_axis::Array{Float64, 1} = Array{Float64, 1}(undef, 0)
end