import LinearAlgebra: norm
import ArgCheck: @argcheck

export Wave

@kwdef mutable struct Wave
    wavefront::Wavefront.WavefrontType = Wavefront.Plane
    source::Point = Point()
    origin::Point = Point()
    apodization::ApertureApodization = ApertureApodization()

    probe::Probe = Probe()
    event::Integer = -1
    delay::Float32 = 0.0
    sound_speed::Float32 = 1540.0
end

# dependent properties = (N_elements, delay_values, apodization_values, t0_origin)

Base.propertynames(::Wave, private::Bool=false) = union(
    fieldnames(Wave), [:N_elements, :delay_values, :apodization_values, :t0_origin]
)

function Base.getproperty(w::Wave, s::Symbol)
    if s in fieldnames(Wave)
        getfield(w, s)

    elseif s == :N_elements
        return length(w.probe)

    elseif s == :t0_origin
        if w.source.z < 0
            return -norm(w.source.xyz) + norm(w.source.xyz .- w.origin.xyz)
        else
            return norm(w.source.xyz) - norm(w.source.xyz .- w.origin.xyz)
        end
    
    elseif s == :delay_values
        @argcheck w.sound_speed > 0.0 "sound_speed must be positive"
        @argcheck length(w.probe) > 0 "probe must have at least one element"

        source_origin_dist = norm(w.source.xyz .- w.origin.xyz)
        if isinf(source_origin_dist)
            return (w.probe.x-w.origin.x)sin(w.source.azimuth) / w.sound_speed + (w.probe.y - w.origin.y)sin(w.source.elevation) / w.sound_speed
        end

        dst = map(norm, eachslice(w.probe.xyz .- w.source.xyz', dims=1))
        if w.source.z < 0
            return dst / w.sound_speed .- abs(source_origin_dist/w.sound_speed)
        else
            return (source_origin_dist' .- dst) / w.sound_speed
        end
    
    elseif s == :apodization_values
        if isempty(w.apodization.apodization_vector)
            return ones(Float32, length(w.probe))
        else
            return w.apodization.apodization_vector
        end
    end
end