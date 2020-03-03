# FreeParameters.jl

Infrastructure for annotating, collecting, and distributing free parameters.

|||
|---------------------:|:----------------------------------------------|
| **Documentation**    | [![dev][docs-dev-img]][docs-dev-url]          |
| **Azure Build**      | [![azure][azure-img]][azure-url]              |
| **Code Coverage**    | [![codecov][codecov-img]][codecov-url]        |
| **Bors**             | [![Bors enabled][bors-img]][bors-url]         |

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg
[docs-dev-url]: https://climate-machine.github.io/FreeParameters.jl/dev/

[azure-img]: https://dev.azure.com/climate-machine/FreeParameters.jl/_apis/build/status/climate-machine.FreeParameters.jl?branchName=master
[azure-url]: https://dev.azure.com/climate-machine/FreeParameters.jl/_build/latest?definitionId=1&branchName=master

[codecov-img]: https://codecov.io/gh/climate-machine/FreeParameters.jl/branch/master/graph/badge.svg
[codecov-url]: https://codecov.io/gh/climate-machine/FreeParameters.jl

[bors-img]: https://bors.tech/images/badge_small.svg
[bors-url]: https://app.bors.tech/repositories/22860

# Installation

FreeParameters.jl is registered in the general Julia registry. To install, enter the package manager by typing `]` in the Julia REPL, and then type:

```julia
(v1.x.y) pkg> add FreeParameters
```

Then, to use

```julia
julia> using FreeParameters
```

# Example

```julia
using FreeParameters
using Distributions
using Test

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


# Get instance of your model
pmodel = Model.m

# Convert module to dictionary
D = @struct_2_dict(pmodel)

# Test the dictionary matches the parametric model
@test D["pmodel.x"]   ≈  pmodel.x
@test D["pmodel.a.x"] ≈  pmodel.a.x
@test D["pmodel.a.i"] == pmodel.a.i

# Annotate which parameters are "free"
@free D["pmodel.x"] Distributions.Normal
@free D["pmodel.a.x"]
@free D["pmodel.a.i"]

# Extract pointers to `FreeParameter`'s
fp = extract_free_parameters(D)

# Test free parameters match their annotated values
@test fp[1].val ≈ 1.0
@test fp[2].val ≈ 3.0
@test fp[2].prior == Normal
@test fp[3].val ≈ 2

# Update free parameters (in UQ)
new_params_val = 10.0
update_free_parameters!(fp, new_params_val)

# Get new instantiation
pmodel_new = instantiate(pmodel, D, EntireStruct())

# Test model is updated
@test pmodel_new.x   ≈  new_params_val
@test pmodel_new.a.x ≈  new_params_val
@test pmodel_new.a.i == new_params_val
```

