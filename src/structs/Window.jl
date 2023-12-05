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

boxcar(ratio) = Float32(ratio <= 0.5)
hanning(ratio) = Float32(ratio<= 0.5)*(0.5 + 0.5cos(2π*ratio))
hamming(ratio) = Float32(ratio<= 0.5)*(0.53836 + 0.46164cos(2π*ratio))
tukey_my(ratio, α) = Float32((ratio<= 0.5(1-α))) + (ratio>0.5(1-α)) * (ratio<0.5) * 0.5(1+cos(2π/α*(ratio-α/2-0.5)))

tukey_dsp(ratio, α) = tukey()

function window_weights!(window::WindowType, θ_ratio, ϕ_ratio)
    if window == None
        return missing

    elseif window == Boxcar
        return nothing
    end
end

end