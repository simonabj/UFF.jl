export ApertureApodization

@kwdef mutable struct ApertureApodization
    probe::AbstractProbe = Probe()
    focus::AbstractScan = Scan()

    window::Window.WindowType = Window.None
    f_number::Vector{Float32} = [1.0, 1.0]

    MLA::Integer = 1
    MLA_overlap::Integer = 0
    
    tilt::Vector{Float32} = [0.0, 0.0]
    minimum_aperature::Vector{Float32} = [1e-3, 1e-3]
    maximum_aperature::Vector{Float32} = [10, 10]

    apodization_vector::Vector{Float32} = []
    origin::Point = Point()
end

