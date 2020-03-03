#####
##### Import dict: SingleFile
#####

export import_dict

function import_dict(D::Dict, outstyle::SingleFile, ft::AbstractFilterTypes=EntireStruct())
  is_leaf(s, prop) = __is_leaf(s, prop, ft)
  if !isempty([triggers(is_leaf(nothing, v)) for v in values(D)])
    open(outstyle.filename,"r") do io
      for (k,v) in D
        if triggers(is_leaf(nothing, v))
          val_s = strip(last(split(readline(io), "=")), ' ')
          D[k] = get_val_from_var(val_s)
        end
      end
    end
  end
end

#####
##### Import dict: FolderStructure
#####

function import_dict(D::Dict, outstyle::FolderStructure, ft::AbstractFilterTypes=EntireStruct())
  get_path(prop_chain) = joinpath(split(prop_chain, ".")[1:end-1]...)
  get_prop_chain_root(k) = join(split(k, ".")[1:end-1]...)
  get_varname(prop_chain) = split(prop_chain, ".")[end]
  is_leaf(s, prop) = __is_leaf(s, prop, ft)
  mkpath(outstyle.root_folder)
  D_paths = Dict([get_path(k) => [] for k in keys(D)])
  for (k,v) in D
    kp = get_path(k)
    var = get_varname(k)
    push!(D_paths[kp], (var, get_prop_chain_root(k), D[k]))
  end

  for (path,arr) in D_paths
    _fullpath = joinpath(outstyle.root_folder, path)
    folder_needed = [triggers(is_leaf(nothing, val)) for (var, pcr, val) in arr]
    if any(folder_needed)
      mkpath(_fullpath)
      open(joinpath(_fullpath, outstyle.filename), "r") do io
        for (var, prop_chain_root, val) in arr
          if triggers(is_leaf(nothing, val))
            D[prop_chain_root*"."*k] = get_val_from_var(strip(last(split(readline(io), "=")), ' '))
          end
        end
      end
    end
  end
end
