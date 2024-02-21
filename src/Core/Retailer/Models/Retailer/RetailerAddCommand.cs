using OrderManager.Core.Retailer.Exceptions;

namespace OrderManager.Core.Retailer.Models;

public record RetailerAddCommand
{
    public string VatId { get; }
    public string Name { get; }

    public RetailerAddCommand(string? vatId, string? name)
    {
        if (string.IsNullOrWhiteSpace(vatId)) throw new RetailerInvalidVatIdException(vatId);
        if (string.IsNullOrWhiteSpace(name)) throw new RetailerInvalidNameException(name);
        VatId = vatId;
        Name = name;
    }
}