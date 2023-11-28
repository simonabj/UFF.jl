module UFF

version = v"1.2.0"

# Julia version compatibility
if VERSION < v"1.9"
    import Base: @kwdef
end

# Allow Matrix to vector conversion
Base.convert(::Type{Vector{T}}, m::Matrix{T}) where T = reduce(vcat, m)

# Base types
include("structs/Header.jl")
include("structs/Wavefront.jl")
include("structs/Window.jl")
include("structs/Point.jl")

# Scan
include("structs/Scans.jl")

# Probes
include("structs/Probe.jl")
include("structs/LinearArray.jl")
include("structs/CurvilinearArray.jl")
include("structs/MatrixArray.jl")
include("structs/CurvilinearMatrixArray.jl")

# Compund Structs
include("structs/Pulse.jl")
include("structs/Phantom.jl")

# Complex Structs
include("structs/ApertureApodization.jl")
include("structs/Wave.jl")
include("structs/WaveApodization.jl")
include("structs/ChannelData.jl")
include("structs/BeamformedData.jl")

# Functions to read/write UFF files
include("ReadObject.jl")
include("WriteObject.jl")


end
