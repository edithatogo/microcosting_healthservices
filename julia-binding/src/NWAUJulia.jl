module NWAUJulia

export calculate, calculate_acute, calculate_ed, calculate_non_admitted

const DEFAULT_PYTHON = get(ENV, "NWAU_PYTHON", "python3")
const DEFAULT_MODULE = get(ENV, "NWAU_MODULE", "nwau_py.cli.main")

function _build_argv(
    subcommand::AbstractString;
    input_csv::AbstractString,
    output_csv::AbstractString,
    year::Union{Nothing,AbstractString,Integer}=nothing,
    params_dir::Union{Nothing,AbstractString}=nothing,
    python::AbstractString=DEFAULT_PYTHON,
    cli_module::AbstractString=DEFAULT_MODULE,
)
    argv = String[
        python,
        "-m",
        cli_module,
        subcommand,
        input_csv,
        "--output",
        output_csv,
    ]
    if params_dir !== nothing
        push!(argv, "--params", String(params_dir))
    end
    if year !== nothing
        push!(argv, "--year", string(year))
    end
    return argv
end

function _resolve_output_path(output_csv::Union{Nothing,AbstractString})
    if output_csv === nothing
        return tempname() * ".csv"
    end
    return String(output_csv)
end

function calculate(
    subcommand::AbstractString;
    input_csv::AbstractString,
    output_csv::Union{Nothing,AbstractString}=nothing,
    year::Union{Nothing,AbstractString,Integer}=nothing,
    params_dir::Union{Nothing,AbstractString}=nothing,
    python::AbstractString=DEFAULT_PYTHON,
    cli_module::AbstractString=DEFAULT_MODULE,
)
    input_path = abspath(String(input_csv))
    isfile(input_path) || throw(ArgumentError("input CSV not found: $input_path"))

    output_path = _resolve_output_path(output_csv)
    mkpath(dirname(output_path))

    argv = _build_argv(
        subcommand;
        input_csv=input_path,
        output_csv=output_path,
        year=year,
        params_dir=params_dir,
        python=python,
        cli_module=cli_module,
    )
    run(Cmd(argv))
    return output_path
end

function calculate_acute(; kwargs...)
    return calculate("acute"; kwargs...)
end

function calculate_ed(; kwargs...)
    return calculate("ed"; kwargs...)
end

function calculate_non_admitted(; kwargs...)
    return calculate("non-admitted"; kwargs...)
end

end
