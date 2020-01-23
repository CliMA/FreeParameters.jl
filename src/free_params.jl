export FreeParameter
export extract_free_parameters

const FPTYPES = Real

"""
    FreeParameterValOnly{T,P,B} <: FPTYPES

Free parameter of type `T`, with prior `P`, and bounds `B`.
"""
struct FreeParameterValOnly{T,P,B} <: FPTYPES
  "Value used in the model"
  val::T
  function FreeParameterValOnly(val::T,
                         P=Nothing,
                         B=Nothing
                         ) where {T}
    return new{T,P,B}(val)
  end
end

"""
    FreeParameterValOnly{T,P,B} <: FPTYPES

Free parameter of type `T` and prior `P`.
"""
struct FreeParameter{T,P} <: FPTYPES
  "Value used in the model"
  val::T
  "prior distribution"
  prior::Union{P,Nothing}
  "bounds on value used"
  bounds::Union{Tuple{T,T},Nothing}
  function FreeParameter(val::T,
                         prior::Union{P,Nothing}=nothing,
                         bounds::Union{Tuple{T,T},Nothing}=nothing
                         ) where {T,P}
    return new{T,typeof(prior)}(val, prior, bounds)
  end
end

Base.promote(x::T, fp::FreeParameter) where {T} = Base.promote(x, fp.val)
Base.promote(fp::FreeParameter, x::T) where {T} = Base.promote(fp.val, x)

Base.:+(x::FreeParameter, y::FPTYPES) = +(promote(x,y)...)
Base.:-(x::FreeParameter, y::FPTYPES) = -(promote(x,y)...)
Base.:*(x::FreeParameter, y::FPTYPES) = *(promote(x,y)...)
Base.:/(x::FreeParameter, y::FPTYPES) = /(promote(x,y)...)
Base.:+(x::FPTYPES, y::FreeParameter) = +(promote(x,y)...)
Base.:-(x::FPTYPES, y::FreeParameter) = -(promote(x,y)...)
Base.:*(x::FPTYPES, y::FreeParameter) = *(promote(x,y)...)
Base.:/(x::FPTYPES, y::FreeParameter) = /(promote(x,y)...)

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
