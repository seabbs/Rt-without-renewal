include("simple_crps.jl")
include("summarise_crps.jl")

"""
Base function for scoring parameters intended to be extended conditional on other
    dependency packages, such as the R package `scoringutils` via `RCall`.
"""
function score_parameters end

"""
Base function for installing the `scoringutils` package in R, intended to be
    extended conditional on other dependency packages, e.g. `RCall`.
"""
function install_scoringutils end
