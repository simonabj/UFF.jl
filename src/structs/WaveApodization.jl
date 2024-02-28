import ControlSystems: blockdiag
import SparseArrays: sparse
import DSP: filtfilt

export WaveApodization

@kwdef mutable struct WaveApodization
    sequence::Vector{Wave} = []
    focus::Union{Scan, CompositeScan} = Scan()

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

Base.propertynames(::WaveApodization, private::Bool=false) = union(
    fieldnames(WaveApodization), [:N]
)

## Simple getproperty/setproperty! implementation

function Base.getproperty(a::WaveApodization, s::Symbol)
    if s in fieldnames(WaveApodization)
        getfield(a, s)

    elseif s == :N
        return length(a.sequence)
    end
end

function Base.setproperty!(a::WaveApodization, s::Symbol, v)
    if s in fieldnames(WaveApodization)
        setfield!(a, s, convert(fieldtype(WaveApodization, s), v))

    elseif s == :N
        error("Cannot set N")
    end
end

## Calculate apodization values

"""
    compute(apo::WaveApodization)
"""

function compute(apod::WaveApodization)
    if isempty(apod.focus)
        apod.focus = Scan([0], [0], [0])
    end

    N_waves = length(apod.sequence)

    if !isempty(apod.apodization_vector)
        return ones(apod.focus.N_pixels, 1) * apod.apodization_vector';
    end

    # No apodization
    if apod.window == Window.None
        return ones(apod.focus.N_pixels, N_waves);

    elseif apod.window == Window.Scanline
        # If linear scan
        if apod.focus isa Scan || apod.focus isa LinearScan
            # Get sequence block matrix
            cells = blockdiag([sparse(ones(apod.MLA, 1)) for _ in 1:N_waves]...)
            # Filter block with MA filter with length of MLA_overlap
            block = filtfilt(ones(apod.MLA_overlap + 1) / (apod.MLA_overlap + 1), [1.0], cells)

            return kron(block, ones(apod.focus.N_z_axis, 1))
        elseif apod.focus isa SectorScan
            # Do some more magic.
            # TODO: Implement this
        else
            error("The scan type $(typeof(apod.focus)) is not supported for scanline apodization")
        end
    end
end

function incidence(apod::WaveApodization)
end
