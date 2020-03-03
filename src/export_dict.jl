#####
##### Export dict: SingleFile
#####

export export_dict

function export_dict(D::Dict, outstyle::SingleFile, ft::AbstractFilterTypes=EntireStruct())
  is_leaf(s, prop) = __is_leaf(s, prop, ft)
  if !isempty([triggers(is_leaf(nothing, v)) for v in values(D)])
    open(outstyle.filename,"w") do io
      for (k,v) in D
        if triggers(is_leaf(nothing, v))

          println(io, "$k = $v")
        end
      end
    end
  end
end

#####
##### Export dict: FolderStructure
#####

function export_dict(D::Dict, outstyle::FolderStructure, ft::AbstractFilterTypes=EntireStruct())
  get_path(prop_chain) = joinpath(split(prop_chain, ".")[1:end-1]...)
  get_prop_chain_root(k) = join(split(k, ".")[1:end-1]...)
  get_varname(prop_chain) = split(prop_chain, ".")[end]
  is_leaf(s, prop) = __is_leaf(s, prop, ft)
  mkpath(outstyle.root_folder)
  D_paths = Dict([get_path(k) => [] for k in keys(D)])
  for (k,v) in D
    kp = get_path(k)
    var = get_varname(k)
    push!(D_paths[kp], (var, D[k]))
  end

  for (path,arr) in D_paths
    _fullpath = joinpath(outstyle.root_folder, path)
    folder_needed = [triggers(is_leaf(nothing, val)) for (varname, val) in arr]
    if any(folder_needed)
      mkpath(_fullpath)
      open(joinpath(_fullpath, outstyle.filename), "w") do io
        for (varname, val) in arr
          if triggers(is_leaf(nothing, val))
            println(io, "$varname = $val")
          end
        end
      end
    end
  end
end
