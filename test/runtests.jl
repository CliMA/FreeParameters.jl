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

"""
    Params

Stores model struct without parametric types.
"""
module Params end

"""
    Model

module for model.
"""
module Model
struct Bar{FT,I}
  x::FT
  i::I
end
struct Foo{FT,I}
  x::FT
  a::Bar{FT,I}
end
m = Foo(3.0, Bar(1.0, 2))
end

"""
    update_free_parameters!(fp, val)

Update free parameters vector `fp` with value `val`
"""
function update_free_parameters!(fp, val)
  for i in eachindex(fp)
    fp[i].val = typeof(fp[i].val)(val)
  end
  return nothing
end

@testset "Update free parameters in Params" begin
  # Define parametric model
  pmodel = Model.m

  # Define a generic model in Params and get an instance
  gmodel = generic_type(Params, pmodel)

  # Test the generic model matches the parametric model
  @test gmodel.x   ≈  pmodel.x
  @test gmodel.a.x ≈  pmodel.a.x
  @test gmodel.a.i == pmodel.a.i

  # Annotate which parameters are `FreeParameter`'s
  @FreeParameter(gmodel.x, Distributions.Normal)
  @FreeParameter(gmodel.a.x)
  @FreeParameter(gmodel.a.i)

  # Extract pointers to `FreeParameter`'s
  fp = extract_free_parameters(gmodel)

  # Test free parameters match their annotated values
  @test fp[1].prior == Distributions.Normal
  @test fp[1].val ≈ 3.0
  @test fp[2].val ≈ 1.0
  @test fp[3].val == 2

  # Update free parameters (in UQ)
  new_params_val = 10.0
  update_free_parameters!(fp, new_params_val)

  # Get parametric version of updated generic model
  pmodel_new = parametric_type(Model, pmodel, gmodel)

  # Test model is updated
  @test pmodel_new.x   ≈  new_params_val
  @test pmodel_new.a.x ≈  new_params_val
  @test pmodel_new.a.i == new_params_val
end

@testset "Update free parameters in Main" begin
  # Define parametric model
  pmodel = Model.m

  # Define a generic model in Main and get an instance
  gmodel = generic_type(Main, pmodel)

  # Test the generic model matches the parametric model
  @test gmodel.x   ≈  pmodel.x
  @test gmodel.a.x ≈  pmodel.a.x
  @test gmodel.a.i == pmodel.a.i

  # Annotate which parameters are `FreeParameter`'s
  @FreeParameter(gmodel.x, Distributions.Normal)
  @FreeParameter(gmodel.a.x)
  @FreeParameter(gmodel.a.i)

  # Extract pointers to `FreeParameter`'s
  fp = extract_free_parameters(gmodel)

  # Test free parameters match their annotated values
  @test fp[1].prior == Distributions.Normal
  @test fp[1].val ≈ 3.0
  @test fp[2].val ≈ 1.0
  @test fp[3].val == 2

  # Update free parameters (in UQ)
  new_params_val = 10.0
  update_free_parameters!(fp, new_params_val)

  # Get parametric version of updated generic model
  pmodel_new = parametric_type(Model, pmodel, gmodel)

  # Test model is updated
  @test pmodel_new.x   ≈  new_params_val
  @test pmodel_new.a.x ≈  new_params_val
  @test pmodel_new.a.i == new_params_val
end

