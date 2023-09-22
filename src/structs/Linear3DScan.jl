export Linear3DScan

@kwdef mutable struct Linear3DScan <: AbstractScan
    x::Array{Float64, 1} = Array{Float64, 1}(undef, 0)
    y::Array{Float64, 1} = Array{Float64, 1}(undef, 0)
    z::Array{Float64, 1} = Array{Float64, 1}(undef, 0)

    radial_axis::Array{Float64, 1} = Array{Float64, 1}(undef, 0)
    axial_axis::Array{Float64, 1} = Array{Float64, 1}(undef, 0)
    roll::Float64 = 0.0
end