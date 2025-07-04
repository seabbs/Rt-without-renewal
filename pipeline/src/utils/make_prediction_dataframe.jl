"""
Create a DataFrame containing predicted values, observed values, model name, parameter name,
and sample IDs based on the provided samples and truth data.

# Arguments
- `param_name::String`: The name of the parameter to extract from the samples.
- `samples::Dict{Symbol, Vector}`: A dictionary containing sampled data, where keys are parameter names as symbols.
- `truth::Vector`: A vector of observed values corresponding to the parameter.
- `model::String` (optional): The name of the model. Defaults to `"EpiAware"`.

# Returns
- `DataFrame`: A DataFrame with the following columns:
  - `predicted`: The sampled values for the specified parameter.
  - `observed`: The truth values provided.
  - `model`: The model name.
  - `parameter`: The name of the parameter.
  - `sample_id`: The index of each sample.

NB: The `samples` object must allow `getindex` to access the parameter values with `param_name`
coerceable to a `Symbol` and the `truth` value should be a single value or a vector of same length
 as the number of samples. An example would be a `MCMCChains.Chains` object as samples and a single
    truth value for the parameter.
"""
function make_prediction_dataframe(param_name, samples, truth; model = "EpiAware")
    x = samples[Symbol(param_name)][:]
    DataFrame(predicted = x, observed = truth, model = model,
        parameter = param_name, sample_id = 1:length(x))
end

# """

# """
