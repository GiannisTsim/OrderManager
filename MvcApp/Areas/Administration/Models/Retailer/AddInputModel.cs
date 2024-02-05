using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;

namespace OrderManager.MvcApp.Areas.Administration.Models.Retailer;

public record AddInputModel
{
    [Required]
    [Remote("ValidateVatId", "Retailer", HttpMethod = "Post")]
    [Display(Name = "VAT identification number", Prompt = "VAT identification number")]
    public required string? VatId { get; init; }

    [Required]
    [Remote("ValidateName", "Retailer", HttpMethod = "Post")]
    [Display(Name = "Full name", Prompt = "Full name")]
    public required string? Name { get; init; }
}

// public record AddInputModel : RetailerAddCommand
// {
//     [Remote("ValidateVatId", "Retailer", HttpMethod = "Post")]
//     [Display(Name = "VAT identification number", Prompt = "VAT identification number")]
//     public override required string? VatId { get; init; }
//
//     [Remote("ValidateFullName", "Retailer", HttpMethod = "Post")]
//     [Display(Name = "Full name", Prompt = "Full name")]
//     public override required string? Name { get; init; }
// }