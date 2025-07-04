"""
    EpiAwarePipeline.install_scoringutils(; force = false, quiet = true)

Installs the R package `scoringutils` version 2.1 using the `pacman` package manager.
If `pacman` is not installed, it will be installed first.

# Arguments
- `force::Bool`: If `true`, forces the reinstallation of the package even if it is already installed. Defaults to `false`.
- `quiet::Bool`: If `true`, suppresses output during installation. Defaults to `true`.

# Returns
- `nothing`: This function does not return any value.

# Notes
- This function uses embedded R code to perform the installation.
- Ensure that R is properly configured and accessible from your Julia environment.
"""
function EpiAwarePipeline.install_scoringutils(; force = false, quiet = true)
    R"""
    if (!requireNamespace("pacman", quietly = TRUE)) {
        install.packages("pacman", dependencies = TRUE, quiet = TRUE, ask = FALSE)
    }
    pacman::p_install("scoringutils",
                        dependencies = TRUE,
                        force = $force,
                        quiet = $quiet)
    """
    return nothing
end
