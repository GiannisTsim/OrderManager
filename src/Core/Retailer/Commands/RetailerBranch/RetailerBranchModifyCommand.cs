using OrderManager.Core.Retailer.Exceptions.RetailerBranch;

namespace OrderManager.Core.Retailer.Commands.RetailerBranch;

public record RetailerBranchModifyCommand
{
    public int RetailerNo { get; }
    public int BranchNo { get; }
    public DateTimeOffset UpdatedDtm { get; }
    public string Name { get; }

    public RetailerBranchModifyCommand(int? retailerNo, int? branchNo, DateTimeOffset? updatedDtm, string name)
    {
        RetailerNo = retailerNo ?? throw new ArgumentNullException(nameof(retailerNo));
        BranchNo = branchNo ?? throw new ArgumentNullException(nameof(branchNo));
        UpdatedDtm = updatedDtm ?? throw new ArgumentNullException(nameof(updatedDtm));
        Name = !string.IsNullOrWhiteSpace(name)
            ? name.Trim()
            : throw new RetailerBranchInvalidNameException(name, "Name cannot be null or empty.");
    }
}