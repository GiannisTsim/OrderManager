namespace OrderManager.Core.Retailer.Exceptions.RetailerBranch;

public class RetailerBranchCurrencyLostException : Exception
{
    private const string DefaultMessageTemplate = "Retailer '{0}' branch '{1}' currency timestamp not matching {2:o}.";
    public int RetailerNo { get; }
    public int BranchNo { get; }
    public DateTimeOffset UpdatedDtm { get; }


    public RetailerBranchCurrencyLostException(int retailerNo, int branchNo, DateTimeOffset updatedDtm)
        : base(string.Format(DefaultMessageTemplate, retailerNo, branchNo, updatedDtm))
    {
        RetailerNo = retailerNo;
        BranchNo = branchNo;
        UpdatedDtm = updatedDtm;
    }

    public RetailerBranchCurrencyLostException(int retailerNo, int branchNo, DateTimeOffset updatedDtm, Exception inner)
        : base(string.Format(DefaultMessageTemplate, retailerNo, branchNo, updatedDtm), inner)
    {
        RetailerNo = retailerNo;
        BranchNo = branchNo;
        UpdatedDtm = updatedDtm;
    }
}