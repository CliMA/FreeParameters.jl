using SyntaxTree
using StaticArrays

export FreeParameter, @FreeParameter
export extract_free_parameters

export ExcludeTypes, IncludeTypes
export EntireStruct, FreeParametersOnly

const FPTYPES = Real

"""
    FreeParameter{T,P,B} <: FPTYPES

Free parameter of type `T` and prior `P`.
"""
mutable struct FreeParameter{T,P,B} <: FPTYPES
  "Value used in the model"
  val::T
  "prior distribution"
  prior::P
  "bounds on value used"
  bounds::B
  function FreeParameter(val::T,
                         prior::P=nothing,
                         bounds::B=nothing
                         ) where {T,P,B}
    return new{T,P,B}(val, prior, bounds)
  end
end

#####
##### Extracting free parameters
#####

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

#####
##### Annotating free parameters
#####

macro FreeParameter(s, prior=nothing, bounds=nothing)
  e = :($(s) = FreeParameter($(s), $(prior), $(bounds)))
  return :($(esc(e)))
end

"""

"""
abstract type AbstractFilterTypes end
abstract type AbstractIncludeTypes <: AbstractFilterTypes end
abstract type AbstractExcludeTypes <: AbstractFilterTypes end

"""
    IncludeTypes <: AbstractIncludeTypes

Types to include in
 - converting a struct to dict
 - exporting a dict
 - importing a dict
"""
struct IncludeTypes <: AbstractIncludeTypes
  include_types
  stop_recursion_types
end
IncludeTypes(include_types) = IncludeTypes(include_types, (FreeParameter,))

"""
    FreeParametersOnly

Convenience constructor for including only free parameters
"""
FreeParametersOnly() = IncludeTypes((FreeParameter,), (FreeParameter,))

"""
    ExcludeTypes <: AbstractExcludeTypes

Types to exclude in
 - converting a struct to dict
 - exporting a dict
 - importing a dict
"""
struct ExcludeTypes <: AbstractExcludeTypes
  exlude_types
  stop_recursion_types
end
ExcludeTypes(exlude_types) = ExcludeTypes(exlude_types, (FreeParameter,))

"""
    EntireStruct

Convenience constructor for including entire struct/dict etc.
"""
EntireStruct() = ExcludeTypes((Any,), (FreeParameter,))

struct isleaf{B}
  custom::B
  emptyfieldnames::B
  isa_stop_recursion_type::B
  isa_SArray::B
  isa_isbits::B
  isa_tuple::B
end

Base.any(il::isleaf) = any([il.custom && il.emptyfieldnames,
                            il.isa_stop_recursion_type,
                            il.isa_SArray
                            ])

leaf_filter(ets::ExcludeTypes) = x -> isbits(x)
leaf_filter(its::IncludeTypes) = x -> any([x isa t for t in its.include_types])

function __is_leaf_old(s, prop, is_leaf_custom, ft::AbstractFilterTypes)
  C0 = is_leaf_custom(prop)
  C2 = (prop isa ft.stop_recursion_types[1])
  return (C0,C2)
end

function __is_leaf(s, prop, is_leaf_custom, ft::AbstractFilterTypes)
  C9 = isbits(prop)
  C0 = is_leaf_custom(prop)
  C1 = isempty(fieldnames(typeof(prop)))
  C2 = (prop isa ft.stop_recursion_types[1])
  C3 = (prop isa SArray)
  C4 = isbits(prop)
  C5 = s isa Tuple
  return isleaf(C0,C1,C2,C3,C4,C5)
end

function get_val_from_var(var::AbstractString)
  e = Meta.parse(var)
  if isbits(e) # var = "2.0" (for example)
    val = e
  else # var = "FreeParameter(...)" (for example)
    val = eval(e.args[1].args[1])(e.args[2:end]...)
  end
  return val
end
