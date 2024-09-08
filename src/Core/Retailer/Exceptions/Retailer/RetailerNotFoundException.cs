namespace OrderManager.Core.Retailer.Exceptions.Retailer;

public class RetailerNotFoundException : Exception
{
    private const string DefaultMessageTemplate = "Retailer '{0}' does not exist.";
    public int RetailerNo { get; }

    public RetailerNotFoundException(int retailerNo) : base(string.Format(DefaultMessageTemplate, retailerNo))
    {
        RetailerNo = retailerNo;
    }

    public RetailerNotFoundException(int retailerNo, Exception inner)
        : base(string.Format(DefaultMessageTemplate, retailerNo), inner)
    {
        RetailerNo = retailerNo;
    }
}