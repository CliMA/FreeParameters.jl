#####
##### Import structs with `FreeParameter`s from single file
#####

export import_struct, @import_struct
macro import_struct(s, filename, et, sf)
  obj_name = string(s)
  return esc(quote
               import_struct($s, $filename, $et, $sf, $obj_name)
             end)
end

function import_struct(s::T,
                       filename::S,
                       et::ExportType,
                       ::SingleFile,
                       obj_name::S,
                       stop_recursion_type=FreeParameter) where {S,T}
  open(filename,"r") do io
    import_struct_single_file(io, s, leaf_filter(et), stop_recursion_type, obj_name)
  end
end

function import_struct_single_file(io,
                                   s::T,
                                   is_leaf::F,
                                   stop_recursion_type,
                                   _fullname::S,
                                   fn_parent=nothing) where {S,T,F<:Function}
  name = fn_parent ≠ nothing ? _fullname*"."*fn_parent : _fullname
  for fn in fieldnames(T)
    prop = getproperty(s, fn)
    if is_leaf(prop) || prop isa stop_recursion_type
      # println(io, "$(name).$(string(fn)) = $prop")
      setproperty!(s, fn, get_val_from_var(strip(last(split(readline(io), "=")), ' ')))
    end
  end
  for fn in fieldnames(T)
    prop = getproperty(s, fn)
    if !is_leaf(prop) && !(prop isa stop_recursion_type)
      import_struct_single_file(io, prop, is_leaf, stop_recursion_type, name, string(fn))
    end
  end
end
