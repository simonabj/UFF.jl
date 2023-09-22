
export UFFHeader

@kwdef mutable struct UFFHeader
    name::Union{Array{String, 1}, Nothing} = nothing
    author::Union{Array{String, 1}, Nothing} = nothing
    version::Union{Array{String, 1}, Nothing} = nothing
    reference::Union{Array{String, 1}, Nothing} = nothing
    info::Union{Array{String, 1}, Nothing} = nothing
end