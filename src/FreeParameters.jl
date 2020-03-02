module FreeParameters

using Distributions

export flatten!, flatten, unflatten, @parameters

include("flatten.jl")
include("macro.jl")
include("domains.jl")

include("io.jl")
include("free_params.jl")

# Soon to be removed:
include("generic_and_parametric_types.jl")
include("export_folders.jl")
include("import_folders.jl")
include("export_single_file.jl")
include("import_single_file.jl")

include("struct_2_dict.jl")
include("annotate.jl")
include("export_dict.jl")
include("import_dict.jl")
include("instantiate.jl")

end