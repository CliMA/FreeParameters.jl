
@testset "Extract free parameters" begin
  pmodel = Model.m
  D = @struct_2_dict(pmodel)


  @free D["pmodel.x"] Distributions.Normal
  @free D["pmodel.a.x"]

  fp = extract_free_parameters(D)
  @test fp[1].val ≈ 1.0
  @test fp[2].val ≈ 3.0
  @test fp[2].prior == Normal

end

