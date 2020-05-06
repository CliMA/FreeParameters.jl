using FreeParameters, Documenter, LaTeXStrings

makedocs(
  sitename = "FreeParameters.jl",
  doctest = false,
  strict = false,
  format = Documenter.HTML(
        prettyurls = get(ENV, "CI", nothing) == "true",
        mathengine = MathJax(Dict(
            :TeX => Dict(
                :equationNumbers => Dict(:autoNumber => "AMS"),
                :Macros => Dict()
            )
        ))
  ),
  clean = false,
  modules = [Documenter, FreeParameters],
  pages = Any[
    "Home" => "index.md",
  ],
)

deploydocs(
           repo = "github.com/CliMA/FreeParameters.jl.git",
           target = "build",
          )
