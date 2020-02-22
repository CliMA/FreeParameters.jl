
filename = "params.jl"
output = joinpath(@__DIR__,"..","output","folder")
mkpath(output)

@testset "Import folder: entire struct" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)

  # export gmodel
  export_struct(gmodel, joinpath(output,"EntireStruct"), EntireStruct(), FolderStructure(), filename)

  # Change gmodel
  gmodel.a.x = 200.0
  gmodel.a.i = 200
  gmodel.x   = 200.0

  # Import gmodel
  import_struct(gmodel, joinpath(output,"EntireStruct"), EntireStruct(), FolderStructure(), filename)

  # pmodel should match gmodel
  @test pmodel.a.x ≈ gmodel.a.x
  @test pmodel.a.i == gmodel.a.i
  @test pmodel.x   ≈ gmodel.x
end

@testset "Import folder: fp only" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)

  @FreeParameter(gmodel.x, Distributions.Normal)
  @FreeParameter(gmodel.a.i)

  # export gmodel
  export_struct(gmodel, joinpath(output,"FreeParametersOnly"), FreeParametersOnly(), FolderStructure(), filename)

  # Change gmodel
  gmodel.a.i.val = 2*gmodel.a.i.val
  gmodel.x.val   = 2*gmodel.x.val

  # Import gmodel
  import_struct(gmodel, joinpath(output,"FreeParametersOnly"), FreeParametersOnly(), FolderStructure(), filename)

  # pmodel should match gmodel
  @test pmodel.a.x ≈ gmodel.a.x
  @test pmodel.a.i ≈ gmodel.a.i.val
  @test pmodel.x   ≈ gmodel.x.val
end
