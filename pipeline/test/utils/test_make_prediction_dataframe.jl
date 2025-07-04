@testset "make_prediction_dataframe tests" begin
    using DataFramesMeta
    # Mock data for testing
    samples_mock = Dict(:param1 => [1.0, 2.0, 3.0])
    truth_mock = [1.5, 2.5, 3.5]
    # Test 1: Basic functionality
    df = make_prediction_dataframe("param1", samples_mock, truth_mock)
    @test isa(df, DataFrame)
    @test all(df.predicted .== [1.0, 2.0, 3.0])
    @test all(df.observed .== [1.5, 2.5, 3.5])
    @test all(df.model .== "EpiAware")
    @test all(df.parameter .== "param1")
    @test all(df.sample_id .== [1, 2, 3])

    # Test 2: Single truth value
    truth_single = 2.0
    df_single_truth = make_prediction_dataframe("param1", samples_mock, truth_single)
    @test all(df_single_truth.observed .== 2.0)

    # Test 3: Custom model name
    df_custom_model = make_prediction_dataframe(
        "param1", samples_mock, truth_mock; model = "CustomModel")
    @test all(df_custom_model.model .== "CustomModel")
end
