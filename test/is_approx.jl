#####
##### is_approx for structs
#####

function is_approx(a::T, b::P, L = true) where {T,P}
  for fn in fieldnames(T)
    @assert hasproperty(a, fn)
    @assert hasproperty(b, fn)

    aprop = getproperty(a, fn)
    bprop = getproperty(b, fn)

    @assert typeof(aprop) == typeof(bprop)
    @assert isbits(aprop) == isbits(bprop)

    if isbits(aprop)
      L = L && isapprox(aprop, bprop)
    else
      is_approx(aprop, bprop, L)
    end
  end
  return L
end
