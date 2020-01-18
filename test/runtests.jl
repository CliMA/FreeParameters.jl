using Test
using FreeParameters
using Distributions

const ∞ =  Inf

@testset "Define, construct & flatten free parameters" begin

  @parameters struct FooParam
    a::Float64 =0.5 ∈(0,1)
    b::Float64 =5.0 ∈(-∞,+∞)
    c::Float64 =4.0
    d::Float64 ∈(2,+∞)
    e::Float64
  end

  foo = FooParam(d=4.0,e=5.0)

#   v = FreeParameters.flatten(Foo, foo) # Currently failing (Foo not define:)

#   FreeParameters.flatten(Foo, foo) # Currently failing (Foo not define:)

end

@testset "Constructor" begin
  fp = FreeParameter(5.0)
  @test fp() ≈ 5.0 # passes
end

@testset "Extract parameters" begin

  mutable struct Bar{FT}
    c::FreeParameter{FT}
    d::FT
  end

  mutable struct Foo{FT}
    a::FreeParameter{FT}
    b::Bar{FT}
  end

  FT = Float64
  b = Bar{FT}(FreeParameter(1.0), 2.0)
  f = Foo(FreeParameter(3.0), b)

  fp = extract_free_parameters(f)
  @test fp[1]() ≈ 3.0
  @test fp[2]() ≈ 1.0

  # # f is now updated
  @test f.a() ≈ 3.0
  @test f.b.c() ≈ 1.0

end
