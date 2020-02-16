
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
