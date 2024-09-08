namespace OrderManager.Core.Retailer.Exceptions.Retailer;

public class RetailerInvalidNameException : Exception
{
    private const string DefaultMessageTemplate = "Retailer name '{0}' is invalid.";
    public string? Name { get; }

    public RetailerInvalidNameException(string? name, string? message = null)
        : base(message ?? string.Format(DefaultMessageTemplate, name))
    {
        Name = name;
    }

    public RetailerInvalidNameException(string? name, Exception inner, string? message = null)
        : base(message ?? string.Format(DefaultMessageTemplate, name), inner)
    {
        Name = name;
    }
}