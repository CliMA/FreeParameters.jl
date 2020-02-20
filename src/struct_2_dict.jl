#####
##### Convert struct to dictionary
#####

export struct_2_dict

"""
    add_leaves!(D_full::Dict, s::T, _fullname::S, is_leaf::F) where {S,T,F}

Add leaves of data structure `s` to dictionary `D_full`
"""
function add_leaves!(D_full::Dict,
                     s::T,
                     _fullname::S,
                     is_leaf::F,
                     stop_recursion_type,
                     filter_type,
                     _parent=Any) where {S,T,F<:Function}
  if !(_parent isa stop_recursion_type)
    subname = string(FreeParameters.strip_type(T))
    name = _fullname == "" ? subname : _fullname*"."*subname
    D = Dict( [fn => getproperty(s, fn) for fn in fieldnames(T)] )
    filter!(x-> is_leaf(x.second), D)
    if s isa filter_type
      for (k,v) in D
        D_full[name*"."*string(k)] = v
      end
    end
    for fn in fieldnames(T)
      prop = getproperty(s, fn)
      if !isbits(prop) && !is_leaf(prop)
        add_leaves!(D_full, prop, name, is_leaf, stop_recursion_type, filter_type, s)
      end
    end
  end
end

function struct_2_dict(s, et::ExportType; stop_recursion_type=FreeParameter, filter_type=Any)
  return struct_2_dict(s, leaf_filter(et), stop_recursion_type, filter_type)
end

"""
    struct_2_dict(s::T, directory::S) where {S,T}

Convert struct to a flattened dict while
maintaining hierarchical naming scheme.
"""
function struct_2_dict(s::T, is_leaf::F, stop_recursion_type, filter_type) where {T,F<:Function}
  D_full = Dict()
  add_leaves!(D_full, s, "", is_leaf, stop_recursion_type, filter_type)
  return D_full
end

