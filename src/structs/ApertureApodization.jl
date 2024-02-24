import Rotations: RotX, RotY

export ApertureApodization, compute

@kwdef mutable struct ApertureApodization
    probe::Probe = Probe()
    focus::Scan = Scan()
    origin::Point = Point()

    window::Window.WindowType = Window.None
    f_number::Vector{Float32} = [1.0f0, 1.0f0]

    MLA::Integer = 1
    MLA_overlap::Integer = 0

    tilt::Vector{Float32} = [0.0, 0.0]
    minimum_aperture::Vector{Float32} = [1e-3, 1e-3]
    maximum_aperture::Vector{Float32} = [10, 10]

    apodization_vector::Matrix{Float32} = Matrix{Float32}(undef, 0, 0)
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


# Calculate apodization values
"""
    compute(apo::ApertureApodization)
    
Calculate the apodization values for a given aperture apodization.

The apodization values are calculated based on the type of apodization.
For scanline/STA apodization, the apodization values are calculated based on the distance

"""
function compute(apod::ApertureApodization)
    if isempty(apod.focus)
        apod.focus = Scan([0], [0], [0])
    end

    # Check if the apodization vector is set. If it is, we use it directly and return
    if !isempty(apod.apodization_vector)
        if length(apod.apodization_vector) == apod.probe.N
            return ones(Float32, apod.focus.N_pixels, 1) * apod.apodization_vector'
        else
            return reshape(apod.apodization_vector, :, 1)
        end
    end

    # If no window is set, we return a simple ones matrix
    if apod.window == Window.None
        return ones(Float32, apod.focus.N_pixels, length(apod.probe))

    # STA apodization (Use the closest element to user set origin)
    elseif apod.window == Window.Sta
        dist = mapslices(norm, apod.probe.xyz .- apod.origin.xyz', dims=2)
        return ones(Float32, apod.focus.N_pixels, 1) * (dist ≈ minimum(dist))
    else
        tan_theta, tan_phi = incidence(apod)

        ratio_theta = abs.(apod.f_number[1] * tan_theta)
        ratio_phi = abs.(apod.f_number[2] * tan_phi)
        
        return apod.window(ratio_theta, ratio_phi)
        
    end

    return ones(Float32, apod.focus.N_pixels, apod.probe.N_elements)
end

function incidence(apod::ApertureApodization)
    # Element locations
    # Each column is a single element.
    # Each row is a flattened single pixel in the focus region (scan)
    x = ones(Float32, apod.focus.N_pixels, 1) * apod.probe.x'
    y = ones(Float32, apod.focus.N_pixels, 1) * apod.probe.y'
    z = ones(Float32, apod.focus.N_pixels, 1) * apod.probe.z'

    # If we have a curvilinear array
    if apod.probe.type == ProbeType.CurvilinearArray || apod.probe.type == ProbeType.CurvilinearMatrixArray 
        # The probe class already includes the quantities θ and ϕ which define the
        # element orientation.
        element_azimuth = atan2(x .- apod.origin.x, z .- apod.origin.z)

        pixel_azimuth = atan2(apod.focus.x - apod.origin.x, apod.focus.z - apod.origin.z)
        pixel_distance = hypot.(apod.focus.x - apod.origin.x, apod.focus.z - apod.origin.z)

        x_dist = apod.origin.z .* (pixel_azimuth .- element_azimuth)
        y_dist = apod.origin.y - y
        z_dist = pixel_distance .* ones(1, apod.probe.N_elements) - a.origin.z

    elseif apod.focus.type == ScanType.SectorScan
    
        pixel_distance = hypot.(
            apod.focus.x .- apod.origin.x,
            apod.focus.y .- apod.origin.y,
            apod.focus.z .- apod.origin.z
        )

        x_dist = x .- apod.origin.x
        y_dist = y .- apod.origin.y
        z_dist = pixel_distance .* ones(1, apod.probe.N_elements)

    else
        # If not, we have a flat probe and a linear scan. In this case
        # the aperture is centered at each beam's x coordinate

        x_dist = apod.focus.x .- x
        y_dist = apod.focus.y .- y
        z_dist = apod.focus.z .- z
    end

    # negative rotY because of the way spherical coordinates are defined. See Point.jl
    rotation_matrix = RotY(-apod.tilt[1]) * RotX(apod.tilt[2])

    x_dist, y_dist, z_dist = eachslice(rotation_matrix * [x_dist[:] y_dist[:] z_dist[:]]', dims=1)

    x_dist = reshape(x_dist, size(x))
    y_dist = reshape(y_dist, size(y))
    z_dist = reshape(z_dist, size(z))

    zx_dist = zy_dist = z_dist

    mask_minimum_x = abs.(z_dist) .<= apod.minimum_aperture[1] * apod.f_number[1]
    mask_minimum_y = abs.(z_dist) .<= apod.minimum_aperture[2] * apod.f_number[2]

    mask_maximum_x = abs.(z_dist) .>= apod.maximum_aperture[1] * apod.f_number[1]
    mask_maximum_y = abs.(z_dist) .>= apod.maximum_aperture[2] * apod.f_number[2]

    ## Apply min aperture
    zx_dist[mask_minimum_x] .= 
        sign.(zx_dist[mask_minimum_x]) * apod.minimum_aperture[1] * apod.f_number[1]
    zy_dist[mask_minimum_y] .=
        sign.(zy_dist[mask_minimum_y]) * apod.minimum_aperture[2] * apod.f_number[2]

    ## Apply max aperture
    zx_dist[mask_maximum_x] .= 
        sign.(zx_dist[mask_maximum_x]) * apod.maximum_aperture[1] * apod.f_number[1]
    zy_dist[mask_maximum_y] .=
        sign.(zy_dist[mask_maximum_y]) * apod.maximum_aperture[2] * apod.f_number[2]

    # Calculate tangents and distance
    tan_theta = x_dist ./ zx_dist
    tan_phi = y_dist ./ zy_dist

    return tan_theta, tan_phi
end