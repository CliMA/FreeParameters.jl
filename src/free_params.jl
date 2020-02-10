using SyntaxTree

export FreeParameter, @FreeParameter

export generic_type,
       extract_free_parameters,
       parametric_type

const FPTYPES = Real

"""
    FreeParameter{T,P,B} <: FPTYPES

Free parameter of type `T` and prior `P`.
"""
mutable struct FreeParameter{T,P,B} <: FPTYPES
  "Value used in the model"
  val::T
  "prior distribution"
  prior::P
  "bounds on value used"
  bounds::B
  function FreeParameter(val::T,
                         prior::P=nothing,
                         bounds::B=nothing
                         ) where {T,P,B}
    return new{T,P,B}(val, prior, bounds)
  end
end

#####
##### Extracting free parameters
#####

"""
    extract_free_parameters!(fp::Vector{FreeParameter}, s)

Recursively extract a vector of `FreeParameter`'s
from the struct `s`.
"""
function extract_free_parameters!(fp::Vector{FreeParameter}, s)
  for fn in fieldnames(typeof(s))
    p = getproperty(s,fn)
    if typeof(p) <: FreeParameter
      push!(fp, p)
    else
      extract_free_parameters!(fp, p)
    end
  end
  return nothing
end

function extract_free_parameters(s)
  fp = FreeParameter[]
  extract_free_parameters!(fp, s)
  return fp
end

#####
##### Generating generic data structures
#####

"""
    get_type(s, fns)

Expression of definition of
struct `s` with fieldnames `fns`
"""
function get_type(s, fns)
  expr = quote mutable struct $(s) end end
  a = expr.args[2].args[3].args
  for fn in fns
    push!(a, fn, LineNumberNode)
  end
  return expr
end

"""
    strip_type(T)

Removes, for example, `Main.MyMod` from `Main.MyMod.Foo`

# TODO: must be a better way, AST?
"""
strip_type(T) = Symbol(last(split(string(Symbol(T)),".")))

"""
    define_type(_module::Module, Tname, fns)

Define struct `s` with fieldnames `fns`
in module `_module`.
"""
function define_type(_module::Module, Tname, fns)
  s_mod = strip_type(Tname) # remove prepending module
  e = get_type(s_mod, fns)
  _module.eval(e.args[2])
end

"""
    define_generic_type(_module::Module, s::T) where {T}

Define struct `s` in module `_module`
_without_ parameters.
"""
function define_generic_type(_module::Module, s::T) where {T}
  if !isprimitivetype(T)
    fns = fieldnames(T)
    define_type(_module, T.name, fns)
    for fn in fns
      prop = getproperty(s, fn)
      define_generic_type(_module, prop)
    end
  end
  return nothing
end

"""
    get_type_instance(T, fields; strip_module=true)

Expression of instance of type `T` with fields `fields`
"""
function get_type_instance(T, fields; strip_module=true)
  T_mod = T
  strip_module && (T_mod = strip_type(T)) # remove prepending module
  expr = quote $(T_mod)() end |> SyntaxTree.linefilter!
  a = expr.args[1].args
  for field in fields
    push!(a, field)
  end
  return expr
end

"""
    _generic_type(_module::Module, s::T) where {T}

Instance of generic struct in module
`_module` that matches the structure
of the parametric struct `s`.
"""
function _generic_type(_module::Module, s::T) where {T}
  if !isprimitivetype(T)
    fns = fieldnames(T)
    props = [_generic_type(_module, prop) for prop in getproperty.(Ref(s), fns)]
    e = get_type_instance(T.name, props)
    return _module.eval(e)
  else
    return s
  end
end

"""
    generic_type(_module::Module, s)

Define and instantiate generic struct in
module `_module` that matches the structure
of the parametric struct `s`.
"""
function generic_type(_module::Module, s)
  define_generic_type(_module, s)
  return _generic_type(_module, s)
end

#####
##### Annotating free parameters
#####

macro FreeParameter(s, prior=nothing, bounds=nothing)
  e = :($(s) = FreeParameter($(s), $(prior), $(bounds)))
  return :($(esc(e)))
end

#####
##### Generating parametric data structures
#####

"""
    get_val(x)

Gets value of `FreeParameter`,
otherwise return identity.
"""
function get_val end
get_val(x) = x
get_val(x::FreeParameter) = x.val

"""
    map_struct_recursive!(f::F, s::T) where {T,F}

Apply function `f` to properties
of mutable struct `s` recursively.

If `T isa FreeParameter`, skip to avoid
assumptions on its properties.
"""
function map_struct_recursive!(f::F, s::T) where {F,T}
  for fn in fieldnames(T)
    prop = getproperty(s, fn)
    setproperty!(s, fn, f(prop))
    map_struct_recursive!(f, prop)
  end
end
map_struct_recursive!(f::F, s::T) where {F,T<:FreeParameter} = nothing


"""
    _parametric_type(_module::Module, s::T, sg::TG) where {T,TG}

Instance of parametric type `T`, defined in module
`_module`, from generic struct `sg`.
"""
function _parametric_type(_module::Module, s::T, sg::TG) where {T,TG}
  if !isprimitivetype(T)
    props_old = getproperty.(Ref(s), fieldnames(T))
    gprops = getproperty.(Ref(sg), fieldnames(TG))
    Z = zip(props_old, gprops)
    props_new = [_parametric_type(_module, prop, gprop) for (prop,gprop) in Z]
    e = get_type_instance(T,props_new;strip_module=false)
    return _module.eval(e)
  else
    return sg
  end
end

"""
    parametric_type(_module::Module, s::T, sg::TG) where {T,TG}

Instance of parametric type `T`, defined in module
`_module`, from generic struct `sg`.

First, get values from `FreeParameter`'s.
"""
function parametric_type(_module::Module, s::T, sg::TG) where {T,TG}
  tmp = deepcopy(sg)
  map_struct_recursive!(get_val, tmp)
  return _parametric_type(_module, s, tmp)
end
