module FreeParameters

using Distributions

export flatten!, flatten, unflatten, @parameters

include("free_params.jl")
include("flatten.jl")
include("domains.jl")
include("macro.jl")
include("io.jl")
include("struct_2_dict.jl")

end