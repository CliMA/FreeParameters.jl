#####
##### Import structs with `FreeParameter`s in folder structured format
#####
using Base.Iterators
export import_struct

"""
    import_struct(s::T, directory::S) where {S,T}

Import struct `s` to directory `directory`
with the same structure as `s`.
"""
function import_struct(s::T, fs::FolderStructure, ft::AbstractFilterTypes) where {S,T,F<:Function}
  is_leaf(s, prop) = __is_leaf_old(s, prop, ft)
  return import_struct_folder(s, fs.root_folder, is_leaf, fs.filename)
end

function import_struct_folder(s::T,
                              directory::S,
                              is_leaf::F,
                              _filename::S,
                              subdir::S="",
                              fn_parent=nothing) where {S,T,F<:Function}
  subdir = fn_parent==nothing ? string(nameof(T)) : joinpath(subdir,string(fn_parent))
  fns = fieldnames(T)
  props = getproperty.(Ref(s), fns)
  if any(triggers.(is_leaf.(Ref(s), props)))
    dir_used = joinpath(directory, subdir)
    # mkpath(dir_used)
    params = joinpath(dir_used, _filename)
    open(params, "r") do io
      for fn in fns
        prop = getproperty(s, fn)
        if triggers(is_leaf(s, prop))
          setproperty!(s, fn, get_val_from_var(strip(last(split(readline(io), "=")), ' ')))
        end
      end
    end
  end

  for fn in fns
    prop = getproperty(s, fn)
    if !triggers(is_leaf(s, prop))
      import_struct_folder(prop, directory, is_leaf, _filename, subdir, fn)
    end
  end
end
