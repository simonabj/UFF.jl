export MatrixArray

#=
    %   Compulsory properties
    %     properties  (SetAccess = public)
    %         pitch_x        % distance between the elements in the azimuth direction [m]
    %         pitch_y        % distance between the elements in the elevation direction [m]
    %         N_x            % number of elements in the azimuth direction
    %         N_y            % number of elements in the elevation direction
    %     end
    % 
    %  Optional properties
    %     properties  (SetAccess = public)
    %         element_width  % width of the elements in the azimuth direction [m]
    %         element_height % height of the elements in the elevation direction [m]
    %     end
=#

@kwdef mutable struct MatrixArray <: AbstractProbe
    origin::Point = Point()
    geometry::Array{Float32, 2} = Array{Float32, 2}(undef, 0, 7)

    pitch_x::Float32 = 0.0
    pitch_y::Float32 = 0.0
    N_x::Int64 = 0
    N_y::Int64 = 0

    element_width::Float32 = 0.0
    element_height::Float32 = 0.0
end