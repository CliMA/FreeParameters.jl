#####
##### Convert struct to dictionary
#####
using Base.Iterators

export @struct_2_dict

"""
    add_leaves!(D_full::Dict,
                     s::T,
                     is_leaf::F,
                     stop_recursion_type::SRT,
                     _basename::S) where {S,T,F<:Function,SRT}

Add leaves of data structure `s` to dictionary `D_full`
"""
function add_leaves!(D_full::Dict,
                     s::T,
                     is_leaf::F,
                     _basename::S) where {S,T,F<:Function,SRT}
  fns = fieldnames(T)
  for fn in fns
    prop = getproperty(s, fn)
    if any(is_leaf(s, prop))
      D_full[_basename*"."*string(fn)] = prop
    else
      add_leaves!(D_full, prop, is_leaf, _basename*"."*string(fn))
    end
  end
end

function struct_2_dict(s, obj_name::AbstractString; ft::AbstractFilterTypes=EntireStruct())
  D_full = Dict()
  is_leaf(s, prop) = __is_leaf(s, prop, leaf_filter(EntireStruct()), ft)
  add_leaves!(D_full, s, is_leaf, obj_name)
  return D_full
end

"""
    @struct_2_dict(s::T) where {T}

Convert struct to a `Dict` with
a hierarchical naming scheme.
"""
macro struct_2_dict(s)
  obj_name = string(s)
  return esc(quote
               FreeParameters.struct_2_dict($s, $obj_name)
             end)
end
