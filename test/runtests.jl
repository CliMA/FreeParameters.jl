using Test
using FreeParameters
using Distributions


output = joinpath(@__DIR__,"..","output")
run(`rm -rf $output`)

include("is_approx.jl")
include("macro.jl")

include("dycomsmodel.jl")
include("define_model.jl")

include("generic_struct.jl")

println("===========================")
println("=========================== single file")
println("===========================")

include("export_single_file.jl")
include("import_single_file.jl")

println("===========================")
println("=========================== folder structure")
println("===========================")

include("export_folder.jl")
include("import_folder.jl")

println("===========================")
println("=========================== Dictionary")
println("===========================")

include("struct_2_dict.jl")
include("export_dict.jl")
include("import_dict.jl")
include("instantiate.jl")
