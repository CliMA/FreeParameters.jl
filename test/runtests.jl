using Test
using FreeParameters

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

@testset "FreeParameters" begin

  mutable struct Bar{FT}
    c::FreeParameter{FT}
    d::FT
  end

  mutable struct Foo{FT}
    a::FreeParameter{FT}
    b::Bar{FT}
  end

  FT = Float64
  b = Bar{FT}(FreeParameter{FT}(5.0, 0.0, 10.0), 10.0)
  f = Foo(FreeParameter{FT}(2.0, 0.0, 10.0), b)

  fp = extract_free_parameters(f)
  fp[1].val = 3.0
  fp[2].val = 30.0

  # f is now updated
  @test f.a.val ≈ 3.0
  @test f.a.hi ≈ 0.0
  @test f.a.lo ≈ 10.0
  @test f.b.c.val ≈ 30.0
  @test f.b.c.hi ≈ 0.0
  @test f.b.c.lo ≈ 10.0

end
