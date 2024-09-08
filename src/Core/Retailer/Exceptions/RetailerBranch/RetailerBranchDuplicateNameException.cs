namespace OrderManager.Core.Retailer.Exceptions.RetailerBranch;

public class RetailerBranchDuplicateNameException : Exception
{
    private const string DefaultMessageTemplate = "Retailer '{0}' already has a branch with name '{1}'.";
    public int RetailerNo { get; }
    public string Name { get; }

    public RetailerBranchDuplicateNameException(int retailerNo, string name)
        : base(string.Format(DefaultMessageTemplate, retailerNo, name))
    {
        RetailerNo = retailerNo;
        Name = name;
    }

    public RetailerBranchDuplicateNameException(int retailerNo, string name, Exception inner)
        : base(string.Format(DefaultMessageTemplate, retailerNo, name), inner)
    {
        RetailerNo = retailerNo;
        Name = name;
    }
}