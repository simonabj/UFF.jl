using ArgCheck

export CompositeScan, Scan, LinearScan, SectorScan, LinearScanRotated, Linear3DScan



@kwdef mutable struct Scan
    x::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    y::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    z::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
end

abstract type CompositeScan end
Base.convert(::Type{Scan}, scan::CompositeScan) = scan.scan

## Define composite scan types

"""
"""
@kwdef mutable struct LinearScan <: CompositeScan
    scan::Scan = Scan()

    x_axis::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    z_axis::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
end

"""
"""
@kwdef mutable struct SectorScan <: CompositeScan
    scan::Scan = Scan()

    origin::Vector{Point} = [Point()]
    depth_axis::Vector{Float32} = []
    azimuth_axis::Vector{Float32} = []


    rho::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    theta::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
end

"""
"""
@kwdef mutable struct LinearScanRotated <: CompositeScan
    scan::Scan = Scan()

    x_axis::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    z_axis::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    rotation_angle::Float32 = 0.0
    center_of_rotation::Point = Point()
end

"""
"""
@kwdef mutable struct Linear3DScan <: CompositeScan
    scan::Scan = Scan() 

    radial_axis::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    axial_axis::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    roll::Float32 = 0.0
end

# Property names
Base.propertynames(::Scan, private::Bool = false) = union(
    fieldnames(Scan), [:N_pixels, :xyz]
)
Base.propertynames(::LinearScan, private::Bool = false) = union(
    fieldnames(LinearScan), propertynames(Scan()) , [:N_x_axis, :N_z_axis, :x_step, :z_step, :reference_distance]
)
Base.propertynames(::SectorScan, private::Bool = false) = union(
    fieldnames(SectorScan), propertynames(Scan()), [:N_azimuth_axis, :N_depth_axis, :N_origins, :depth_step, :reference_distance]
)
# TODO: Add property names for LinearScanRotated
Base.propertynames(::LinearScanRotated, private::Bool = false) = union(
    fieldnames(LinearScanRotated), propertynames(Scan()), [:N_x_axis, :N_z_axis, :x_step, :z_step, :reference_distance]
)
# TODO: Add property names for Linear3DScan
Base.propertynames(::Linear3DScan, private::Bool = false) = union(
    fieldnames(Linear3DScan), [:Not_finished]
)


function Base.getproperty(scan::Scan, s::Symbol)
    if s in fieldnames(typeof(scan))
        getfield(scan, s)
    elseif s == :N_pixels
        length(scan.x)
    elseif s == :xyz
        hcat(scan.x, scan.y, scan.z)
    else
        error("No get property $s exists in Scan")
    end
end

function Base.getproperty(scan::CompositeScan, s::Symbol)
    if s in fieldnames(typeof(scan))
        getfield(scan, s)
    elseif s in propertynames(Scan())
        getproperty(scan.scan, s)
    elseif scan isa LinearScan
        get_LinearScan_dependents(scan, s)
    elseif scan isa SectorScan
        get_SectorScan_dependents(scan, s)
    elseif scan isa LinearScanRotated
        get_LinearScanRotated_dependents(scan, s)
    elseif s == :Not_finished
        false
    else
        error("No get property $s exists in CompositeScan")
    end
end

function Base.setproperty!(scan::Scan, s::Symbol, value)
    if s in fieldnames(Scan)
        setfield!(scan, s, convert(fieldtype(Scan, s), value))
    elseif s == :xyz
        scan.x = value[:, 1]
        scan.y = value[:, 2]
        scan.z = value[:, 3]
    else
        error("No set property $s exists in Scan")
    end
end

function Base.setproperty!(scan::CompositeScan, s::Symbol, value)
    if s in fieldnames(typeof(scan))
        setfield!(scan, s, convert(fieldtype(typeof(scan), s), value))
    elseif s in propertynames(Scan)
        setproperty!(scan.scan, s, value)
    else
        error("No set property $s exists in $(typeof(scan))")
    end
    
    if scan isa LinearScan
        update_LinearScan_pixels!(scan) 
    elseif scan isa SectorScan
        update_SectorScan_pixels!(scan)
    elseif scan isa LinearScanRotated
        update_LinearScanRotated_pixels!(scan)
    end
