export WaveApodization

@kwdef mutable struct WaveApodization
    wave::Wave = Wave() 
    focus::AbstractScan = Scan()

    window::Window.WindowType = Window.None
    f_number::Vector{Float64} = [1.0, 1.0]

    MLA::Integer = 1
    MLA_overlap::Integer = 0
    
    tilt::Vector{Float64} = [0.0, 0.0]
    minimum_aperature::Vector{Float64} = [1e-3, 1e-3]
    maximum_aperature::Vector{Float64} = [10, 10]

    apodization_vector::Vector{Float64} = []
    origin::Point = Point()
end