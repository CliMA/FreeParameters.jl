
fext = ".jl"
output = joinpath(@__DIR__,"..","output")
mkpath(output)

@testset "Import single file: without free parameters" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)

  file = joinpath(output, "NoFPEntireStruct.jl")
  @export_struct(gmodel, file, EntireStruct(), SingleFile())

  # Manually adjust file:
  contents = "gmodel.x = 500.0\ngmodel.a.x = 500.0\ngmodel.a.i = 500\ngmodel.a.fb.x = 500.0\ngmodel.a.fb.i = 500\n"
  open(file, "w") do io
    print(io, contents)
  end
  @import_struct(gmodel, file, EntireStruct(), SingleFile())
  @test gmodel.x      ≈ 500.0
  @test gmodel.x      ≈ 500.0
  @test gmodel.a.x    ≈ 500.0
  @test gmodel.a.i    ≈ 500
  @test gmodel.a.fb.x ≈ 500.0
  @test gmodel.a.fb.i ≈ 500

  file = joinpath(output, "NoFPFreeParametersOnly.jl")
  qmodel = deepcopy(gmodel)
  @import_struct(gmodel, file, FreeParametersOnly(), SingleFile())
  @test is_approx(qmodel, gmodel)
end

@testset "Import single file: with free parameters" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)

  @FreeParameter(gmodel.x, Distributions.Normal)
  @FreeParameter(gmodel.a.x)

  file = joinpath(output, "WithFPEntireStruct.jl")
  @export_struct(gmodel, file, EntireStruct(), SingleFile())

  # Manually adjust file:
  contents = "gmodel.x = FreeParameter{Float64,UnionAll,Nothing}(500, Normal, nothing)
gmodel.a.x = FreeParameter{Float64,Nothing,Nothing}(500, nothing, nothing)
gmodel.a.i = 500
gmodel.a.fb.x = 500
gmodel.a.fb.i = 500
"
  open(file, "w") do io
    print(io, contents)
  end

  @import_struct(gmodel, file, EntireStruct(), SingleFile())
  @test gmodel.x.val   ≈ 500
  @test gmodel.a.x.val ≈ 500
  @test gmodel.a.i     ≈ 500
  @test gmodel.a.fb.x  ≈ 500
  @test gmodel.a.fb.i  ≈ 500

  # Refresh
  gmodel = generic_type(Params, pmodel)

  @FreeParameter(gmodel.x, Distributions.Normal)
  @FreeParameter(gmodel.a.x)

  file = joinpath(output, "WithFPFreeParametersOnly.jl")
  @export_struct(gmodel, file, FreeParametersOnly(), SingleFile())

  # Manually adjust file:
  contents = "gmodel.x = FreeParameter{Int64,Symbol,Symbol}(500, :Normal, :nothing)
gmodel.a.x = FreeParameter{Int64,Symbol,Symbol}(500, :nothing, :nothing)
"
  open(file, "w") do io
    print(io, contents)
  end

  @import_struct(gmodel, file, FreeParametersOnly(), SingleFile())

  @test gmodel.x.val   ≈ 500
  @test gmodel.a.x.val ≈ 500
  @test gmodel.a.i     ≈ pmodel.a.i
  @test gmodel.a.fb.x  ≈ pmodel.a.fb.x
  @test gmodel.a.fb.i  ≈ pmodel.a.fb.i
end
