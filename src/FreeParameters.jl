module FreeParameters

using Distributions

export flatten!, flatten, unflatten, @parameters

include("flatten.jl")
include("macro.jl")
include("domains.jl")

include("io.jl")
include("free_params.jl")

include("struct_2_dict.jl")
include("annotate.jl")
include("export_dict.jl")
include("import_dict.jl")
include("instantiate.jl")

end