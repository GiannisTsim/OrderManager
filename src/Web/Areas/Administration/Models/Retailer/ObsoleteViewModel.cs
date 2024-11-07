using System.ComponentModel.DataAnnotations;
using OrderManager.Core.Retailer.Models;

namespace OrderManager.Web.Areas.Administration.Models.Retailer;

public record ObsoleteViewModel
{
    public record ObsoleteInputModel
    {
        [Required]
        public required int? RetailerNo { get; init; }

        [Required]
        public required DateTimeOffset? UpdatedDtm { get; init; }
    }

    public required RetailerDetails Retailer { get; init; }
    public required ObsoleteInputModel ObsoleteInput { get; init; }
}