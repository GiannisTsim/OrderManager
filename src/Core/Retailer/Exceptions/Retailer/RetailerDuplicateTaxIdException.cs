namespace OrderManager.Core.Retailer.Exceptions.Retailer;

public class RetailerDuplicateTaxIdException : Exception
{
    private const string DefaultMessageTemplate = "Retailer with TaxId '{0}' already exists.";
    public string TaxId { get; }

    public RetailerDuplicateTaxIdException(string taxId) : base(string.Format(DefaultMessageTemplate, taxId))
    {
        TaxId = taxId;
    }

    public RetailerDuplicateTaxIdException(string taxId, Exception inner)
        : base(string.Format(DefaultMessageTemplate, taxId), inner)
    {
        TaxId = taxId;
    }
}