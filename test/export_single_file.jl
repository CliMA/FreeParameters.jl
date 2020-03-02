
fext = ".jl"
output = joinpath(@__DIR__,"..","output")
mkpath(output)

@testset "Export single file: without free parameters" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)

  file = joinpath(output, "NoFPEntireStruct.jl")
  @export_struct(gmodel, SingleFile(file), EntireStruct())
  contents = open(f->read(f, String), file)
  @test isfile(file)
  @test contents == "gmodel.x = 3.0\ngmodel.a.x = 1.0\ngmodel.a.i = 2\ngmodel.a.fb.x = 4.0\ngmodel.a.fb.i = 5\n"

  file = joinpath(output, "NoFPFreeParametersOnly.jl")
  @export_struct(gmodel, SingleFile(file), FreeParametersOnly())
  contents = open(f->read(f, String), file)
  @test isfile(file)
  @test contents == ""
end

@testset "Export single file: with free parameters" begin
  pmodel = Model.m
  gmodel = generic_type(Params, pmodel)

  @FreeParameter(gmodel.x, Distributions.Normal)
  @FreeParameter(gmodel.a.x)

  file = joinpath(output, "WithFPEntireStruct.jl")
  @export_struct(gmodel, SingleFile(file), EntireStruct())
  contents = open(f->read(f, String), file)
  @test isfile(file)
  @test contents == "gmodel.x = FreeParameter{Float64,UnionAll,Nothing}(3.0, Normal, nothing)
gmodel.a.x = FreeParameter{Float64,Nothing,Nothing}(1.0, nothing, nothing)
gmodel.a.i = 2
gmodel.a.fb.x = 4.0
gmodel.a.fb.i = 5
"

  file = joinpath(output, "WithFPFreeParametersOnly.jl")
  @export_struct(gmodel, SingleFile(file), FreeParametersOnly())
  contents = open(f->read(f, String), file)
  @test isfile(file)
  @test contents == "gmodel.x = FreeParameter{Float64,UnionAll,Nothing}(3.0, Normal, nothing)
gmodel.a.x = FreeParameter{Float64,Nothing,Nothing}(1.0, nothing, nothing)
"
end
