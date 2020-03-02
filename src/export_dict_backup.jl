#####
##### Export dict
#####

export export_dict, export_dict_alternative

#####
##### SingleFile IO
#####

"""
    export_struct(s::T, directory::S) where {S,T}

Export struct `s` to directory `directory`
with the same structure as `s`.

 - `stop_recursion_type` stop recursion when reaching type `stop_recursion_type`
"""
function export_dict(D::Dict,
                     s::T,
                     et::AbstractFilterTypes,
                     outstyle::SingleFile) where {S,T}
  _basename = first(split(first(keys(D)), "."))

  is_leaf(s, prop) = __is_leaf(s, prop, leaf_filter(et), ft)

  open(outstyle.filename,"w") do io
    export_dict_single_file(io, D, s, is_leaf, _basename)
  end
end

function export_dict_single_file(io,
                                 D::Dict,
                                 s::T,
                                 is_leaf::F,
                                 _basename::S) where {S,T,F<:Function}
  fns = fieldnames(T)
  for fn in fns
    prop = getproperty(s, fn)
    if any(is_leaf(s, prop))
      k = _basename*"."*string(fn)
      println(io, "$k = $(D[k])")
    else
      export_dict_single_file(io, D, prop, is_leaf, _basename*"."*string(fn))
    end
  end
end

function export_dict_alternative(D::Dict, et::AbstractFilterTypes, outstyle::SingleFile)
  is_leaf(s, prop) = __is_leaf(s, prop, leaf_filter(et), ft)
  open(outstyle.filename,"w") do io
    for (k,v) in D
      any(is_leaf(nothing, v)) && println(io, "$k = $v")
    end
  end
end

#####
##### FolderStructure IO
#####

get_path(prop_chain) = joinpath(split(prop_chain, ".")[1:end-1]...)
get_varname(prop_chain) = split(prop_chain, ".")[end]

function export_dict(D::Dict, et::AbstractFilterTypes, outstyle::FolderStructure)
  mkpath(outstyle.root_folder)
  D_paths = Dict([get_path(k) => [] for k in keys(D)])
  for (k,v) in D
    kp = get_path(k)
    var = get_varname(k)
    push!(D_paths[kp], (var, D[k]))
  end

  for (path,arr) in D_paths
    _fullpath = joinpath(outstyle.root_folder, path)
    mkpath(_fullpath)
    open(joinpath(_fullpath, outstyle.filename), "w") do io
      for tup in arr
        println(io, "$(tup[1]) = $(tup[2])")
      end
    end
  end
end

function export_dict(D::Dict, et::AbstractFilterTypes, outstyle::SingleFile)
  open(outstyle.filename, "w") do io
    for (k,v) in D
      println(io, "$k = $v")
    end
  end
end
