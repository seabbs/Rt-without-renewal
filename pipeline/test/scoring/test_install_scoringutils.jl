@testset "EpiAwarePipeline.install_scoringutils Tests" begin
    # Test 1: Check if the function runs without errors with default arguments
    @testset "Default Arguments" begin
        try
            EpiAwarePipeline.install_scoringutils()
            @test true  # If no error occurs, the test passes
        catch e
            @test false
        end
    end

    # Test 2: Check if the function runs without errors with force = true
    @testset "Force Installation" begin
        try
            EpiAwarePipeline.install_scoringutils(force = true)
            @test true  # If no error occurs, the test passes
        catch e
            @test false
        end
    end

    # Test 3: Check if the function runs without errors with quiet = false
    @testset "Verbose Installation" begin
        try
            EpiAwarePipeline.install_scoringutils(quiet = false)
            @test true  # If no error occurs, the test passes
        catch e
            @test false
        end
    end

    # Test 4: Check if the function runs without errors with both force = true and quiet = false
    @testset "Force and Verbose Installation" begin
        try
            EpiAwarePipeline.install_scoringutils(force = true, quiet = false)
            @test true  # If no error occurs, the test passes
        catch e
            @test false
        end
    end
end
