export BeamformedData

@kwdef mutable struct BeamformedData
    header::UFFHeader = UFFHeader()

    scan::Scan = LinearScan()
    data::Array{Float32, 4} = Array{Float32, 4}(undef, 0, 0, 0, 0)

    phantom::Phantom = Phantom()
    sequence::Array{Wave, 1} = Array{Wave, 1}(undef, 0)
    probe::Probe = LinearArray()
    pulse::Pulse = Pulse()
    sampling_frequency::Float32 = 0.0
    modulation_frequency::Float32 = 0.0
    frame_rate::Float32 = 1.0
end