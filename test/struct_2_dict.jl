
fext = ".yml"

@testset "Struct 2 dict: without free parameters" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)
  D_EntireStruct = struct_2_dict(gmodel, EntireStruct())
  for (k,v) in D_EntireStruct
    println("D_EntireStruct[$k] = $v")
  end
  D_FreeParametersOnly = struct_2_dict(gmodel, FreeParametersOnly())
  for (k,v) in D_FreeParametersOnly
    println("D_FreeParametersOnly[$k] = $v")
  end
  write_data(D_EntireStruct, "parameters")
  @test 1==1
end

@testset "Struct 2 dict: with free parameters" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)

  @FreeParameter(gmodel.x, Distributions.Normal)
  @FreeParameter(gmodel.a.x)
  # @FreeParameter(gmodel.a.i)
  @test 1==1

  D_EntireStruct = struct_2_dict(gmodel, EntireStruct())
  for (k,v) in D_EntireStruct
    println("D_EntireStruct[$k] = $v")
  end
  @test 1==1
  D_FreeParametersOnly = struct_2_dict(gmodel, FreeParametersOnly())
  @test 1==1
  for (k,v) in D_FreeParametersOnly
    println("D_FreeParametersOnly[$k] = $v")
  end
  write_data(D_EntireStruct, "parameters")
end

