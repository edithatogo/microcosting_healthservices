using System.Text.Json;
using Mchs.Bindings.DotNet.Models;

namespace Mchs.Bindings.DotNet.Interop;

public sealed class LocalFileInteropAdapter : IBindingInteropAdapter
{
    private static readonly JsonSerializerOptions JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        WriteIndented = true,
    };

    public async Task<BindingResponse> ExecuteAsync(
        string requestPath,
        string responsePath,
        CancellationToken cancellationToken = default)
    {
        var request = await ReadRequestAsync(requestPath, cancellationToken).ConfigureAwait(false);
        var response = CreateResponse(request);

        await WriteResponseAsync(responsePath, response, cancellationToken).ConfigureAwait(false);
        return response;
    }

    private static async Task<BindingRequest> ReadRequestAsync(
        string requestPath,
        CancellationToken cancellationToken)
    {
        if (!File.Exists(requestPath))
        {
            throw new FileNotFoundException("Request file not found.", requestPath);
        }

        await using var stream = File.OpenRead(requestPath);
        var request = await JsonSerializer.DeserializeAsync<BindingRequest>(
            stream,
            JsonOptions,
            cancellationToken).ConfigureAwait(false);

        if (request is null)
        {
            throw new InvalidDataException("Request file did not contain a valid BindingRequest document.");
        }

        return request;
    }

    private static async Task WriteResponseAsync(
        string responsePath,
        BindingResponse response,
        CancellationToken cancellationToken)
    {
        var directory = Path.GetDirectoryName(responsePath);
        if (!string.IsNullOrWhiteSpace(directory))
        {
            Directory.CreateDirectory(directory);
        }

        await using var stream = File.Create(responsePath);
        await JsonSerializer.SerializeAsync(stream, response, JsonOptions, cancellationToken).ConfigureAwait(false);
    }

    private static BindingResponse CreateResponse(BindingRequest request)
    {
        var warnings = new List<string>
        {
            "Formula logic is intentionally not implemented in this prototype.",
        };

        if (request.Metadata is null || request.Metadata.Count == 0)
        {
            warnings.Add("Request metadata was empty.");
        }

        return new BindingResponse(
            Success: true,
            Status: "scaffold-only",
            Operation: request.Operation,
            InputPath: request.InputPath,
            OutputPath: request.OutputPath,
            Message: "DotNet binding scaffold completed without calculator logic.",
            Warnings: warnings);
    }
}
