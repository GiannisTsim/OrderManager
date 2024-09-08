namespace OrderManager.Core.Retailer.Commands.Retailer;

public record RetailerRestoreCommand
{
    public int RetailerNo { get; }
    public DateTimeOffset UpdatedDtm { get; }

    public RetailerRestoreCommand(int? retailerNo, DateTimeOffset? updatedDtm)
    {
        RetailerNo = retailerNo ?? throw new ArgumentNullException(nameof(retailerNo));
        UpdatedDtm = updatedDtm ?? throw new ArgumentNullException(nameof(updatedDtm));
    }
}