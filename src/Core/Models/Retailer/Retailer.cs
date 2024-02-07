namespace OrderManager.Core.Models.Retailer;

public record Retailer
{
    public required int RetailerNo { get; init; }
    public required DateTimeOffset UpdatedDtm { get; init; }
    public required string VatId { get; init; }
    public required string Name { get; init; }
    public required bool IsObsolete { get; init; }
    public required int BranchCount { get; init; }
}