import Pkg
Pkg.activate(; temp=true)
Pkg.add("PackageCompiler")
Pkg.dev(path=joinpath(@__DIR__, "..")) # dev or add?

using PackageCompiler
create_sysimage(
    ["PoleExploration"]; 
    sysimage_path=joinpath(@__DIR__, "custom_sysimage.so"), 
    precompile_execution_file=joinpath(@__DIR__, "precompile_file.jl"),
)