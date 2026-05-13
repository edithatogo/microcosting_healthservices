namespace Mchs.Bindings.DotNet.Models;

public sealed record BindingRequest(
    string InputPath,
    string OutputPath,
    string Operation,
    string? CorrelationId,
    IReadOnlyDictionary<string, string>? Metadata);
