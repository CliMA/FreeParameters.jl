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

struct leaf_triggers{B,AFT}
  ft::AFT
  s
  prop
  custom::B                  # C1
  emptyfieldnames::B         # C2
  isa_stop_recursion_type::B # C3
  isa_SArray::B              # C4
  isa_isbits::B              # C5
end

triggers(t::Tuple) = any(t)

function aux_leaf(lt::leaf_triggers{Bool,IncludeTypes})
  return any([lt.prop isa t for t in lt.ft.stop_recursion_types]) || any([lt.prop isa t for t in lt.ft.include_types])
end
function aux_leaf(lt::leaf_triggers{Bool,ExcludeTypes})
  return any([lt.prop isa t for t in lt.ft.stop_recursion_types]) || isbits(lt.prop)
end

triggers(lt::leaf_triggers) = triggers(lt, lt.ft)

triggers(lt::leaf_triggers, ft::IncludeTypes) = any([any([lt.prop isa t for t in ft.include_types]) && lt.emptyfieldnames,
                                                     lt.isa_stop_recursion_type
                                                     ])
triggers(lt::leaf_triggers, ft::ExcludeTypes) = any([isbits(lt.prop) && lt.emptyfieldnames,
                                                     lt.isa_stop_recursion_type,
                                                     lt.isa_SArray
                                                     ])

function __is_leaf(s, prop, ft::IncludeTypes)
  C1 = any([prop isa t for t in ft.include_types])
  C2 = isempty(fieldnames(typeof(prop)))
  C3 = any([prop isa t for t in ft.stop_recursion_types])
  C4 = (prop isa SArray)
  C5 = isbits(prop)
  return leaf_triggers(ft, s, prop, C1, C2, C3, C4, C5)
end
function __is_leaf(s, prop, ft::ExcludeTypes)
  C1 = isbits(prop)
  C2 = isempty(fieldnames(typeof(prop)))
  C3 = any([prop isa t for t in ft.stop_recursion_types])
  C4 = (prop isa SArray)
  C5 = isbits(prop)
  return leaf_triggers(ft, s, prop, C1, C2, C3, C4, C5)
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

"""
    get_val(x)
Gets value of `FreeParameter`,
otherwise return identity.
"""
function get_val end
get_val(x) = x
get_val(x::FreeParameter) = x.val
