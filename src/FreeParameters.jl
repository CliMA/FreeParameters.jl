module FreeParameters

export flatten!, flatten, unflatten, @parameters

include("free_params.jl")
include("flatten.jl")
include("domains.jl")
include("macro.jl")

end