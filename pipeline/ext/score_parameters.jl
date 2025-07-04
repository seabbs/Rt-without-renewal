function EpiAwarePipeline.score_parameters(
        param_names, samples, truths; model = "EpiAware", transform_forecasts = true)
    df = mapreduce(vcat, param_names, truths) do param_name, truth
        score(make_prediction_dataframe(param_name, samples, truth; model),
            transform_forecasts = transform_forecasts)
    end
    return df
end
