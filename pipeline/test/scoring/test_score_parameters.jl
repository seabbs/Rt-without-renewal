@testset "score_parameter tests" begin
    using DataFramesMeta, MCMCChains

    samples = MCMCChains.Chains(exp.(0.5 .+ randn(1000, 2, 1)), [:a, :b])
    truths = fill(exp(0.5), 2)
    result = score_parameters(["a", "b"], samples, truths;
        model = "EpiAware",
        transform_forecasts = false)

    @test isa(result, DataFrame)
    @test "parameter" in names(result)
    @test "model" in names(result)
    @test "crps" in names(result)
    @test all(result.model .== "EpiAware")

    # Test with transformation and different model name
    result_transformed = score_parameters(["a", "b"], samples, truths;
        model = "CustomModel",
        transform_forecasts = true)
    @test isa(result_transformed, DataFrame)
    @test "parameter" in names(result_transformed)
    @test "model" in names(result_transformed)
    @test "crps" in names(result_transformed)
    @test all(result_transformed.model .== "CustomModel")
end
