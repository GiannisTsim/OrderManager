namespace OrderManager.Core.Retailer.Exceptions;

public class RetailerInvalidVatIdException : Exception
{
    private const string DefaultMessageTemplate = "Retailer VAT ID '{0}' is invalid.";
    public string? VatId { get; }

    public RetailerInvalidVatIdException(string? vatId) : base(string.Format(DefaultMessageTemplate, vatId))
    {
        VatId = vatId;
    }

    public RetailerInvalidVatIdException(string? vatId, Exception inner)
        : base(string.Format(DefaultMessageTemplate, vatId), inner)
    {
        VatId = vatId;
    }
}