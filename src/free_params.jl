export FreeParameter
export extract_free_parameters

"""
    AbstractFreeParameter{T}

Abstract free parameter with type `T` and prior `P`
"""
abstract type AbstractFreeParameter{T,P} end

"""
    FreeParameter{T,P} <: AbstractFreeParameter{T,P}

Free parameter
"""
mutable struct FreeParameter{T,P} <: AbstractFreeParameter{T,P}
  "Value used in the model"
  val_used::T
  "prior distribution"
  prior::Union{P,Nothing}
  "bounds on value used"
  bounds::Union{Tuple{T,T},Nothing}
  function FreeParameter(val_used::T,
                         prior::P=nothing,
                         bounds=nothing
                         ) where {T,P}
    return new{T,P}(val_used, prior, bounds)
  end
end


"""
    (fp::FreeParameter)()

If a free parameter is called as a function, let the
returned value be the default value used.

# Example

```julia
  fp = FreeParameter{Float64}(5.0)
  @test fp() ≈ 5.0 # passes
```
"""
(fp::FreeParameter)() = fp.val_used

"""
    extract_free_parameters!(fp::Vector{FreeParameter}, s)

Recursively extract a vector of `FreeParameter`'s
from the struct `s`.
"""
function extract_free_parameters!(fp::Vector{FreeParameter}, s)
  for fn in fieldnames(typeof(s))
    p = getproperty(s,fn)
    if typeof(p) <: FreeParameter
      push!(fp, p)
    else
      extract_free_parameters!(fp, p)
    end
  end
  return nothing
end

function extract_free_parameters(s)
  fp = FreeParameter[]
  extract_free_parameters!(fp, s)
  return fp
end
