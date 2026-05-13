namespace Mchs.Bindings.DotNet.Models;

public sealed record BindingResponse(
    bool Success,
    string Status,
    string Operation,
    string InputPath,
    string OutputPath,
    string Message,
    IReadOnlyList<string> Warnings);
