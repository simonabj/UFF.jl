export ApertureApodization

struct ApodizationData
    data::Matrix{Float32}
end

@kwdef mutable struct ApertureApodization
    probe::Probe = Probe()
    focus::Scan = Scan()
    origin::Point = Point()

    window::Window.WindowType = Window.None
    f_number::Tuple{Float32, Float32} = (1.0f0, 1.0f0)

    MLA::Integer = 1
    MLA_overlap::Integer = 0

    tilt::Tuple{Float32, Float32} = (0.0, 0.0)
    minimum_aperture::Tuple{Float32, Float32} = (1e-3, 1e-3)
    maximum_aperture::Tuple{Float32, Float32} = (10, 10)

    apodization_vector::Vector{Float32} = []
end


Base.propertynames(::ApertureApodization, private::Bool=false) = union(
    fieldnames(ApertureApodization), [:N_elements]
)

## Simple getproperty/setproperty! implementation

function Base.getproperty(a::ApertureApodization, s::Symbol)
    if s in fieldnames(ApertureApodization)
        getfield(a, s)

    elseif s == :N_elements
        return length(a.probe)
    end
end

function Base.setproperty!(a::ApertureApodization, s::Symbol, v)
    if s in fieldnames(ApertureApodization)
        setfield!(a, s, convert(fieldtype(ApertureApodization, s), v))

    elseif s == :N_elements
        error("Cannot set N_elements")
    end
end


# Calculate apodization data

function compute(apod::ApertureApodization)
    if isempty(apod.focus)
        apod.focus = Scan([0], [0], [0])
    end

    if !isempty(apod.apodization_vector)
        if length(apod.apodization_vector) == apod.probe.N_elements
            return ApodizationData(ones(Float32, apod.focus.N_pixels, 1) * apod.apodization_vector')
        else
            return ApodizationData(reshape(apod.apodization_vector, :, 1))
        end
    end

    if apod.window == Window.None
        return ApodizationData(ones(Float32, apod.focus.N_pixels, apod.probe.N_elements))
    
    # STA apodization (Use the closest to user set origin)
    elseif apod.window == Window.Sta
        dist = mapslices(norm,apod.probe.xyz .- apod.origin.xyz', dims=2)
        return ApodizationData(ones(Float32, apod.focus.N_pixels, 1) * (dist ≈ minimum(dist)))
    else
        
    end

    return ApodizationData(ones(Float32, apod.focus.N_pixels, apod.probe.N_elements));
end

function incidence(apod::ApertureApodization)
    # Element locations
    # Each column is a single element
    x = ones(apod.focus.N_pixels, 1) * apod.probe.x'
    y = ones(apod.focus.N_pixels, 1) * apod.probe.y'
    z = ones(apod.focus.N_pixels, 1) * apod.probe.z'

    # If we have a curvilinear array
    if apod.probe isa CurvilinearArray || apod.probe isa CurvilinearMatrixArray
        # The probe class already includes the quantities θ and ϕ which define the
        # element orientation.
        element_azimuth = atan2(x - apod.origin.x, z - apod.origin.z)

        pixel_azimuth = atan2(apod.focus.x - apod.origin.x, apod.focus.z - apod.origin.z)
        pixel_distance = hypot.(apod.focus.x - apod.origin.x, apod.focus.z - apod.origin.z)

        x_dist = apod.origin.z .* (pixel_azimuth .- element_azimuth)
        y_dist = apod.origin.y - y
        z_dist = pixel_distance .* ones(1, apod.probe.N_elements)-a.origin.z
        
        println(x_dist)
        println(y_dist)
        println(z_dist)
    end
end