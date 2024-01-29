using System.ComponentModel.DataAnnotations;

namespace OrderManager.MvcApp.Areas.Administration.Models.Retailer;

public record ObsoleteInputModel
{
    [Required] public required DateTimeOffset? UpdatedDtm { get; init; }
}