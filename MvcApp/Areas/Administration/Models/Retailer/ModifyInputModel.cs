using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;

namespace OrderManager.MvcApp.Areas.Administration.Models.Retailer;

public record ModifyInputModel
{
    [Required] [HiddenInput] public required DateTimeOffset? UpdatedDtm { get; init; }

    [Required]
    [Display(Name = "VAT identification number", Prompt = "VAT identification number")]
    public required string? VatId { get; init; }

    [Required]
    [Display(Name = "Full name", Prompt = "Full name")]
    public required string? Name { get; init; }
}

// [BindRequired]
// public record ModifyInputModel : RetailerModifyCommand
// {
//     [HiddenInput] public override required int RetailerNo { get; init; }
//
//     [HiddenInput] public override required DateTimeOffset UpdatedDtm { get; init; }
//
//     [Display(Name = "VAT identification number", Prompt = "VAT identification number")]
//     public override required string VatId { get; init; }
//
//     [Display(Name = "Full name", Prompt = "Full name")]
//     public override required string Name { get; init; }
// }