"""
    EpiAwarePipeline.install_scoringutils(; force = false, quiet = true)

Installs the `scoringutils` R package from the `epiforecasts/scoringutils` GitHub repository
using the `pacman` R package manager. If `pacman` is not already installed, it will be installed first.

# Arguments
- `force::Bool`: If `true`, forces reinstallation of `scoringutils` even if it is already installed. Defaults to `false`.
- `quiet::Bool`: If `true`, suppresses output during installation. Defaults to `true`.

# Returns
- `nothing`: This function does not return any value.
"""
function EpiAwarePipeline.install_scoringutils(; force = false, quiet = true)
    R"""
    if (!requireNamespace("pacman", quietly = TRUE)) {
        install.packages("pacman", dependencies = TRUE, quiet = TRUE, ask = FALSE)
    }
    pacman::p_install_gh("epiforecasts/scoringutils",
                          dependencies = TRUE,
                          force = $force,
                          quiet = $quiet)
    """
    return nothing
end
