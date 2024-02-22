using HDF5

export read_object

"""
    Read data from HDF5 file object.

    # Arguments
    - `h5obj::HDF5File`: HDF5 file object

    # Returns
    - `data::Any`: Data read from HDF5 file object
"""
function read_data(h5obj)
    data = nothing
    if Bool(attrs(h5obj)["complex"][1])
        data = read(h5obj["real"]) + im * read(h5obj["imag"])
    else
        data = read(h5obj)
    end

    if length(data) == 1
        return first(data)
    else
        return data
    end
end

function read_col_vector(h5obj)
    # Read column vector
    return read_data(h5obj)[:, 1]
end

"""
    Create a scan object from a HDF5 file object at a given location.

    # Arguments
    - `fid::HDF5File`: HDF5 file object
    - `location::String`: Location of scan object in HDF5 file
    - `verbose::Bool`: Print verbose output
"""
function read_scan(fid, location; verbose = false)
    # We need to determine the type of scan, and then request
    # the appropriate data from the HDF5 file corresponding to that scan type.
    scan_type = match(r"uff\.(.*)", attrs(fid[location])["class"])[1]

    base_scan = Scan()
    base_scan.x = read_col_vector(fid["$location/x"])
    base_scan.y = read_col_vector(fid["$location/y"])
    base_scan.z = read_col_vector(fid["$location/z"])
    

    if scan_type == "scan"
        return base_scan
    end

    full_scan = scan_type == "linear_scan" ? LinearScan() :
           scan_type == "sector_scan" ? SectorScan() :
           scan_type == "curvilinear_scan" ? CurvilinearScan() :
           scan_type == "linear_scan_rotated" ? LinearScanRotated() :
           scan_type == "linear_3d_scan" ? Linear3DScan() :
           error("Scan type $scan_type not supported.")

    setfield!(full_scan, :scan, base_scan)

    for field_name in fieldnames(typeof(full_scan))
        if field_name == :scan
            continue
        end # Skip scan field

        # setproperty! will try to convert the data to the correct type
        try
            setfield!(full_scan, field_name, convert(fieldtype(typeof(full_scan), field_name), read_data(fid["$location/$field_name"])))
        catch e
            # This is a special case for sector scans in v1.2.0
            sector_scan_fix = field_name == :origin && scan_type == "sector_scan" && e isa KeyError
            if !sector_scan_fix
                rethrow(e)
            end

            apex = _read_location(fid, "$location/apex"; verbose)
            if apex isa Point
                apex = [apex]
            end
            setfield!(full_scan, :origin, apex)
        end
    end

    return full_scan
end

function read_array(fid, location; verbose = false)

    array_type = match(r"uff\.(.*)", attrs(fid[location])["class"])[1]

    array = array_type == "linear_array" ? LinearArray() :
            array_type == "curvilinear_array" ? CurvilinearArray() :
            array_type == "matrix_array" ? MatrixArray() :
            array_type == "curvilinear_matrix_array" ? CurvilinearMatrixArray() :
            error("Array type $array_type not supported.")

    # Read the location as an array
    for key in keys(fid[location])
        if verbose
            println("$location/$key")
        end
        # setproperty! will run update!() on the inner probe, which we don't want.
        UFF.set!(array, Symbol(key), false, read_data(fid["$location/$key"]))
        
    end

    return array
end

function read_cell(fid, location)
    # YO dawg, I heard you like cells
    current_item = basename(location)
    if !(Symbol(current_item) in fieldnames(UFFHeader))
        println("Current item: $current_item")
        # Wtf do I do with cells?
        # Wtf even is a cell anyway?
        error("Cell not supported yet. Please post an issue on GitHub if this is important https://github.com/simonabj/UFF.jl/issues")
    end

    # This is part of a header object!
    items = keys(fid[location])
    N = length(items)
    header_data = Array{String}(undef, N)

    for i in 1:N
        if verbose
            println("$location/$items[i]")
        end
        header_data[i] = _read_location(fid, joinpath(location, items[i]); verbose)
    end

    return header_data
end

