abstract type AbstractEpiModel end



"""
    struct EpiModel{T<:Real} <: AbstractEpiModel

EpiModel represents an epidemiological model with generation intervals, delay intervals, and observation delay kernel.

# Fields
- `gen_int::Vector{T}`: Discrete generation inteval, runs from 1, 2, ... to the end of the vector.
- `delay_int::Vector{T}`: Discrete delay distribution runs from 0, 1, ... to the end of the vector less 1.
- `delay_kernel::SparseMatrixCSC{T,Integer}`: Sparse matrix representing the observation delay kernel.
- `cluster_coeff::T`: Cluster coefficient for negative binomial observations.
- `len_gen_int::Integer`: Length of `gen_int`.
- `len_delay_int::Integer`: Length of `delay_int`.
- `time_horizon::Integer`: Length of the generated data.

# Constructors
- `EpiModel(gen_int, delay_int, cluster_coeff, time_horizon::Integer)`: Constructs an EpiModel object with given generation intervals, delay intervals, cluster coefficient, and time horizon.
- `EpiModel(gen_distribution::ContinuousDistribution, delay_distribution::ContinuousDistribution, cluster_coeff, time_horizon::Integer; Δd = 1.0, D_gen, D_delay)`: Constructs an EpiModel object with generation and delay distributions, cluster coefficient, time horizon, and optional parameters.

"""
struct EpiModel{T<:Real} <: AbstractEpiModel
    gen_int::Vector{T}
    delay_int::Vector{T}
    delay_kernel::SparseMatrixCSC{T,Integer}
    cluster_coeff::T
    len_gen_int::Integer #length(gen_int) just to save recalc
    len_delay_int::Integer #length(delay_int) just to save recalc
    time_horizon::Integer

    #Inner constructors for EpiModel object
    function EpiModel(gen_int, delay_int, cluster_coeff, time_horizon::Integer)
        @assert all(gen_int .>= 0) "Generation interval must be non-negative"
        @assert all(delay_int .>= 0) "Delay interval must be non-negative"
        @assert sum(gen_int) ≈ 1 "Generation interval must sum to 1"
        @assert sum(delay_int) ≈ 1 "Delay interval must sum to 1"

        K = generate_observation_kernel(delay_int, time_horizon)

        new{eltype(gen_int)}(
            gen_int,
            delay_int,
            K,
            cluster_coeff,
            length(gen_int),
            length(delay_int),
            time_horizon,
        )
    end

    function EpiModel(
        gen_distribution::ContinuousDistribution,
        delay_distribution::ContinuousDistribution,
        cluster_coeff,
        time_horizon::Integer;
        Δd = 1.0,
        D_gen,
        D_delay,
    )
        gen_int =
            create_discrete_pmf(gen_distribution, Δd = Δd, D = D_gen) |>
            p -> p[2:end] ./ sum(p[2:end])
        delay_int = create_discrete_pmf(delay_distribution, Δd = Δd, D = D_delay)

        K = generate_observation_kernel(delay_int, time_horizon)

        new{eltype(gen_int)}(
            gen_int,
            delay_int,
            K,
            cluster_coeff,
            length(gen_int),
            length(delay_int),
            time_horizon,
        )
    end
end

"""
    (epi_model::EpiModel)(recent_incidence, Rt)

Apply the EpiModel to calculate new incidence based on recent incidence and Rt.

# Arguments
- `recent_incidence`: Array of recent incidence values.
- `Rt`: Reproduction number.

# Returns
- `new_incidence`: Array of new incidence values.
"""
function (epi_model::EpiModel)(recent_incidence, Rt)
    new_incidence = Rt * dot(recent_incidence, epi_model.gen_int)
    [new_incidence; recent_incidence[1:(epi_model.len_gen_int-1)]], new_incidence
end