end


## Concrete getters
function get_LinearScan_dependents(sca::LinearScan, s::Symbol)
    if s == :N_x_axis
        length(sca.x_axis)
    elseif s == :N_z_axis
        length(sca.z_axis)
    elseif s == :x_step
        sca.x_axis[2] - sca.x_axis[1]
    elseif s == :z_step
        sca.z_axis[2] - sca.z_axis[1]
    elseif s == :reference_distance
        sca.scan.z
    else
        error("No get property $s exists in LinearScan")
    end
end

function get_SectorScan_dependents(sca::SectorScan, s::Symbol)
    if s == :N_azimuth_axis
        length(sca.azimuth_axis)
    elseif s == :N_depth_axis
        length(sca.depth_axis)
    elseif s == :N_origins
        length(sca.origin)
    elseif s == :depth_step
        sca.depth_axis[2] - sca.depth_axis[1]
    elseif s == :reference_distance
        sca.rho
    else
        error("No get property $s exists in SectorScan")
    end
end

function get_LinearScanRotated_dependents(scan::LinearScanRotated, s::Symbol)
    if s == :N_x_axis
        length(scan.x_axis)
    elseif s == :N_z_axis
        length(scan.z_axis)
    elseif s == :x_step
        sca.x_axis[2] - sca.x_axis[1]
    elseif s == :z_step
        sca.z_axis[2] - sca.z_axis[1]
    elseif s == :reference_distance
        sin(scan.rotation_angle)*scan.x + cos(scan.rotation_angle)*scan.z
    else
        error("No get property $s exists in LinearScanRotated")
    end
end

## Concrete setters

## Concrete updaters
function update_LinearScan_pixels!(scan::LinearScan)
    scan.scan.x = (ones(length(scan.z_axis))' .* scan.x_axis)[:];
    scan.scan.y = zeros(length(scan.x_axis) * length(scan.z_axis))
    scan.scan.z = (ones(length(scan.x_axis)) .* scan.z_axis')[:];
end

function update_SectorScan_pixels!(scan::SectorScan)
    @argcheck scan.N_origins == 1 || scan.N_origins == scan.N_azimuth_axis ArgumentError(
        "Number of origins should be either one or equal to the number of scan lines")

    N_pixels = scan.N_azimuth_axis * scan.N_depth_axis
    x0 = getproperty.(scan.origin, :x)
    y0 = getproperty.(scan.origin, :y)
    z0 = getproperty.(scan.origin, :z)

    scan.scan.x = (scan.depth_axis' .* sin.(scan.azimuth_axis)  .+ x0)[:]
    scan.scan.z = (scan.depth_axis  .* cos.(scan.azimuth_axis)' .+ z0)[:]
    scan.scan.y = zeros(N_pixels)
end

function update_LinearScanRotated_pixels!(scan::LinearScanRotated)
    # Mesh grid
    X = (ones(length(scan.z_axis))' .* scan.x_axis )[:];
    Z = (ones(length(scan.x_axis))  .* scan.z_axis')[:];

    angle = scan.rotation_angle
    center = scan.center_of_rotation.xyz

    if !isempty(X)
        Xc = X .- center[1];
        Zc = Z .- center[3];

        rot_matrix = [cos(angle) -sin(angle); sin(angle) cos(angle)]
        rot_grid = [Xc[:] Zc[:]]*rot_matrix
        
        X = reshape(rot_grid[:, 1], size(Xc))
        Z = reshape(rot_grid[:, 2], size(Zc))

        X = X .+ center[1]
        Z = Z .+ center[3]
    
        scan.scan.x = X[:]
        scan.scan.y = zeros(prod(size(X)))
        scan.scan.z = Z[:]
    end
end