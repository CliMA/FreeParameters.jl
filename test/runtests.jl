using Test
using FreeParameters
using Distributions


output = joinpath(@__DIR__,"..","output")
run(`rm -rf $output`)

include("macro.jl")

include("dycomsmodel.jl")
include("define_model.jl")

include("struct_2_dict.jl")
include("extract.jl")
include("export_dict.jl")
include("import_dict.jl")
include("instantiate.jl")
