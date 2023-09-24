export Wave

@kwdef mutable struct Wave
    wavefront::Wavefront.WavefrontType = Wavefront.Plane
    source::Point = Point()
    origin::Point = Point()
    apodization::ApertureApodization = ApertureApodization()

    probe::AbstractProbe = Probe()
    event::Integer = -1
    delay::Float32 = 0.0
    sound_speed::Float32 = 1540.0
end