#####
##### Annotate free parameters in dict
#####

export @free

macro free(s, prior=nothing, bounds=nothing)
  e = :($s = FreeParameter($(s), $(prior), $(bounds)))
  return :($(esc(e)))
end
