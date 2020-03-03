
output = joinpath(@__DIR__,"..","output")
mkpath(output)

@testset "export_dict: without free parameters" begin
  pmodel = Model.m
  D = @struct_2_dict(pmodel)

  sf = SingleFile(joinpath(output,"toy_model_all.jl"))
  export_dict(D, sf)

  contents = open(f->read(f, String), sf.filename)
  @test contents == "pmodel.a.fb.x = 4.0\npmodel.a.x = 1.0\npmodel.x = 3.0\npmodel.a.i = 2\npmodel.a.fb.i = 5\n"
  fs = FolderStructure(joinpath(output,"toy_model_all"),"params.jl")
  export_dict(D, fs)
  @test ispath(fs.root_folder)
  @test isfile(joinpath(fs.root_folder,"pmodel",fs.filename))
end

@testset "export_dict: with free parameters" begin
  pmodel = Model.m
  D = @struct_2_dict(pmodel)

  @free D["pmodel.x"] Distributions.Normal
  @free D["pmodel.a.x"]
  sf = SingleFile(joinpath(output,"toy_model_fp.jl"))
  export_dict(D, sf, FreeParametersOnly())
  @test isfile(sf.filename)
  contents = open(f->read(f, String), sf.filename)
  @test contents == "pmodel.a.x = FreeParameter{Float64,Nothing,Nothing}(1.0, nothing, nothing)\npmodel.x = FreeParameter{Float64,UnionAll,Nothing}(3.0, Normal, nothing)\n"
  fs = FolderStructure(joinpath(output,"toy_model_fp"),"params.jl")
  export_dict(D, fs, FreeParametersOnly())
end

#####
##### Complex model
#####

@testset "complex model: export_dict without free parameters" begin
  pmodel = DycomsModel.model
  D = @struct_2_dict(pmodel)
  sf = SingleFile(joinpath(output,"real_model_all.jl"))
  export_dict(D, sf)
  contents = open(f->read(f, String), sf.filename)
  @test contents == "pmodel.source.2.u_relaxation = Float32[7.0, -5.5, 0.0]\npmodel.boundarycondition.SHF = 15.0\npmodel.source.2.z_sponge = 1500.0\npmodel.radiation.F_0 = 70.0\npmodel.source.2.γ = 2.0\npmodel.orientation = Main.DycomsModel.FlatOrientation()\npmodel.source.4.v_geostrophic = -5.5\npmodel.ref_state.relativehumidity = 0.0\npmodel.turbulence.C_smag = 0.21\npmodel.radiation.F_1 = 22.0\npmodel.source.3.D = 0.0\npmodel.boundarycondition.C_drag = 0.0011\npmodel.ref_state.temperatureprofile.Γ = 0.0097659705\npmodel.radiation.α_z = 1.0\npmodel.radiation.D_subsidence = 0.0\npmodel.source.4.f_coriolis = 0.000103\npmodel.radiation.κ = 85.0\npmodel.source.2.z_max = 2500.0\npmodel.source.4.u_geostrophic = 7.0\npmodel.moisture.maxiter = 5\npmodel.radiation.ρ_i = 1.13\npmodel.source.1 = Main.DycomsModel.Gravity()\npmodel.radiation.z_i = 840.0\npmodel.source.2.α_max = 1.0\npmodel.boundarycondition.LHF = 115.0\npmodel.init_state = init_dycoms!\npmodel.ref_state.temperatureprofile.T_min = 289.0\npmodel.ref_state.temperatureprofile.T_surface = 290.4\npmodel.precipitation = Main.DycomsModel.NoPrecipitation()\n"

  fs = FolderStructure(joinpath(output,"real_model_all"),"params.jl")
  export_dict(D, fs)
  @test ispath(fs.root_folder)
  @test isfile(joinpath(fs.root_folder,"pmodel",fs.filename))
end

@testset "complex model: export_dict with free parameters" begin
  pmodel = DycomsModel.model
  D = @struct_2_dict(pmodel)
  @free D["pmodel.turbulence.C_smag"] Distributions.Normal
  @free D["pmodel.boundarycondition.C_drag"]

  sf = SingleFile(joinpath(output,"real_model_fp.jl"))
  export_dict(D, sf, FreeParametersOnly())
  contents = open(f->read(f, String), sf.filename)
  @test contents == "pmodel.turbulence.C_smag = FreeParameter{Float32,UnionAll,Nothing}(0.21f0, Normal, nothing)\npmodel.boundarycondition.C_drag = FreeParameter{Float32,Nothing,Nothing}(0.0011f0, nothing, nothing)\n"
  fs = FolderStructure(joinpath(output,"real_model_fp"),"params.jl")

  export_dict(D, fs, FreeParametersOnly())
  @test !ispath(joinpath(fs.root_folder, "pmodel", "source"))
end

