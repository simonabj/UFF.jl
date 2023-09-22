export Linear3DScan

@kwdef mutable struct Linear3DScan <: AbstractScan
    x::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    y::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    z::Array{Float32, 1} = Array{Float32, 1}(undef, 0)

    radial_axis::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    axial_axis::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    roll::Float32 = 0.0
end