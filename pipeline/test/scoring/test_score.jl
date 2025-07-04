@testset "score function tests" begin
    using DataFramesMeta
    install_scoringutils()  # Ensure scoringutils is installed

    function create_mock_dataframe(; n = 5)
        DataFrame(
            predicted = exp.(randn(n)),
            observed = ones(n),
            model = fill("model1", n),
            parameter = fill("param1", n),
            sample_id = collect(1:n)
        )
    end

    # Test 1: Basic functionality without transformation
    df = create_mock_dataframe()
    result = score(df; transform_forecasts = false)
    @test isa(result, DataFrame)
    @test "model" ∈ names(result)
    @test "parameter" ∈ names(result)

    # Test 2: Functionality with transformation
    result_transformed = score(df; transform_forecasts = true)
    @test isa(result_transformed, DataFrame)
    @test "model" ∈ names(result)
    @test "parameter" ∈ names(result)

    # Test 3: Edge case - Empty DataFrame
    empty_df = DataFrame()
    @test_throws RCall.REvalError score(empty_df)

    # Test 4: Invalid DataFrame structure
    invalid_df = DataFrame(a = [1, 2, 3], b = [4, 5, 6])
    @test_throws RCall.REvalError score(invalid_df)
end
