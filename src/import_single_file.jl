#####
##### Import structs with `FreeParameter`s from single file
#####

export import_struct, @import_struct
macro import_struct(s, sf, ft)
  obj_name = string(s)
  return esc(quote
               import_struct($s, $sf, $obj_name, $ft)
             end)
end

function import_struct(s::T,
                       sf::SingleFile,
                       obj_name::S,
                       ft::AbstractFilterTypes=EntireStruct()) where {S,T}
  is_leaf(s, prop) = __is_leaf(s, prop, leaf_filter(ft), ft)
  open(sf.filename,"r") do io
    import_struct_single_file(io, s, is_leaf, obj_name)
  end
end

function import_struct_single_file(io,
                                   s::T,
                                   is_leaf::F,
                                   _fullname::S,
                                   fn_parent=nothing) where {S,T,F<:Function}
  name = fn_parent ≠ nothing ? _fullname*"."*fn_parent : _fullname
  fns = fieldnames(T)
  for fn in fns
    prop = getproperty(s, fn)
    if any(is_leaf(s, prop))
      # println(io, "$(name).$(string(fn)) = $prop")
      setproperty!(s, fn, get_val_from_var(strip(last(split(readline(io), "=")), ' ')))
    else
      import_struct_single_file(io, prop, is_leaf, name, string(fn))
    end
  end
end
