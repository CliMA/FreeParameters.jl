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
  "Default value"
  default_value::T
  "prior distribution"
  prior::P
  function FreeParameter(default_value::T,
                         prior::P=Normal(default_value)
                         ) where {T,P}
    return new{T,P}(default_value, prior)
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
(fp::FreeParameter)() = fp.default_value

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
