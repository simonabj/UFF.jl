export Phantom


@kwdef mutable struct Phantom
    points::Array{Float64, 2} = Array{Float64, 2}(undef, 0, 4)
    time::Float64 = 0.0
    sound_speed::Float64 = 0.0
    density::Float64 = 0.0
    alpha::Float64 = 0.0
end