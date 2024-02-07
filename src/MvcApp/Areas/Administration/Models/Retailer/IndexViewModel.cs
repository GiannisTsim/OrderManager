using System.ComponentModel.DataAnnotations;

namespace OrderManager.MvcApp.Areas.Administration.Models.Retailer;

public record IndexViewModel
{
    public record Retailer(
        int OrdinalNo,
        int RetailerNo,
        DateTimeOffset UpdatedDtm,
        string VatId,
        string Name,
        bool IsObsolete,
        int BranchCount
    );

    public required IEnumerable<Retailer> Retailers { get; init; }

    [Display(Name = "Search", Prompt = "Search for name of VAT id...")]
    public required string? SearchTerm { get; init; }

    public required int TotalResultCount { get; init; }
    public required int PageNo { get; init; }
    public required int PageSize { get; init; }

    public int PageCount => (TotalResultCount + PageSize - 1) / PageSize;
    public bool HasPreviousPage => PageNo != 1;
    public bool HasNextPage => PageNo != PageCount;

    public (int FirstResultNo, int LastResultNo) PageResultRange => ((PageNo - 1) * PageSize + 1,
        HasNextPage ? PageNo * PageSize : TotalResultCount);
}