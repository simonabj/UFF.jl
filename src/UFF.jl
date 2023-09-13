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

# Probes
include("structs/Probe.jl")
include("structs/LinearArray.jl")
include("structs/CurvilinearArray.jl")

# Compund Structs
include("structs/Pulse.jl")
include("structs/Phantom.jl")

# Complex Structs
abstract type AbstractWave end 
include("structs/Apodization.jl")
include("structs/Wave.jl")





end
