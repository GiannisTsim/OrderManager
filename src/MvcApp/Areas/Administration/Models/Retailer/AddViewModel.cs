using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;

namespace OrderManager.MvcApp.Areas.Administration.Models.Retailer;

public record AddViewModel
{
    public record AddInputModel
    {
        [Required]
        [Display(Name = "VAT identification number", Prompt = "VAT identification number")]
        [Remote("ValidateVatId", "Retailer", HttpMethod = "Post")]
        public required string? VatId { get; init; }

        [Required]
        [Display(Name = "Full name", Prompt = "Full name")]
        [Remote("ValidateName", "Retailer", HttpMethod = "Post")]
        public required string? Name { get; init; }
    }

    public required AddInputModel AddInput { get; init; }
}