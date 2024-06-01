export ChannelData

@kwdef mutable struct ChannelData
    header::UFFHeader = UFFHeader()

    sampling_frequency::Float32 = 0.0
    initial_time::Float32 = 0.0
    sound_speed::Float32 = 1540.0
    modulation_frequency::Float32 = 0.0
    sequence::Array{Wave, 1} = Array{Wave, 1}(undef, 0)
    probe::Union{Probe, CompositeProbe} = Probe()
    data::Array{Float32, 4} = Array{Float32, 4}(undef, 0, 0, 0, 0)
    PRF::Float32 = 0.0
    pulse::Pulse = Pulse()
    phantom::Phantom = Phantom()
    N_active_elements::Int64 = 0

end