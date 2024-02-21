using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;
using OrderManager.Core.Retailer.Models;

namespace OrderManager.MvcApp.Areas.Administration.Models.Retailer;

public record ModifyViewModel
{
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

    public required RetailerDetails Retailer { get; init; }
    public required ModifyInputModel ModifyInput { get; init; }
}