namespace OrderManager.Core.Retailer.Commands.Retailer;

public record RetailerObsoleteCommand
{
    public int RetailerNo { get; }
    public DateTimeOffset UpdatedDtm { get; }

    public RetailerObsoleteCommand(int? retailerNo, DateTimeOffset? updatedDtm)
    {
        RetailerNo = retailerNo ?? throw new ArgumentNullException(nameof(retailerNo));
        UpdatedDtm = updatedDtm ?? throw new ArgumentNullException(nameof(updatedDtm));
    }
}