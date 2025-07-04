using RCall # Activate RCall extension
install_scoringutils()  # Ensure scoringutils is installed
include("test_install_scoringutils.jl")
include("test_score_parameters.jl")
include("test_score.jl")
