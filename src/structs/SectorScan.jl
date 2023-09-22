export SectorScan

#=
    properties  (Access = public)
        azimuth_axis                % Vector containing the azimuth coordinates [rad]
        depth_axis                  % Vector containing the distance coordinates [m]
        origin                      % Vector of UFF.POINT objects
    end
=#

@kwdef mutable struct SectorScan <: AbstractScan
    x::Array{Float64, 1} = Array{Float64, 1}(undef, 0)
    y::Array{Float64, 1} = Array{Float64, 1}(undef, 0)
    z::Array{Float64, 1} = Array{Float64, 1}(undef, 0)

    origin::Vector{Point} = []
    depth_axis::Vector{Float64} = []
    azimuth_axis::Vector{Float64} = []
end