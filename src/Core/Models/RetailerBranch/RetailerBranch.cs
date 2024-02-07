namespace OrderManager.Core.Models.RetailerBranch;

public record RetailerBranch
{
    public required int RetailerNo { get; init; }
    public required int BranchNo { get; init; }
    public required string Name { get; init; }
    public required DateTimeOffset UpdatedDtm { get; init; }
    public required bool IsObsolete { get; init; }
    public required int WeeklyServiceCount { get; init; }
    public required DateTimeOffset NextServiceDtm { get; init; }
}