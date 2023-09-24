export SectorScan

#=
    properties  (Access = public)
        azimuth_axis                % Vector containing the azimuth coordinates [rad]
        depth_axis                  % Vector containing the distance coordinates [m]
        origin                      % Vector of UFF.POINT objects
    end
=#

@kwdef mutable struct SectorScan <: AbstractScan
    x::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    y::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    z::Array{Float32, 1} = Array{Float32, 1}(undef, 0)

    origin::Vector{Point} = []
    depth_axis::Vector{Float32} = []
    azimuth_axis::Vector{Float32} = []
end