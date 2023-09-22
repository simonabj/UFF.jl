export Wave

@kwdef mutable struct Wave
    wavefront::Wavefront.WavefrontType = Wavefront.PLANE
    source::Point = Point()
    apodization::ApertureApodization = ApertureApodization()
end