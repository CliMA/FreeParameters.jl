#####
##### Export structs with `FreeParameter`s to   single file
#####

export export_struct, @export_struct
macro export_struct(s, filename, et, sf)
  obj_name = string(s)
  return esc(quote
               export_struct($s, $filename, $et, $sf, $obj_name)
             end)
end

function export_struct(s::T,
                       filename::S,
                       et::ExportType,
                       ::SingleFile,
                       obj_name::S,
                       stop_recursion_type=FreeParameter) where {S,T}
  open(filename,"w") do io
    export_struct_single_file(io, s, leaf_filter(et), stop_recursion_type, obj_name)
  end
end

function export_struct_single_file(io,
                                   s::T,
                                   is_leaf::F,
                                   stop_recursion_type,
                                   _fullname::S,
                                   fn_parent=nothing) where {S,T,F<:Function}
  name = fn_parent ≠ nothing ? _fullname*"."*fn_parent : _fullname
  for fn in fieldnames(T)
    prop = getproperty(s, fn)
    if is_leaf(prop) || prop isa stop_recursion_type
      println(io, "$(name).$(string(fn)) = $prop")
      # setproperty!(s, fn, eval(Meta.parse(last(split(readline(io), "=")))))
    end
  end
  for fn in fieldnames(T)
    prop = getproperty(s, fn)
    if !is_leaf(prop) && !(prop isa stop_recursion_type)
      export_struct_single_file(io, prop, is_leaf, stop_recursion_type, name, string(fn))
    end
  end
end
