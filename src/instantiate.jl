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
  is_leaf(s, prop) = __is_leaf(s, prop, ft)
  _basename = first(split(first(keys(D)), "."))
  return _instantiate(s, D, is_leaf, _basename)
end

function _instantiate(s::T, D::Dict, is_leaf::F, _basename::S) where {T,F<:Function,S<:AbstractString}
  cond_s = is_leaf(nothing, s)
  if T <: Function
    return s
  elseif triggers(cond_s) || T<:FPTYPES
    s_active = haskey(D, _basename) ? D[_basename] : s
    cond_D = is_leaf(nothing, s_active)
    cond = haskey(D, _basename) && aux_leaf(cond_D)
    return cond ? get_val(D[_basename]) : s
  else
    props_new = [_instantiate(getproperty(s, fn), D, is_leaf, _basename*"."*string(fn)) for fn in fieldnames(T)]
    return T <: Tuple ? T(props_new) : T(props_new...)
  end
end
