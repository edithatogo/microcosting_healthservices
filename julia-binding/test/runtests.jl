using Test
using NWAUJulia

@testset "command assembly" begin
    argv = NWAUJulia._build_argv(
        "acute";
        input_csv = "input.csv",
        output_csv = "output.csv",
        year = 2025,
        params_dir = "archive/sas/2025",
        python = "python",
        cli_module = "nwau_py.cli.main",
    )

    @test argv == [
        "python",
        "-m",
        "nwau_py.cli.main",
        "acute",
        "input.csv",
        "--output",
        "output.csv",
        "--params",
        "archive/sas/2025",
        "--year",
        "2025",
    ]
end

@testset "missing input guard" begin
    @test_throws ArgumentError calculate(
        "acute";
        input_csv = "does-not-exist.csv",
        output_csv = "out.csv",
    )
end
