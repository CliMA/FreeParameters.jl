
@testset "instantiate: all, without free parameters" begin
  pmodel = Model.m
  D = @struct_2_dict(pmodel)
  D["pmodel.a.x"] = 100.0
  pmodel_new = instantiate(pmodel, D, EntireStruct())
  @test pmodel_new.a.x ≈ 100.0
end

@testset "instantiate: all, with free parameters" begin
  pmodel = Model.m
  D = @struct_2_dict(pmodel)
  D["pmodel.a.x"] = 100.0
  @free D["pmodel.a.x"]
  pmodel_new = instantiate(pmodel, D, EntireStruct())
  @test pmodel_new.a.x ≈ 100.0
end

@testset "instantiate: fp, with free parameters" begin
  pmodel = Model.m
  D = @struct_2_dict(pmodel)
  D["pmodel.a.x"] = 100.0
  @free D["pmodel.a.x"]
  D["pmodel.x"] = 100.0
  pmodel_new = instantiate(pmodel, D, FreeParametersOnly())
  @test pmodel_new.a.x ≈ 100.0
  @test pmodel_new.x ≈ pmodel.x
end

