#####
##### Shared IO functions
#####

export OutputStyle, SingleFile, FolderStructure

abstract type OutputStyle end

struct FolderStructure <: OutputStyle
  root_folder
  filename
end
FolderStructure() = FolderStructure(nothing, nothing)

struct SingleFile <: OutputStyle
  filename
end
SingleFile() = SingleFile(nothing)

