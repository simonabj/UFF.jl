export Window

import DSP: tukey

module Window
export WindowType, None, Boxcar, Hanning, Hamming, Tukey25, Tukey50, Tukey75, Tukey80, Scanline, Rectangular, Flat, Sta

"""
    Window

Enumeration for window types. 
Available options and corresponding values are 

| Window Type | Value |
|-------------|-------|
| None        |   0   |
| Boxcar      |   1   |
| Flat        |   1   |
| Rectangular |   1   |
| Hanning     |   2   |
| Hamming     |   3   |
| Tukey25     |   4   |
| Tukey50     |   5   |
| Tukey75     |   6   |
| Tukey80     |   7   |
| Sta         |   7   |
| Scanline    |   8   |

See also PULSE, BEAM, PHANTOM, PROBE
# TODO: Link up PULSE
# TODO: Link up BEAM
# TODO: Link up PHANTOM
# TODO: Link up PROBE
"""
@enum WindowType begin
    None = 0
    Boxcar = 1
    Hanning = 2
    Hamming = 3
    Tukey25 = 4
    Tukey50 = 5
    Tukey75 = 6
    Tukey80 = 7
    Scanline = 8
end

Rectangular = Boxcar
Flat = Boxcar
Sta = Tukey80

boxcar_weight(ratio)   = @. Float32(ratio <= 0.5)
hanning_weight(ratio)  = @. Float32(ratio <= 0.5) * (0.5 + 0.5cos(2π * ratio))
hamming_weight(ratio)  = @. Float32(ratio <= 0.5) * (0.53836 + 0.46164cos(2π * ratio))
tukey_weight(ratio, α) = @. Float32((ratio <= 0.5(1 - α))) + (ratio > 0.5(1 - α)) * (ratio < 0.5) * 0.5(1 + cos(2π / α * (ratio - α / 2 - 0.5)))

(window::WindowType)(ratio) = window_weights(window, ratio, [0.0])
(window::WindowType)(θ, ϕ) = window_weights(window, θ, ϕ)

function window_weights(window::WindowType, θ_ratio, ϕ_ratio)
    θ_ratio[isinf.(θ_ratio)] .= 0
    ϕ_ratio[isinf.(θ_ratio)] .= 0

    if window == Boxcar
        return boxcar_weight(θ_ratio) .* boxcar_weight(ϕ_ratio)

    elseif window == Hanning
        return hanning_weight(θ_ratio) .* hanning_weight(ϕ_ratio)
    
    elseif window == Hamming
        return hamming_weight(θ_ratio) .* hamming_weight(ϕ_ratio)
    
    elseif window == Tukey25
        return tukey_weight(θ_ratio, 0.25) .* tukey_weight(ϕ_ratio, 0.25)

    elseif window == Tukey50
        return tukey_weight(θ_ratio, 0.5) .* tukey_weight(ϕ_ratio, 0.5)   

    elseif window == Tukey75
        return tukey_weight(θ_ratio, 0.75) .* tukey_weight(ϕ_ratio, 0.75)

    elseif window == Tukey80
        return tukey_weight(θ_ratio, 0.8) .* tukey_weight(ϕ_ratio, 0.8)
    else
        error("Window type not supported")
    end
end

end