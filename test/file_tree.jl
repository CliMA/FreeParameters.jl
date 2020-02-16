
fext = ".json"

@testset "Export: isbits" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)

  export_struct_recursive(gmodel, "isbits")
  @FreeParameter(gmodel.x, Distributions.Normal)
  @FreeParameter(gmodel.a.x)
  @FreeParameter(gmodel.a.i)
  @test ispath(joinpath("isbits"))
  @test ispath(joinpath("isbits","Foo"))
  @test ispath(joinpath("isbits","Foo","Bar"))
  @test ispath(joinpath("isbits","Foo","Bar","FooBar"))

  @test isfile(joinpath("isbits","Foo","params$fext"))
  @test isfile(joinpath("isbits","Foo","Bar","params$fext"))
  @test isfile(joinpath("isbits","Foo","Bar","FooBar","params$fext"))
end

@testset "Export: fp" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)

  @FreeParameter(gmodel.x, Distributions.Normal)
  @FreeParameter(gmodel.a.x)
  @FreeParameter(gmodel.a.i)
  export_free_params_recursive(gmodel, ".")
  @test ispath(joinpath("Foo"))
  @test ispath(joinpath("Foo","Bar"))
  @test ispath(joinpath("Foo","Bar", "FooBar"))

  @test isfile(joinpath("Foo","params$fext"))
  @test isfile(joinpath("Foo","Bar","params$fext"))
  @test !isfile(joinpath("Foo","FooBar","params$fext")) # No free paramters exist in FooBar:
end

@testset "Import: isbits" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)

  # export gmodel
  export_free_params_recursive(gmodel, "isbits")

  # Change gmodel
  gmodel.a.x = 200.0
  gmodel.a.i = 200
  gmodel.x   = 200.0

  # Import gmodel
  import_struct_recursive!(gmodel, "isbits")

  # pmodel should match gmodel
  @test pmodel.a.x ≈ gmodel.a.x
  @test pmodel.a.i == gmodel.a.i
  @test pmodel.x   ≈ gmodel.x
end

@testset "Import: fp" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)

  @FreeParameter(gmodel.x, Distributions.Normal)
  @FreeParameter(gmodel.a.i)

  # export gmodel
  export_free_params_recursive(gmodel, ".")

  # Change gmodel
  gmodel.a.i.val = 2*gmodel.a.i.val
  gmodel.x.val   = 2*gmodel.x.val

  # Import gmodel
  import_free_params_recursive!(gmodel, ".")

  # pmodel should match gmodel
  @test pmodel.a.x ≈ gmodel.a.x
  @test pmodel.a.i ≈ gmodel.a.i.val
  @test pmodel.x   ≈ gmodel.x.val
end
