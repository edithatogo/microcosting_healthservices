namespace Mchs.Bindings.DotNet;

public sealed record BindingCliOptions(string RequestPath, string ResponsePath)
{
    public static bool TryParse(string[] args, out BindingCliOptions? options, out string? errorMessage)
    {
        options = null;
        errorMessage = null;

        string? requestPath = null;
        string? responsePath = null;

        for (var i = 0; i < args.Length; i++)
        {
            var current = args[i];

            if (current is "--help" or "-h")
            {
                errorMessage = null;
                return false;
            }

            if (current == "--request")
            {
                if (i + 1 >= args.Length)
                {
                    errorMessage = "Missing value for --request.";
                    return false;
                }

                requestPath = args[++i];
                continue;
            }

            if (current == "--response")
            {
                if (i + 1 >= args.Length)
                {
                    errorMessage = "Missing value for --response.";
                    return false;
                }

                responsePath = args[++i];
                continue;
            }

            errorMessage = $"Unrecognized argument: {current}";
            return false;
        }

        if (string.IsNullOrWhiteSpace(requestPath))
        {
            errorMessage = "The --request argument is required.";
            return false;
        }

        if (string.IsNullOrWhiteSpace(responsePath))
        {
            errorMessage = "The --response argument is required.";
            return false;
        }

        options = new BindingCliOptions(requestPath, responsePath);
        return true;
    }
}
