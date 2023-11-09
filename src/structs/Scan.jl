export Scan, AbstractScan

abstract type AbstractScan end

@kwdef mutable struct Scan <: AbstractScan
    x::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    y::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
    z::Array{Float32, 1} = Array{Float32, 1}(undef, 0)
end

Base.propertynames(::Type{Scan}, private = false) = union(fieldnames(Scan), [:N_pixels, :xyz])

function Base.getproperty(scan::Scan, s::Symbol) 
    if s in fieldnames(Scan)
        getfield(scan, s)
    elseif s == :N_pixels
        length(scan.x)
    elseif s == :xyz
        [scan.x[1], scan.y[1], scan.z[1]]
    else
        error("No get property $s exists in Scan")
    end
end

function Base.setproperty!(scan::Scan, s::Symbol, v)
    if s in fieldnames(Scan)
        setfield!(scan, s, convert(fieldtype(Scan, s), v))
    elseif s == :xyz
        scan.x = v[:, 1]
        scan.y = v[:, 2]
        scan.z = v[:, 3]
    else
        error("No set property $s exists in Scan")
    end
end