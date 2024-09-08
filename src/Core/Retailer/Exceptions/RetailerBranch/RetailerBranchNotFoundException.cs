namespace OrderManager.Core.Retailer.Exceptions.RetailerBranch;

public class RetailerBranchNotFoundException : Exception
{
    private const string DefaultMessageTemplate = "Retailer '{0}' branch '{1}' does not exist.";
    public int RetailerNo { get; }
    public int BranchNo { get; }

    public RetailerBranchNotFoundException(int retailerNo, int branchNo) : base
        (string.Format(DefaultMessageTemplate, retailerNo, branchNo))
    {
        RetailerNo = retailerNo;
        BranchNo = branchNo;
    }

    public RetailerBranchNotFoundException(int retailerNo, int branchNo, Exception inner)
        : base(string.Format(DefaultMessageTemplate, retailerNo, branchNo), inner)
    {
        RetailerNo = retailerNo;
        BranchNo = branchNo;
    }
}