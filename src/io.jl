#####
##### Shared IO functions
#####

export EntireStruct, FreeParametersOnly
export SingleFile, FolderStructure

struct FolderStructure end
struct SingleFile end

abstract type ExportType end
struct EntireStruct <: ExportType end
struct FreeParametersOnly <: ExportType end

function get_val_from_var(var::AbstractString)
  e = Meta.parse(var)
  if isbits(e) # var = "2.0" (for example)
    val = e
  else # var = "FreeParameter(...)" (for example)
    val = eval(e.args[1].args[1])(e.args[2:end]...)
  end
  return val
end

leaf_filter(::EntireStruct) = x -> isbits(x)
leaf_filter(::FreeParametersOnly) = x -> x isa FreeParameter
