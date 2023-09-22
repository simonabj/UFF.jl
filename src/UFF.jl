module UFF

version = v"1.2.0"

# Base types
include("structs/Wavefront.jl")
include("structs/Window.jl")
include("structs/Point.jl")

# Scan
include("structs/Scan.jl")
include("structs/LinearScan.jl")
include("structs/SectorScan.jl")
include("structs/Linear3DScan.jl")

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





end
