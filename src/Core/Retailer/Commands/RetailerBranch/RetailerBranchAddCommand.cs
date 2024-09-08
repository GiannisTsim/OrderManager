using OrderManager.Core.Retailer.Exceptions.RetailerBranch;

namespace OrderManager.Core.Retailer.Commands.RetailerBranch;

public record RetailerBranchAddCommand
{
    public int RetailerNo { get; }
    public string Name { get; }

    public RetailerBranchAddCommand(int? retailerNo, string? name)
    {
        RetailerNo = retailerNo ?? throw new ArgumentNullException(nameof(retailerNo));
        Name = !string.IsNullOrWhiteSpace(name)
            ? name.Trim()
            : throw new RetailerBranchInvalidNameException(name, "Name cannot be null or empty.");
    }
}