#####
##### Export structs with `FreeParameter`s in folder structured format
#####
using Base.Iterators
export export_struct

"""
    export_struct(s::T, directory::S) where {S,T}

Export struct `s` to directory `directory`
with the same structure as `s`.
"""
function export_struct(s::T, fs::FolderStructure, ft::AbstractFilterTypes) where {S,T,F<:Function}
  is_leaf(s, prop) = __is_leaf_old(s, prop, leaf_filter(ft), ft)
  return export_struct_folder(s, fs.root_folder, is_leaf, fs.filename)
end

function export_struct_folder(s::T,
                              directory::S,
                              is_leaf::F,
                              _filename::S,
                              subdir::S="",
                              fn_parent=nothing) where {S,T,F<:Function}
  subdir = fn_parent==nothing ? string(nameof(T)) : joinpath(subdir,string(fn_parent))
  fns = fieldnames(T)
  props = getproperty.(Ref(s), fns)
  if any(Base.Iterators.flatten(is_leaf.(Ref(s), props)))
    dir_used = joinpath(directory, subdir)
    mkpath(dir_used)
    params = joinpath(dir_used, _filename)
    open(params, "w") do io
      for fn in fns
        prop = getproperty(s, fn)
        if any(is_leaf(s, prop))
          println(io, "$fn = $prop")
        end
      end
    end
  end

  for fn in fns
    prop = getproperty(s, fn)
    if !any(is_leaf(s, prop))
      export_struct_folder(prop, directory, is_leaf, _filename, subdir, fn)
    end
  end
end
