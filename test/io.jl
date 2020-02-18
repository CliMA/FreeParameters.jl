
fext = ".json"

@testset "Export: entire struct" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)

  export_struct(gmodel, "EntireStruct", EntireStruct())
  @FreeParameter(gmodel.x, Distributions.Normal)
  @FreeParameter(gmodel.a.x)
  @FreeParameter(gmodel.a.i)
  @test ispath(joinpath("EntireStruct"))
  @test ispath(joinpath("EntireStruct","Foo"))
  @test ispath(joinpath("EntireStruct","Foo","Bar"))
  @test ispath(joinpath("EntireStruct","Foo","Bar","FooBar"))

  @test isfile(joinpath("EntireStruct","Foo","params$fext"))
  @test isfile(joinpath("EntireStruct","Foo","Bar","params$fext"))
  @test isfile(joinpath("EntireStruct","Foo","Bar","FooBar","params$fext"))
end

@testset "Export: fp only" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)

  @FreeParameter(gmodel.x, Distributions.Normal)
  @FreeParameter(gmodel.a.x)
  @FreeParameter(gmodel.a.i)
  export_struct(gmodel, "FreeParametersOnly", FreeParametersOnly())
  @test ispath(joinpath("FreeParametersOnly","Foo"))
  @test ispath(joinpath("FreeParametersOnly","Foo","Bar"))
  @test ispath(joinpath("FreeParametersOnly","Foo","Bar", "FooBar"))

  @test isfile(joinpath("FreeParametersOnly","Foo","params$fext"))
  @test isfile(joinpath("FreeParametersOnly","Foo","Bar","params$fext"))
  @test !isfile(joinpath("FreeParametersOnly","Foo","FooBar","params$fext")) # No free paramters exist in FooBar:
end

@testset "Import: entire struct" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)

  # export gmodel
  export_struct(gmodel, "EntireStruct", EntireStruct())

  # Change gmodel
  gmodel.a.x = 200.0
  gmodel.a.i = 200
  gmodel.x   = 200.0

  # Import gmodel
  import_struct!(gmodel, "EntireStruct", EntireStruct())

  # pmodel should match gmodel
  @test pmodel.a.x ≈ gmodel.a.x
  @test pmodel.a.i == gmodel.a.i
  @test pmodel.x   ≈ gmodel.x
end

@testset "Import: fp only" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)

  @FreeParameter(gmodel.x, Distributions.Normal)
  @FreeParameter(gmodel.a.i)

  # export gmodel
  export_struct(gmodel, "FreeParametersOnly", FreeParametersOnly())

  # Change gmodel
  gmodel.a.i.val = 2*gmodel.a.i.val
  gmodel.x.val   = 2*gmodel.x.val

  # Import gmodel
  import_struct!(gmodel, "FreeParametersOnly", FreeParametersOnly())

  # pmodel should match gmodel
  @test pmodel.a.x ≈ gmodel.a.x
  @test pmodel.a.i ≈ gmodel.a.i.val
  @test pmodel.x   ≈ gmodel.x.val
end
