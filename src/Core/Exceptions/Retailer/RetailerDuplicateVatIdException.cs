namespace OrderManager.Core.Exceptions.Retailer;

[Serializable]
public class RetailerDuplicateVatIdException : Exception
{
    private const string DefaultMessageTemplate = "Retailer with VAT ID '{0}' already exists.";
    public string VatId { get; }

    public RetailerDuplicateVatIdException(string vatId) : base(string.Format(DefaultMessageTemplate, vatId))
    {
        VatId = vatId;
    }

    public RetailerDuplicateVatIdException(string vatId, Exception inner)
        : base(string.Format(DefaultMessageTemplate, vatId), inner)
    {
        VatId = vatId;
    }
}