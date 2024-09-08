namespace OrderManager.Core.Retailer.Exceptions.Retailer;

public class RetailerInvalidTaxIdException : Exception
{
    private const string DefaultMessageTemplate = "Retailer TaxId '{0}' is invalid.";
    public string? TaxId { get; }

    public RetailerInvalidTaxIdException(string? taxId, string? message = null)
        : base(message ?? string.Format(DefaultMessageTemplate, taxId))
    {
        TaxId = taxId;
    }

    public RetailerInvalidTaxIdException(string? taxId, Exception inner, string? message = null)
        : base(message ?? string.Format(DefaultMessageTemplate, taxId), inner)
    {
        TaxId = taxId;
    }
}