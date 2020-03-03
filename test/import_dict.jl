
output = joinpath(@__DIR__,"..","output")
mkpath(output)

@testset "import_dict: without free parameters" begin
  pmodel = Model.m
  D = @struct_2_dict(pmodel)

  sf = SingleFile(joinpath(output,"toy_model_all.jl"))
  export_dict(D, sf)

  contents = "pmodel.x = 500.0\npmodel.a.x = 500.0\npmodel.a.i = 500\npmodel.a.fb.x = 500.0\npmodel.a.fb.i = 500\n"
  open(sf.filename, "w") do io
    print(io, contents)
  end
  import_dict(D, sf, EntireStruct())
  @test D["pmodel.x"]      ≈ 500.0
  @test D["pmodel.x"]      ≈ 500.0
  @test D["pmodel.a.x"]    ≈ 500.0
  @test D["pmodel.a.i"]    ≈ 500
  @test D["pmodel.a.fb.x"] ≈ 500.0
  @test D["pmodel.a.fb.i"] ≈ 500
end

@testset "import_dict: with free parameters" begin
  pmodel = Model.m
  D = @struct_2_dict(pmodel)

  @free D["pmodel.x"] Distributions.Normal
  @free D["pmodel.a.x"]

  sf = SingleFile(joinpath(output,"toy_model_all.jl"))
  export_dict(D, sf)

  # contents = open(f->read(f, String), sf.filename)
  contents = "pmodel.a.fb.x = 500
pmodel.a.x = FreeParameter{Float64,Nothing,Nothing}(500, nothing, nothing)
pmodel.x = FreeParameter{Float64,UnionAll,Nothing}(500, Normal, nothing)
pmodel.a.i = 500
pmodel.a.fb.i = 500
"
  # Manually adjust file:
  open(sf.filename, "w") do io
    print(io, contents)
  end

  import_dict(D, sf, EntireStruct())
  @test FreeParameters.get_val(D["pmodel.x"]) ≈ 500
  @test FreeParameters.get_val(D["pmodel.a.x"]) ≈ 500
  @test D["pmodel.a.i"] ≈ 500
  @test D["pmodel.a.fb.x"] ≈ 500
  @test D["pmodel.a.fb.i"] ≈ 500
end

@testset "import_dict: with free parameters, subset" begin
  pmodel = Model.m
  D = @struct_2_dict(pmodel)

  @free D["pmodel.x"] Distributions.Normal
  @free D["pmodel.a.x"]

  sf = SingleFile(joinpath(output,"toy_model_all.jl"))
  export_dict(D, sf)

  # contents = open(f->read(f, String), sf.filename)
  contents = "pmodel.a.fb.x = 500
pmodel.a.x = FreeParameter{Float64,Nothing,Nothing}(500, nothing, nothing)
pmodel.x = FreeParameter{Float64,UnionAll,Nothing}(500, Normal, nothing)
pmodel.a.i = 500
pmodel.a.fb.i = 500
"
  # Manually adjust file:
  open(sf.filename, "w") do io
    print(io, contents)
  end

  import_dict(D, sf, FreeParametersOnly())
  @test FreeParameters.get_val(D["pmodel.x"]) ≈ 500
  @test FreeParameters.get_val(D["pmodel.a.x"]) ≈ 500
  @test !(D["pmodel.a.i"] ≈ 500)
  @test !(D["pmodel.a.fb.x"] ≈ 500)
  @test !(D["pmodel.a.fb.i"] ≈ 500)
end

#####
##### Complex model
#####

@testset "complex model: import_dict single file" begin
  pmodel = DycomsModel.model
  D = @struct_2_dict(pmodel)

  sf = SingleFile(joinpath(output,"real_model_fp.jl"))

  generate_template = true
  if generate_template
    @free D["pmodel.turbulence.C_smag"] Distributions.Normal
    @free D["pmodel.boundarycondition.C_drag"]
    export_dict(D, sf)

    # contents = open(f->read(f, String), sf.filename)
    contents = "pmodel.source.2.u_relaxation = Float32[7.0, -5.5, 0.0]\npmodel.boundarycondition.SHF = 500\npmodel.source.2.z_sponge = 1500.0\npmodel.radiation.F_0 = 70.0\npmodel.source.2.γ = 2.0\npmodel.orientation = Main.DycomsModel.FlatOrientation()\npmodel.source.4.v_geostrophic = -5.5\npmodel.ref_state.relativehumidity = 0.0\npmodel.turbulence.C_smag = FreeParameter{Float32,UnionAll,Nothing}(500, Normal, nothing)\npmodel.radiation.F_1 = 22.0\npmodel.source.3.D = 0.0\npmodel.boundarycondition.C_drag = FreeParameter{Float32,Nothing,Nothing}(500, nothing, nothing)\npmodel.ref_state.temperatureprofile.Γ = 0.0097659705\npmodel.radiation.α_z = 1.0\npmodel.radiation.D_subsidence = 0.0\npmodel.source.4.f_coriolis = 0.000103\npmodel.radiation.κ = 85.0\npmodel.source.2.z_max = 2500.0\npmodel.source.4.u_geostrophic = 7.0\npmodel.moisture.maxiter = 5\npmodel.radiation.ρ_i = 1.13\npmodel.source.1 = Main.DycomsModel.Gravity()\npmodel.radiation.z_i = 840.0\npmodel.source.2.α_max = 1.0\npmodel.boundarycondition.LHF = 115.0\npmodel.init_state = init_dycoms!\npmodel.ref_state.temperatureprofile.T_min = 289.0\npmodel.ref_state.temperatureprofile.T_surface = 290.4\npmodel.precipitation = Main.DycomsModel.NoPrecipitation()\n"
    open(sf.filename, "w") do io
      print(io, contents)
    end

  end

  # Last bit to get working:
  # import_dict(D, sf, FreeParametersOnly())
  # @test !(D["pmodel.boundarycondition.SHF"] ≈ 500)
  # @test FreeParameters.get_val(D["pmodel.turbulence.C_smag"]) ≈ 500
  # @test FreeParameters.get_val(D["pmodel.boundarycondition.C_drag"]) ≈ 500

  # pmodel_new = instantiate(pmodel, D, FreeParametersOnly())
  # @test !(pmodel.boundarycondition.SHF ≈ 500)
  # @test pmodel_new.turbulence.C_smag ≈ 500
  # @test pmodel_new.boundarycondition.C_drag ≈ 500
end
