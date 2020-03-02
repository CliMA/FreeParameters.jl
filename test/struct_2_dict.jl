
@testset "struct_2_dict: without free parameters" begin
  pmodel = Model.m
  D = @struct_2_dict(pmodel)

  @test D["pmodel.a.fb.x"] ≈ 4.0
  @test D["pmodel.a.x"] ≈ 1.0
  @test D["pmodel.x"] ≈ 3.0
  @test D["pmodel.a.i"] ≈ 2
  @test D["pmodel.a.fb.i"] ≈ 5
end

@testset "Annotate dict" begin
  pmodel = Model.m
  D = @struct_2_dict(pmodel)

  @free D["pmodel.x"] Distributions.Normal
  @test D["pmodel.x"] isa FreeParameter

  @free D["pmodel.a.x"]
  @test D["pmodel.a.x"] isa FreeParameter
end

@testset "struct_2_dict complex: without free parameters" begin
  pmodel = DycomsModel.model
  D = @struct_2_dict(pmodel)

  @test D["pmodel.source.2.u_relaxation"]                  ≈ Float32[7.0, -5.5, 0.0]
  @test D["pmodel.boundarycondition.SHF"]                  ≈ 15.0
  @test D["pmodel.source.2.z_sponge"]                      ≈ 1500.0
  @test D["pmodel.radiation.F_0"]                          ≈ 70.0
  @test D["pmodel.source.2.γ"]                             ≈ 2.0
  @test D["pmodel.orientation"]                            == Main.DycomsModel.FlatOrientation()
  @test D["pmodel.source.4.v_geostrophic"]                 ≈ -5.5
  @test D["pmodel.ref_state.relativehumidity"]             ≈ 0.0
  @test D["pmodel.turbulence.C_smag"]                      ≈ 0.21
  @test D["pmodel.radiation.F_1"]                          ≈ 22.0
  @test D["pmodel.source.3.D"]                             ≈ 0.0
  @test D["pmodel.boundarycondition.C_drag"]               ≈ 0.0011
  @test D["pmodel.ref_state.temperatureprofile.Γ"]         ≈ 0.0097659705
  @test D["pmodel.radiation.α_z"]                          ≈ 1.0
  @test D["pmodel.radiation.D_subsidence"]                 ≈ 0.0
  @test D["pmodel.source.4.f_coriolis"]                    ≈ 0.000103
  @test D["pmodel.radiation.κ"]                            ≈ 85.0
  @test D["pmodel.source.2.z_max"]                         ≈ 2500.0
  @test D["pmodel.source.4.u_geostrophic"]                 ≈ 7.0
  @test D["pmodel.moisture.maxiter"]                       ≈ 5
  @test D["pmodel.radiation.ρ_i"]                          ≈ 1.13
  @test D["pmodel.source.1"]                               == Main.DycomsModel.Gravity()
  @test D["pmodel.radiation.z_i"]                          ≈ 840.0
  @test D["pmodel.source.2.α_max"]                         ≈ 1.0
  @test D["pmodel.boundarycondition.LHF"]                  ≈ 115.0
  @test D["pmodel.init_state"]                             == Main.DycomsModel.init_dycoms!
  @test D["pmodel.ref_state.temperatureprofile.T_min"]     ≈ 289.0
  @test D["pmodel.ref_state.temperatureprofile.T_surface"] ≈ 290.4
  @test D["pmodel.precipitation"]                          == Main.DycomsModel.NoPrecipitation()
end

@testset "Annotate dict" begin
  pmodel = DycomsModel.model
  D = @struct_2_dict(pmodel)

  @free D["pmodel.radiation.κ"] Distributions.Normal
  @test D["pmodel.radiation.κ"] isa FreeParameter

  @free D["pmodel.turbulence.C_smag"] Distributions.Normal
  @test D["pmodel.turbulence.C_smag"] isa FreeParameter
end
