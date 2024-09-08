namespace OrderManager.Core.Retailer.Commands.RetailerBranch;

public record RetailerBranchRestoreCommand
{
    public int RetailerNo { get; }
    public int BranchNo { get; }
    public DateTimeOffset UpdatedDtm { get; }

    public RetailerBranchRestoreCommand(int? retailerNo, int? branchNo, DateTimeOffset? updatedDtm)
    {
        RetailerNo = retailerNo ?? throw new ArgumentNullException(nameof(retailerNo));
        BranchNo = branchNo ?? throw new ArgumentNullException(nameof(branchNo));
        UpdatedDtm = updatedDtm ?? throw new ArgumentNullException(nameof(updatedDtm));
    }
}