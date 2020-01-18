export FreeParameter
export extract_free_parameters

"""
    AbstractFreeParameter{T}

Abstract free parameter with type `T`
"""
abstract type AbstractFreeParameter{T} end

mutable struct FreeParameter{T} <: AbstractFreeParameter{T}
  val::T
  hi::T
  lo::T
end

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
