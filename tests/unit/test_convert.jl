include("../../src/convert.jl")
import .core: to_gregorian, to_hijri, Hijri, Gregorian
using Test

@test to_hijri(Gregorian(2000, 8, 13))
@test Gregorian(1990, 3, 10)
