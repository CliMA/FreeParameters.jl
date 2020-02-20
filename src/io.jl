#####
##### IO of structs with `FreeParameter`s
#####

export export_struct, import_struct!
export EntireStruct, FreeParametersOnly
export write_data

abstract type ExportType end
struct EntireStruct <: ExportType end
struct FreeParametersOnly <: ExportType end

using JSON

const params_ext = ".json"

function write_data(data::T, filename::S) where {S,T}
  open(filename*params_ext,"w") do io
    D = Dict(string(k)=>string(v) for (k,v) in data)
    JSON.print(io, D, 4)
  end
end
function read_data!(data::T, filename::S) where {S,T}
  contents = open(f->read(f, String), filename*params_ext)
  parsed_JSON = JSON.parse(contents)
  for (k,v) in data
    val = parsed_JSON[string(k)]
    e = Meta.parse(val)
    if isbits(e)
      data[k] = e
    else # FreeParameter
      data[k] = eval(e.args[1].args[1])(e.args[2:end]...)
    end
  end
  return nothing
end

leaf_filter(::EntireStruct) = x -> isbits(x)
leaf_filter(::FreeParametersOnly) = x -> x isa FreeParameter

function export_struct(s::T, directory::S, et::ExportType, stop_recursion_type, filter_type) where {S,T,F<:Function}
  return export_struct(s, directory, leaf_filter(et), stop_recursion_type=FreeParameter, filter_type=Any)
end
function import_struct!(s::T, directory::S, et::ExportType, stop_recursion_type, filter_type) where {S,T,F<:Function}
  return import_struct!(s, directory, leaf_filter(et), stop_recursion_type=FreeParameter, filter_type=Any)
end

"""
    export_struct(s::T, directory::S) where {S,T}

Export struct `s` to directory `directory`
with the same structure as `s`.

 - `stop_recursion_type` stop recursion when reaching type `stop_recursion_type`
 - `filter_type` only export type `filter_type`
"""
function export_struct(s::T,
                       directory::S,
                       is_leaf::F,
                       stop_recursion_type,
                       filter_type,
                       _parent=Any) where {S,T,F<:Function}
  subdir = string(FreeParameters.strip_type(T))
  dir = joinpath(directory, subdir)
  params = joinpath(dir, "params")
  mkpath(dir)
  D = Dict( [fn => getproperty(s, fn) for fn in fieldnames(T)] )
  filter!(x-> is_leaf(x.second), D)
  if s isa filter_type
    !isempty(D) && write_data(D, params)
  end
  if !(_parent isa stop_recursion_type)
    for fn in fieldnames(T)
      prop = getproperty(s, fn)
      if !isbits(prop) && !is_leaf(prop)
        export_struct(prop, dir, is_leaf, stop_recursion_type, filter_type, _parent)
      end
    end
  end
end

"""
    import_struct!(s::T, directory::S) where {S,T}

Import struct `s` to directory `directory`
with the same structure as `s`.
"""
function import_struct!(s::T,
                        directory::S,
                        is_leaf::F,
                        stop_recursion_type,
                        filter_type,
                        _parent=Any) where {S,T,F<:Function}
  subdir = string(FreeParameters.strip_type(T))
  dir = joinpath(directory, subdir)
  params = joinpath(dir, "params")
  D = Dict( [fn => getproperty(s, fn) for fn in fieldnames(T)] )
  filter!(p -> is_leaf(p.second), D)
  if !isempty(D)
    read_data!(D, params)
    for fn in fieldnames(T)
      prop = getproperty(s, fn)
      is_leaf(prop) && setproperty!(s, fn, D[fn])
    end
  end
  if !(_parent isa stop_recursion_type)
    for fn in fieldnames(T)
      prop = getproperty(s, fn)
      if !isbits(prop)
        import_struct!(prop, dir, is_leaf, stop_recursion_type, filter_type, _parent)
      end
    end
  end
end

