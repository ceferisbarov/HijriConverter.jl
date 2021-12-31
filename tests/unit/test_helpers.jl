include("../../src/helpers.jl")
using .helpers
using Test

@test helpers.jdn_to_ordinal(2447977) == 726552


@test helpers.ordinal_to_jdn(726552) == 2447977


@test helpers.jdn_to_rjd(2456087) == 56087


@test helpers.rjd_to_jdn(56087) == 2456087
