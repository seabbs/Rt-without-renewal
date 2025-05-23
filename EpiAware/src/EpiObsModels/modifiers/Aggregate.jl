@doc raw"
Aggregates observations over a specified time period. For efficiency it also only passes the aggregated observations to the submodel. The aggregation vector
is internally broadcasted to the length of the observations and the present vector is broadcasted to the length of the aggregation vector using `broadcast_n`.

# Fields

- `model::AbstractTuringObservationModel`: The submodel to use for the aggregated observations.
- `aggregation::AbstractVector{<: Int}`: The number of time periods to aggregate over.
- `present::AbstractVector{<: Bool}`: A vector of booleans indicating whether the observation is present or not.

# Constructors

- `Aggregate(model, aggregation)`: Constructs an `Aggregate` object and automatically sets the `present` field.
- `Aggregate(; model, aggregation)`: Constructs an `Aggregate` object and automatically sets the `present` field using named keyword arguments

# Examples

```julia
using EpiAware
weekly_agg = Aggregate(PoissonError(), [0, 0, 0, 0, 7, 0, 0])
gen_obs = generate_observations(weekly_agg, missing, fill(1, 28))
gen_obs()
```
"
struct Aggregate{M <: AbstractTuringObservationModel,
    I <: AbstractVector{<:Int}, J <: AbstractVector{<:Bool}} <:
       AbstractTuringObservationModel
    model::M
    aggregation::I
    present::J

    function Aggregate(model, aggregation)
        present = aggregation .!= 0
        new{typeof(model), typeof(aggregation), typeof(present)}(
            model, aggregation, present)
    end
end

function Aggregate(; model, aggregation)
    return Aggregate(model, aggregation)
end

@doc raw"
Generate observations using an aggregation model.

# Arguments
- `ag::Aggregate`: The aggregation model.
- `y_t`: The current state of the observations. If missing, a vector of missing values is created.
- `Y_t`: The expected observations.

# Returns
- A vector of observations where entries are aggregated according to the aggregation model's
  specification. Only positions marked as present in the aggregation model contain non-zero
  values.

# Details
The function:
1. Broadcasts the aggregation vector to match the length of observations
2. Broadcasts the present vector to match the length of observations
3. For each present position, sums the expected observations over the aggregation window
4. Generates observations for the aggregated values using the underlying model
5. Returns a vector with observations only in the present positions
"
@model function EpiAwareBase.generate_observations(ag::Aggregate, y_t, Y_t)
    if ismissing(y_t)
        y_t = Vector{Missing}(missing, length(Y_t))
    end

    n = length(y_t)
    m = length(ag.aggregation)

    aggregation = broadcast_rule(RepeatEach(), ag.aggregation, n, m)

    present = broadcast_rule(RepeatEach(), ag.present, n, m)

    agg_Y_t = map(findall(present)) do i
        sum(Y_t[max(1, i - aggregation[i] + 1):i])
    end

    @submodel pred_obs = generate_observations(ag.model, y_t[present], agg_Y_t)
    return _return_aggregate(pred_obs, present, n)
end

function _return_aggregate(pred_obs, present, n)
    y_t = zeros(eltype(pred_obs), n)
    y_t[present] = pred_obs
    return y_t
end
