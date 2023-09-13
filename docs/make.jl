using UFF
using Documenter

DocMeta.setdocmeta!(UFF, :DocTestSetup, :(using UFF); recursive=true)

makedocs(;
    modules=[UFF],
    authors="Simon Andreas Bjørn <s.a.bjorn@ifi.uio.no> and contributors",
    repo="https://github.com/Dainou01/UFF.jl/blob/{commit}{path}#{line}",
    sitename="UFF.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Dainou01.github.io/UFF.jl",
        edit_link="develop",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Dainou01/UFF.jl",
    devbranch="develop",
)
