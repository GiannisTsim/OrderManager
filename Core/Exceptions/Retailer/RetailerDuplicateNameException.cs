namespace OrderManager.Core.Exceptions.Retailer;

[Serializable]
public class RetailerDuplicateNameException : Exception
{
    private const string DefaultMessageTemplate = "Retailer with name '{0}' already exists.";
    public string Name { get; }

    public RetailerDuplicateNameException(string name) : base(string.Format(DefaultMessageTemplate, name))
    {
        Name = name;
    }

    public RetailerDuplicateNameException(string name, Exception inner)
        : base(string.Format(DefaultMessageTemplate, name), inner)
    {
        Name = name;
    }
}