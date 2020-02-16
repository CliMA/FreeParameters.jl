#####
##### IO of structs with `FreeParameter`s
#####

export export_struct_recursive
export export_free_params_recursive
export import_struct_recursive!
export import_free_params_recursive!

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

"""
    export_struct_recursive(s::T, directory::S) where {S,T}

Export struct `s` to directory `directory`
with the same structure as `s`.
"""
function export_struct_recursive(s::T, directory::S) where {S,T}
  subdir = string(FreeParameters.strip_type(T))
  dir = joinpath(directory, subdir)
  params = joinpath(dir, "params")
  mkpath(dir)
  D = Dict( [fn => getproperty(s, fn) for fn in fieldnames(T)] )
  filter!(p -> isbits(p.second), D)
  !isempty(D) && write_data(D, params)
  for fn in fieldnames(T)
    prop = getproperty(s, fn)
    if !isbits(prop)
      export_struct_recursive(prop, dir)
    end
  end
end

"""
    export_free_params_recursive(s::T, directory::S) where {S,T}

Export struct `s` to directory `directory`
with the same structure as `s`.
"""
function export_free_params_recursive(s::T, directory::S) where {S,T}
  subdir = string(FreeParameters.strip_type(T))
  dir = joinpath(directory, subdir)
  params = joinpath(dir, "params")
  mkpath(dir)
  D = Dict( [fn => getproperty(s, fn) for fn in fieldnames(T)] )
  filter!(p -> p.second isa FreeParameter, D)
  !isempty(D) && write_data(D, params)
  for fn in fieldnames(T)
    prop = getproperty(s, fn)
    if !(prop isa FreeParameter) && !isbits(prop)
      export_free_params_recursive(prop, dir)
    end
  end
end

"""
    import_struct_recursive!(s::T, directory::S) where {S,T}

Import struct `s` to directory `directory`
with the same structure as `s`.
"""
function import_struct_recursive!(s::T, directory::S) where {S,T}
  subdir = string(FreeParameters.strip_type(T))
  dir = joinpath(directory, subdir)
  params = joinpath(dir, "params")
  D = Dict( [fn => getproperty(s, fn) for fn in fieldnames(T)] )
  filter!(p -> isbits(p.second), D)
  if !isempty(D)
    read_data!(D, params)
    for fn in fieldnames(T)
      prop = getproperty(s, fn)
      isbits(prop) && setproperty!(s, fn, D[fn])
    end
  end
  for fn in fieldnames(T)
    prop = getproperty(s, fn)
    if !isbits(prop)
      import_struct_recursive!(prop, dir)
    end
  end
end

"""
    import_free_params_recursive!(s::T, directory::S) where {S,T}

Import struct `s` to directory `directory`
with the same structure as `s`.
"""
function import_free_params_recursive!(s::T, directory::S) where {S,T}
  subdir = string(FreeParameters.strip_type(T))
  dir = joinpath(directory, subdir)
  params = joinpath(dir, "params")
  D = Dict( [fn => getproperty(s, fn) for fn in fieldnames(T)] )
  filter!(p -> p.second isa FreeParameter, D)
  if !isempty(D)
    read_data!(D, params)
    for fn in fieldnames(T)
      prop = getproperty(s, fn)
      prop isa FreeParameter && setproperty!(s, fn, D[fn])
    end
  end
  for fn in fieldnames(T)
    prop = getproperty(s, fn)
    if !isbits(prop)
      import_free_params_recursive!(prop, dir)
    end
  end
end

