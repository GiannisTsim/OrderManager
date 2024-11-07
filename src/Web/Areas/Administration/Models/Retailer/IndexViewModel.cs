using System.ComponentModel.DataAnnotations;
using OrderManager.Localization;
using OrderManager.Localization.Resources.Retailer;

namespace OrderManager.Web.Areas.Administration.Models.Retailer;

[DataAnnotationResourceType(typeof(RetailerResource))]
public record IndexViewModel
{
    [DataAnnotationResourceType(typeof(RetailerResource))]
    public record RetailerViewItem
    {
        [Display(Name = "#")]
        public required int OrdinalNo { get; init; }

        public required int RetailerNo { get; init; }

        public required DateTimeOffset UpdatedDtm { get; init; }

        [Display(Name = RetailerResourceKeys.Retailer.TaxIdAbbreviation)]
        public required string TaxId { get; init; }

        [Display(Name = RetailerResourceKeys.Retailer.Name)]
        public required string Name { get; init; }

        public required bool IsObsolete { get; init; }

        [Display(Name = "Branch count")]
        public required int BranchCount { get; init; }
    }

    public required IEnumerable<RetailerViewItem> Retailers { get; init; }

    [Display(Name = "Search", Prompt = "Search for name or TIN...")]
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