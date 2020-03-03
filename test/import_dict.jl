
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

  @free D["pmodel.turbulence.C_smag"] Distributions.Normal
  @free D["pmodel.boundarycondition.C_drag"]
  export_dict(D, sf, FreeParametersOnly())

  # contents = open(f->read(f, String), sf.filename)
  # Manually adjust file:
  contents = "pmodel.turbulence.C_smag = FreeParameter{Float32,UnionAll,Nothing}(500, Normal, nothing)\npmodel.boundarycondition.C_drag = FreeParameter{Float32,Nothing,Nothing}(500, nothing, nothing)\n"
  open(sf.filename, "w") do io
    print(io, contents)
  end

  import_dict(D, sf, FreeParametersOnly())
  @test FreeParameters.get_val(D["pmodel.turbulence.C_smag"]) ≈ 500
  @test FreeParameters.get_val(D["pmodel.boundarycondition.C_drag"]) ≈ 500
end
