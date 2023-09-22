export Scan, AbstractScan

abstract type AbstractScan end

#=
    properties  (Access = public)
        x                  % Vector containing the x coordinate of each pixel in the matrix
        y                  % Vector containing the x coordinate of each pixel in the matrix
        z                  % Vector containing the z coordinate of each pixel in the matrix
    end
    
    properties  (Dependent)
        N_pixels           % total number of pixels in the matrix
        xyz                % location of the source [m m m] if the source is not at infinity    
    end
=#

@kwdef mutable struct Scan <: AbstractScan
    x::Array{Float64, 1} = Array{Float64, 1}(undef, 0)
    y::Array{Float64, 1} = Array{Float64, 1}(undef, 0)
    z::Array{Float64, 1} = Array{Float64, 1}(undef, 0)
end
