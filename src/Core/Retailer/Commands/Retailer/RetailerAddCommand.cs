using OrderManager.Core.Retailer.Exceptions.Retailer;

namespace OrderManager.Core.Retailer.Commands.Retailer;

public record RetailerAddCommand
{
    public string TaxId { get; }
    public string Name { get; }

    public RetailerAddCommand(string? taxId, string? name)
    {
        TaxId = !string.IsNullOrWhiteSpace(taxId)
            ? taxId.Trim()
            : throw new RetailerInvalidTaxIdException(taxId, "TaxId cannot be null or empty.");
        Name = !string.IsNullOrWhiteSpace(name)
            ? name.Trim()
            : throw new RetailerInvalidNameException(name, "Name cannot be null or empty.");
    }
}