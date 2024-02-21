namespace OrderManager.Core.Retailer.Models;

public record RetailerSimple
{
    public required int RetailerNo { get; init; }
    public required string VatId { get; init; }
    public required string Name { get; init; }
}