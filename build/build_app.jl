import Pkg
Pkg.activate(; temp=true)
Pkg.add("PackageCompiler")

using PackageCompiler
create_app(
    joinpath(@__DIR__, ".."), 
    joinpath(@__DIR__, "compiled");
    precompile_execution_file=joinpath(@__DIR__, "precompile_file.jl"),
)