function _read_location(fid, location; verbose = false)
    data_name = nothing
    class_name = nothing

    try
        data_name = attrs(fid[location])["name"]
        class_name = attrs(fid[location])["class"]
    catch
        error("Location $location missing attributes name and/or class")
    end

    if class_name in ["double", "single", "int16"]
        return read_data(fid[location])

    elseif class_name == "char"
        return join(Char.(read(fid[location])))

    elseif class_name == "uff.window"
        return Window.WindowType(trunc(Int, read(fid[location])[1]))

    elseif class_name == "uff.wavefront"
        return Wavefront.WavefrontType(trunc(Int, read(fid[location])[1]))

    elseif class_name == "cell"
        return read_cell(fid, location)

    elseif endswith(class_name, "scan")
        if verbose
            println("Reading scan!")
        end
        return read_scan(fid, location; verbose)

    elseif endswith(class_name, "array")
        if verbose
            println("Reading array!")
        end
        return read_array(fid, location; verbose)

    end

    class_name_matches = match(r"uff\.*", class_name)
    if !isnothing(class_name_matches)
        # Meta-parse everything we dont know exactly what is

        # Custom UFF type
        if verbose && class_name in ["uff.channel_data", "uff.beamformed_data", "uff.phantom"]
            println("Reading $class_name")
        end

        data_size = Int(prod(attrs(fid[location])["size"]))
        N = prod(data_size)
        items = keys(fid[location])

        if N > 1
            if length(items) != N
                error("Size attribute does not match number of items")
            end

            sym_name = join([uppercase(word[1]) * lowercase(word[2:end]) for word in split(class_name[5:end], "_")])

            # Wtf is this cursed monstrosity?!?
            out = Vector{eval(Meta.parse(sym_name))}(undef, N)

            for i in 1:N
                out[i] = _read_location(fid, joinpath(location, items[i]); verbose)
            end

            if verbose
                println("Done!")
            end
            reshape(out, transpose(data_size))
            return out
        else
            # Convert class_name from snake_case to CamelCase
            sym_name = join([uppercase(word[1]) * lowercase(word[2:end]) for word in split(class_name[5:end], "_")])

            # We need to handle the split case of Wave and Aperture apodizations
            if sym_name == "Apodization"
                # Check is sequence is empty
                if "sequence" in keys(fid[location])
                    sym_name = "WaveApodization"
                else
                    sym_name = "ApertureApodization"
                end
            end

            # Ayo, why USTB use metaprogramming? I don't like this...
            uff_obj = eval(Meta.parse(sym_name * "()"))

            # Get the rest of the stuff then
            props = keys(fid[location])
            for prop in props
                prop_location = "$location/$prop"
                if verbose
                    println(prop_location)
                end

                # Here we can include some backwards compatibility stuff.
                # Guess this is a todo for now.
                # if flag_v10x && prop_name == "uff.probe"

                # This will definitely break...
                if Symbol(prop) in fieldnames(UFFHeader)
                    # Since the header is a collection of multiple unpacked vales, we must dispatch into the header object
                    setfield!(uff_obj.header, Meta.parse(prop), _read_location(fid, prop_location; verbose))
                else
                    # PS: This is way too deep. Should probably refactor this with guard clauses or something.

                    prop_symbol = Meta.parse(prop)

                    # Property symbol translation for differences between Matlab and Julia implementation
                    if isa(uff_obj, Point)
                        prop_symbol = (prop_symbol == :azimuth) ? :θ :
                                      (prop_symbol == :elevation) ? :ϕ :
                                      (prop_symbol == :distance) ? :r : prop_symbol
                    end

                    prop_field_type = fieldtype(typeof(uff_obj), prop_symbol)
                    data = _read_location(fid, prop_location; verbose)
                    if prop_field_type <: Integer
                        data = trunc(prop_field_type, data)
                    end

                    # Some whacky-hacky stuff to make sure that the data is correct type
                    if prop_symbol in [:f_number, :tilt, :maximum_aperture, :minimum_aperture]
                        data = vec(data)
                    elseif isa(uff_obj, Scan)
                        data = [data]
                    end

                    setfield!(uff_obj, prop_symbol, data)
                end

                # Upon finishing construction of wave objects, propagate probe from wave to apodization
                if isa(uff_obj, Wave)
                    uff_obj.apodization.probe = uff_obj.probe
                end
            end
            return uff_obj
        end
    else
        error("Unsupported class $class_name")
        return nothing
    end
end


function read_object(filename, location="/"; verbose=false)

    flag_v10x = false
    flag_v11x = false

    # Check if file exists
    if !isfile(filename)
        error("File $filename does not exist")
    end

    fid = h5open(filename, "r")

    file_version = attrs(fid)["version"][1]

    if verbose
        println("File version = $file_version")
    end

    if !isnothing(match(r"v1\.2\.\d+", file_version))
        # Current version
    elseif !isnothing(match(r"v1\.1\.\d+", file_version))
        flag_v11x = true
    elseif !isnothing(match(r"v1\.0\.\d+", file_version))
        flag_v10x = true
    else
        error("UFF version $file_version not supported")
    end

    try
        fid[location]
    catch
        error("Location $location does not exist")
    end

    if location == "/"
        error("Batch reading not supported yet. Please specify a location.")
    end

    result = _read_location(fid, location; verbose)

    close(fid)

    return result
end