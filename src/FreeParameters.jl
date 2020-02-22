module FreeParameters

using Distributions

export flatten!, flatten, unflatten, @parameters

include("free_params.jl")
include("flatten.jl")
include("domains.jl")
include("macro.jl")
include("io.jl")
include("export_folders.jl")
include("import_folders.jl")
include("export_single_file.jl")
include("import_single_file.jl")

end