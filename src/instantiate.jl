#####
##### instantiate
#####

export instantiate

"""
    instantiate(s::T,
                D::Dict,
                ft::AbstractFilterTypes,
                stop_recursion_type=FreeParameter) where {T}

Instantiate instance of struct `s` and replace
using values in `D` where filter types `ft` apply.
"""
function instantiate(s::T,
                     D::Dict,
                     ft::AbstractFilterTypes) where {T}
  is_leaf(s, prop) = __is_leaf(s, prop, leaf_filter(ft), ft)
  _basename = first(split(first(keys(D)), "."))
  return _instantiate(s, D, is_leaf, _basename)
end

get_value(s::T) where {T} = s
get_value(s::FreeParameter) = s.val

function _instantiate(s::T, D::Dict, is_leaf::F, _basename::S) where {T,F<:Function,S<:AbstractString}
  cond_s = is_leaf(nothing, s)
  if any(cond_s) || T<:FPTYPES
    s_active = haskey(D, _basename) ? D[_basename] : s
    cond_D = is_leaf(nothing, s_active)
    if haskey(D, _basename) && (cond_D.custom || cond_D.isa_stop_recursion_type)
      return get_value(D[_basename])
    else
      return s
    end
  else
    props_new = [_instantiate(getproperty(s, fn), D, is_leaf, _basename*"."*string(fn)) for fn in fieldnames(T)]
    return T(props_new...)
  end
end
