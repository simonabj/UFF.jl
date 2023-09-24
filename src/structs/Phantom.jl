export Phantom

@kwdef mutable struct Phantom
    header::UFFHeader = UFFHeader()

    points::Array{Float32, 2} = Array{Float32, 2}(undef, 0, 4)
    time::Float32 = 0.0
    sound_speed::Float32 = 0.0
    density::Float32 = 0.0
    alpha::Float32 = 0.0
end