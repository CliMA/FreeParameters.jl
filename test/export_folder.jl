
filename = "params.jl"
output = joinpath(@__DIR__,"..","output","folder")
mkpath(output)

@testset "Export folder: entire struct" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)
  subfolder = joinpath(output, "EntireStruct")

  export_struct(gmodel, subfolder, EntireStruct(), FolderStructure(), filename)

  @FreeParameter(gmodel.x, Distributions.Normal)
  @FreeParameter(gmodel.a.x)
  @FreeParameter(gmodel.a.i)

  @test ispath(subfolder)
  @test ispath(joinpath(subfolder,"Foo"))
  @test ispath(joinpath(subfolder,"Foo","a"))
  @test ispath(joinpath(subfolder,"Foo","a","fb"))

  @test isfile(joinpath(subfolder,"Foo", filename))
  @test isfile(joinpath(subfolder,"Foo","a", filename))
  @test isfile(joinpath(subfolder,"Foo","a","fb", filename))
end

@testset "Export folder: fp only" begin
  pmodel = Model.m
  subfolder = joinpath(output, "FreeParametersOnly")
  gmodel = generic_type(Params, pmodel)

  @FreeParameter(gmodel.x, Distributions.Normal)
  @FreeParameter(gmodel.a.x)
  @FreeParameter(gmodel.a.i)

  export_struct(gmodel, subfolder, FreeParametersOnly(), FolderStructure(), filename)

  @test ispath(subfolder)
  @test ispath(joinpath(subfolder,"Foo"))
  @test ispath(joinpath(subfolder,"Foo","a"))

  @test isfile(joinpath(subfolder,"Foo", filename))
  @test isfile(joinpath(subfolder,"Foo","a", filename))
  @test !ispath(joinpath(subfolder,"Foo","a", "fb"))
  @test !isfile(joinpath(subfolder,"Foo","a","fb", filename)) # No free paramters exist in FooBar:
  @test !ispath(joinpath(subfolder,"Foo","a","fb", "i")) # Should be caught by fb
  @test !ispath(joinpath(subfolder,"Foo","a","fb", "x")) # Should be caught by fb
end
