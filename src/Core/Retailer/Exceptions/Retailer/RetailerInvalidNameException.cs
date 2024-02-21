namespace OrderManager.Core.Retailer.Exceptions;

public class RetailerInvalidNameException : Exception
{
    private const string DefaultMessageTemplate = "Retailer name '{0}' is invalid.";
    public string? Name { get; }

    public RetailerInvalidNameException(string? name) : base(string.Format(DefaultMessageTemplate, name))
    {
        Name = name;
    }

    public RetailerInvalidNameException(string? name, Exception inner)
        : base(string.Format(DefaultMessageTemplate, name), inner)
    {
        Name = name;
    }
}