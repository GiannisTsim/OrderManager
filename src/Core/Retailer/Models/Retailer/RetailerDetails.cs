namespace OrderManager.Core.Retailer.Models;

public record RetailerDetails
{
    public required int RetailerNo { get; init; }
    public required DateTimeOffset UpdatedDtm { get; init; }
    public required string TaxId { get; init; }
    public required string Name { get; init; }
    public required bool IsObsolete { get; init; }
    public required int BranchCount { get; init; }
}