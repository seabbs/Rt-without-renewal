"""
    score(df::DataFrame; transform_forecasts = true)

Scores the forecast samples in the given DataFrame using the `scoringutils` R package.

# Arguments
- `df::DataFrame`: A DataFrame containing forecast samples to be scored.
- `transform_forecasts::Bool`: A keyword argument indicating whether to apply the `transform_forecasts()` function to the scored results. Defaults to `true`.

# Returns
- The scored results as a `DataFrame`.

# Details
- If `transform_forecasts` is `true`, the `scoringutils::transform_forecasts()` R function is applied to the scored results.
- The function uses RCall to execute R code and interact with the `scoringutils` package.

# Dataframe Structure
The input DataFrame `df` should contain the following columns:
- `predicted`: The predicted values from the forecast samples.
- `observed`: The observed values (truth) corresponding to the predictions.
- `model`: The name of the model used for the predictions.
- `parameter`: The name of the parameter being scored.
- `sample_id`: An identifier for each sample in the DataFrame.

To create such a DataFrame, you can use the `make_prediction_dataframe` utility function from the `EpiAwarePipeline` package.

# Dependencies
Requires the `RCall` Julia package and the `scoringutils` R package to be installed and available.
To install the `scoringutils` package as part of `EpiAwarePipeline` usage you can run:

```julia
using EpiAwarePipeline, RCall
install_scoringutils()
```

"""
function EpiAwarePipeline.score(df::DataFrame; transform_forecasts = true)
    rresult = transform_forecasts ?
              R"""
               library(scoringutils)
               result <- $df |>
                   as_forecast_sample(
                    forecast_unit = c("model", "parameter")
                   ) |>
                   transform_forecasts(append = FALSE) |>
                   score()
               """ :
              R"""
              library(scoringutils)
               result <- $df |>
                   as_forecast_sample(
                    forecast_unit = c("model", "parameter")
                   ) |>
                   score()
              """
    return rcopy(rresult)
end
