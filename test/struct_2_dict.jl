
fext = ".yml"

@testset "Struct 2 dict: without free parameters" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)
  D_EntireStruct = struct_2_dict(gmodel, EntireStruct())
  for (k,v) in D_EntireStruct
    println("D_EntireStruct[$k] = $v")
  end
  @test !isempty(D_EntireStruct)

  D_FreeParametersOnly = struct_2_dict(gmodel, FreeParametersOnly())
  for (k,v) in D_FreeParametersOnly
    println("D_FreeParametersOnly[$k] = $v")
  end
  # write_data(D_EntireStruct, "parameters")
  @test isempty(D_FreeParametersOnly)
end

@testset "Struct 2 dict: with free parameters" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)

  @FreeParameter(gmodel.x, Distributions.Normal)
  @FreeParameter(gmodel.a.x)
  # @FreeParameter(gmodel.a.i)

  D_EntireStruct = struct_2_dict(gmodel, EntireStruct())
  for (k,v) in D_EntireStruct
    println("D_EntireStruct[$k] = $v")
  end
  @test !isempty(D_EntireStruct)
  @test haskey(D_EntireStruct, "Foo.x")
  @test haskey(D_EntireStruct, "Foo.a.x")
  @test haskey(D_EntireStruct, "Foo.a.i")

  D_FreeParametersOnly = struct_2_dict(gmodel, FreeParametersOnly())
  for (k,v) in D_FreeParametersOnly
    println("D_FreeParametersOnly[$k] = $v")
  end
  # write_data(D_EntireStruct, "parameters")
  @test !isempty(D_FreeParametersOnly)
  @test haskey(D_FreeParametersOnly, "Foo.x")
  @test haskey(D_FreeParametersOnly, "Foo.a.x")
  @test !haskey(D_FreeParametersOnly, "Foo.a.i")
end

