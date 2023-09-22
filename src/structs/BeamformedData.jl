export BeamformedData

@kwdef mutable struct BeamformedData
    header::UFFHeader = UFFHeader()

    scan::Scan = LinearScan()
    data::Array{Float64, 4} = Array{Float64, 4}(undef, 0, 0, 0, 0)

    phantom::Phantom = Phantom()
    sequence::Array{Wave, 1} = Array{Wave, 1}(undef, 0)
    probe::Probe = LinearArray()
    pulse::Pulse = Pulse()
    sampling_frequency::Float64 = 0.0
    modulation_frequency::Float64 = 0.0
    frame_rate::Float64 = 1.0
end