"""
    EpiAwarePipeline.score_parameters(param_names, samples, truths; model="EpiAware", transform_forecasts=true)

Scores the parameters of a model by comparing predictions against ground truth values.

# Arguments
- `param_names::Vector{String}`: A list of parameter names to be scored.
- `samples::Any`: The sampled predictions for the parameters.
- `truths::Any`: The ground truth values corresponding to the parameters.
- `model::String="EpiAware"`: The name of the model used for scoring. Defaults to `"EpiAware"`.
- `transform_forecasts::Bool=true`: Whether to transform forecasts before scoring. Defaults to `true`.

# Returns
- `df::DataFrame`: A DataFrame containing the scores for each parameter.

# Notes
This function uses `make_prediction_dataframe` to generate prediction dataframes for each parameter and `score` to compute the scores. The results are aggregated into a single DataFrame.
"""
function EpiAwarePipeline.score_parameters(
        param_names, samples, truths; model = "EpiAware", transform_forecasts = true)
    df = mapreduce(vcat, param_names, truths) do param_name, truth
        score(make_prediction_dataframe(param_name, samples, truth; model),
            transform_forecasts = transform_forecasts)
    end
    return df
end
