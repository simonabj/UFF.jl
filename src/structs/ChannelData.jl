export ChannelData

@kwdef mutable struct ChannelData
    sampling_frequency::Float64 = 0.0
    initial_time::Float64 = 0.0
    sound_speed::Float64 = 1540.0
    modulation_frequency::Float64 = 0.0
    sequence::Array{Wave, 1} = Array{Wave, 1}(undef, 0)
    probe::Probe = LinearArray()
    data::Array{Float64, 4} = Array{Float64, 4}(undef, 0, 0, 0, 0)
    PRF::Float64 = 0.0
    pulse::Pulse = Pulse()
    phantom::Phantom = Phantom()
    N_active_elements::Int64 = 0
end