#####
##### IO of structs with `FreeParameter`s
#####

export export_struct, import_struct!
export EntireStruct, FreeParametersOnly

struct EntireStruct end
struct FreeParametersOnly end

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

export_struct(s::T, directory::S, ::EntireStruct) where {S,T,F} = export_struct(s, directory, x -> isbits(x))
export_struct(s::T, directory::S, ::FreeParametersOnly) where {S,T,F} = export_struct(s, directory, x -> x isa FreeParameter)
import_struct!(s::T, directory::S, ::EntireStruct) where {S,T,F} = import_struct!(s, directory, x -> isbits(x))
import_struct!(s::T, directory::S, ::FreeParametersOnly) where {S,T,F} = import_struct!(s, directory, x -> x isa FreeParameter)

"""
    export_struct(s::T, directory::S) where {S,T}

Export struct `s` to directory `directory`
with the same structure as `s`.
"""
function export_struct(s::T, directory::S, cond::F) where {S,T,F}
  subdir = string(FreeParameters.strip_type(T))
  dir = joinpath(directory, subdir)
  params = joinpath(dir, "params")
  mkpath(dir)
  D = Dict( [fn => getproperty(s, fn) for fn in fieldnames(T)] )
  filter!(x-> cond(x.second), D)
  !isempty(D) && write_data(D, params)
  for fn in fieldnames(T)
    prop = getproperty(s, fn)
    if !isbits(prop) && ! cond(prop)
      export_struct(prop, dir, cond)
    end
  end
end

"""
    import_struct!(s::T, directory::S) where {S,T}

Import struct `s` to directory `directory`
with the same structure as `s`.
"""
function import_struct!(s::T, directory::S, cond::F) where {S,T,F}
  subdir = string(FreeParameters.strip_type(T))
  dir = joinpath(directory, subdir)
  params = joinpath(dir, "params")
  D = Dict( [fn => getproperty(s, fn) for fn in fieldnames(T)] )
  filter!(p -> cond(p.second), D)
  if !isempty(D)
    read_data!(D, params)
    for fn in fieldnames(T)
      prop = getproperty(s, fn)
      cond(prop) && setproperty!(s, fn, D[fn])
    end
  end
  for fn in fieldnames(T)
    prop = getproperty(s, fn)
    if !isbits(prop)
      import_struct!(prop, dir, cond)
    end
  end
end

