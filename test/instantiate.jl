
@testset "instantiate: toy model all, without free parameters" begin
  pmodel = Model.m
  D = @struct_2_dict(pmodel)
  D["pmodel.a.x"] = 100.0
  pmodel_new = instantiate(pmodel, D, EntireStruct())
  @test pmodel_new.a.x ≈ 100.0
end

@testset "instantiate: toy model all, with free parameters" begin
  pmodel = Model.m
  D = @struct_2_dict(pmodel)
  D["pmodel.a.x"] = 100.0
  @free D["pmodel.a.x"]
  pmodel_new = instantiate(pmodel, D, EntireStruct())
  @test pmodel_new.a.x ≈ 100.0
end

@testset "instantiate: toy model fp, with free parameters" begin
  pmodel = Model.m
  D = @struct_2_dict(pmodel)
  D["pmodel.a.x"] = 100.0
  @free D["pmodel.a.x"]
  D["pmodel.x"] = 100.0
  pmodel_new = instantiate(pmodel, D, FreeParametersOnly())
  @test pmodel_new.a.x ≈ 100.0
  @test pmodel_new.x ≈ pmodel.x
end

######
###### Complex model
######

@testset "instantiate: complex model, single file" begin
  pmodel = DycomsModel.model
  D = @struct_2_dict(pmodel)

  sf = SingleFile(joinpath(output,"real_model_fp.jl"))

  @free D["pmodel.turbulence.C_smag"] Distributions.Normal
  @free D["pmodel.boundarycondition.C_drag"]
  export_dict(D, sf, FreeParametersOnly())

  # contents = open(f->read(f, String), sf.filename)
  # Manually adjust file:
  contents = "pmodel.turbulence.C_smag = FreeParameter{Float32,UnionAll,Nothing}(500, Normal, nothing)\npmodel.boundarycondition.C_drag = FreeParameter{Float32,Nothing,Nothing}(500, nothing, nothing)\n"
  open(sf.filename, "w") do io
    print(io, contents)
  end

  # Last bit to get working:
  import_dict(D, sf, FreeParametersOnly())
  @test FreeParameters.get_val(D["pmodel.turbulence.C_smag"]) ≈ 500
  @test FreeParameters.get_val(D["pmodel.boundarycondition.C_drag"]) ≈ 500

  pmodel_new = instantiate(pmodel, D, FreeParametersOnly())
  @test pmodel_new.turbulence.C_smag ≈ 500
  @test pmodel_new.boundarycondition.C_drag ≈ 500
end
