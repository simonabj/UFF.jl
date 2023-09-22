using HDF5

export read_object



function _read_location(fid, location, verbose)
    data_name = nothing 
    class_name = nothing

    try
        data_name = attrs(fid[location])["name"]
        class_name = attrs(fid[location])["class"]
    catch
        error("Location $location missing attributes name and/or class")
    end

    if class_name in ["double", "single", "int16"]
        data = nothing
        if Bool(attrs(fid[location])["complex"][1])
            data = read(fid[location]["real"]) + im * read(fid[location]["imag"])
        else
            data = read(fid[location])
        end

        if length(data) == 1
            return first(data)
        else
            return data
        end
    elseif class_name == "char"
        return join(Char.(read(fid[location])))
    elseif class_name == "uff.window"
        return Window.WindowType(trunc(Int,read(fid[location])[1]))
    elseif class_name == "uff.wavefront"
        return Wavefront.WavefrontType(trunc(Int,read(fid[location])[1]))
    elseif class_name == "cell"
        
        # YO dawg, I heard you like cells
        current_item = basename(location)
        if Symbol(current_item) in fieldnames(UFFHeader)
            # This is part of a header object!
            items = keys(fid[location])
            N = length(items)

            header_data = Array{String}(undef, N)

            for i in 1:N
                if verbose println("$location/$items[i]") end
                header_data[i] = _read_location(fid, joinpath(location, items[i]), verbose)
            end

            return header_data
        else
            println("Current item: $current_item")

            # Wtf do I do with cells?
            # Wtf even is a cell anyway?
            error("Cell not supported yet. Please post an issue on GitHub if this is important https://github.com/simonabj/UFF.jl/issues")
        end
    elseif !isnothing(match(r"uff\.*", class_name))
        # Custom UFF type
        if verbose && class_name in ["uff.channel_data", "uff.beamformed_data", "uff.phantom"]
            println("Reading $class_name")
        end

        data_size = Int(prod(attrs(fid[location])["size"]))
        N = prod(data_size)
        items = keys(fid[location])

        if N > 1
            if length(items) != N error("Size attribute does not match number of items") end
            out = Vector{Any}(undef, N)

            for i in 1:N
                out[i] = _read_location(fid, joinpath(location, items[i]), verbose)
            end

            if verbose println("Done!") end
            reshape(out, transpose(data_size))
            return out
        else
            # Convert class_name from snake_case to CamelCase
            sym_name = join([uppercase(word[1]) * lowercase(word[2:end]) for word in split(class_name[5:end], "_")])

            # Ayo, why USTB use metaprogramming? I don't like this...
            uff_obj = eval(Meta.parse(sym_name * "()"))

            # Get the rest of the stuff then
            props = keys(fid[location])
            for prop in props
                prop_location = "$location/$prop"
                if verbose println(prop_location) end
                
                prop_name = attrs(fid[prop_location])["name"] # isnt this just prop?
                

                # Here we can include some backwards compatibility stuff.
                # Guess this is a todo for now.
                # if flag_v10x && prop_name == "uff.probe"

                # This will definitely break...
                if Symbol(prop) in fieldnames(UFFHeader)
                    # Since the header is a collection of multiple unpacked vales, we must dispatch into the header object
                    setfield!(uff_obj.header, Meta.parse(prop), _read_location(fid, prop_location, verbose)) 
                else
                    setfield!(uff_obj, Meta.parse(prop), _read_location(fid, prop_location, verbose))
                end
            end
            return uff_obj
        end
    else
        prinln("Unsupported class $class_name")
        return nothing
    end
end


function read_object( filename, location = "/", verbose = true)

flag_v10x = false
flag_v11x = false

# Check if file exists
if !isfile(filename)
    error("File $filename does not exist")
end

fid = h5open(filename, "r")

file_version = attrs(fid)["version"][1]

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

_read_location(fid, location, verbose)

end