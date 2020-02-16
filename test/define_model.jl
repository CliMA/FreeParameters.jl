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
struct FooBar{FT,I}
  x::FT
  i::I
end
struct Bar{FT,I,FB}
  x::FT
  i::I
  fb::FB
end
struct Foo{FT,I}
  x::FT
  a::Bar{FT,I}
end
m = Foo(3.0, Bar(1.0, 2, FooBar(4.0, 5)))
end
