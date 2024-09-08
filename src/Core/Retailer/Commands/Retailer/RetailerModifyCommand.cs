using OrderManager.Core.Retailer.Exceptions.Retailer;

namespace OrderManager.Core.Retailer.Commands.Retailer;

public record RetailerModifyCommand
{
    public int RetailerNo { get; }
    public DateTimeOffset UpdatedDtm { get; }
    public string TaxId { get; }
    public string Name { get; }

    public RetailerModifyCommand(int? retailerNo, DateTimeOffset? updatedDtm, string? taxId, string? name)
    {
        RetailerNo = retailerNo ?? throw new ArgumentNullException(nameof(retailerNo));
        UpdatedDtm = updatedDtm ?? throw new ArgumentNullException(nameof(updatedDtm));
        TaxId = !string.IsNullOrWhiteSpace(taxId)
            ? taxId.Trim()
            : throw new RetailerInvalidTaxIdException(taxId, "TaxId cannot be null or empty.");
        Name = !string.IsNullOrWhiteSpace(name)
            ? name.Trim()
            : throw new RetailerInvalidNameException(name, "Name cannot be null or empty.");
    }
}