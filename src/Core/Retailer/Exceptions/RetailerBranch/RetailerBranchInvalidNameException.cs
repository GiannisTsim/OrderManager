namespace OrderManager.Core.Retailer.Exceptions.RetailerBranch;

public class RetailerBranchInvalidNameException : Exception
{
    private const string DefaultMessageTemplate = "Branch name '{0}' is invalid.";
    public string? Name { get; }

    public RetailerBranchInvalidNameException(string? name, string? message = null)
        : base(message ?? string.Format(DefaultMessageTemplate, name))
    {
        Name = name;
    }

    public RetailerBranchInvalidNameException(string? name, Exception inner, string? message = null)
        : base(message ?? string.Format(DefaultMessageTemplate, name), inner)
    {
        Name = name;
    }
}