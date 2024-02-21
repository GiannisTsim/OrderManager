namespace OrderManager.Core.Retailer.Exceptions;

[Serializable]
public class RetailerCurrencyLostException : Exception
{
    private const string DefaultMessageTemplate = "Retailer '{0}' currency timestamp not matching {1:o}.";
    public int RetailerNo { get; }
    public DateTimeOffset UpdatedDtm { get; }


    public RetailerCurrencyLostException(int retailerNo, DateTimeOffset updatedDtm)
        : base(string.Format(DefaultMessageTemplate, retailerNo, updatedDtm))
    {
        RetailerNo = retailerNo;
        UpdatedDtm = updatedDtm;
    }

    public RetailerCurrencyLostException(int retailerNo, DateTimeOffset updatedDtm, Exception inner)
        : base(string.Format(DefaultMessageTemplate, retailerNo, updatedDtm), inner)
    {
        RetailerNo = retailerNo;
        UpdatedDtm = updatedDtm;
    }
}