export CompositeScan, Scan, LinearScan, SectorScan, LinearScanRotated, Linear3DScan



@kwdef mutable struct Scan
    x::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    y::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    z::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
end

abstract type CompositeScan end
Base.convert(::Type{Scan}, scan::CompositeScan) = scan.scan

@kwdef mutable struct LinearScan <: CompositeScan
    scan::Scan = Scan()

    x_axis::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    z_axis::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
end

@kwdef mutable struct SectorScan <: CompositeScan
    scan::Scan = Scan()

    origin::Vector{Point} = []
    depth_axis::Vector{Float32} = []
    azimuth_axis::Vector{Float32} = []
end

@kwdef mutable struct LinearScanRotated <: CompositeScan
    scan::Scan = Scan()

    x_axis::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    z_axis::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    rotation_angle::Float32 = 0.0
    center_of_rotation::Point = Point()
end

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
    fieldnames(SectorScan), [:Not_finished]
)
Base.propertynames(::LinearScanRotated, private::Bool = false) = union(
    fieldnames(LinearScanRotated), [:Not_finished]
)
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

## Concrete setters

## Concrete updaters
function update_LinearScan_pixels!(scan::LinearScan)
    scan.scan.x = (ones(length(scan.z_axis))' .* scan.x_axis)[:];
    scan.scan.y = zeros(length(scan.x_axis) * length(scan.z_axis))
    scan.scan.z = (ones(length(scan.x_axis)) .* scan.z_axis')[:];
end