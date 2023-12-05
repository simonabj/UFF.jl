export ApertureApodization

struct ApodizationData
    data::Matrix{Float32}
end

@kwdef mutable struct ApertureApodization
    probe::Probe = Probe()
    focus::Scan = Scan()

    window::Window.WindowType = Window.None
    f_number::Vector{Float32} = [1.0, 1.0]

    MLA::Integer = 1
    MLA_overlap::Integer = 0
    
    tilt::Vector{Float32} = [0.0, 0.0]
    minimum_aperture::Vector{Float32} = [1e-3, 1e-3]
    maximum_aperture::Vector{Float32} = [10, 10]

    apodization_vector::Vector{Float32} = []
    origin::Point = Point()

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

