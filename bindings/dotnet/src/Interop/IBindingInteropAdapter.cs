using Mchs.Bindings.DotNet.Models;

namespace Mchs.Bindings.DotNet.Interop;

public interface IBindingInteropAdapter
{
    Task<BindingResponse> ExecuteAsync(
        string requestPath,
        string responsePath,
        CancellationToken cancellationToken = default);
}
