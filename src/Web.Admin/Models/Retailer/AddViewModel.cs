using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;
using OrderManager.Localization;
using OrderManager.Localization.Resources.Retailer;

namespace OrderManager.Web.Admin.Models.Retailer;

public record AddViewModel
{
    [DataAnnotationResourceType(typeof(RetailerResource))]
    public record AddInputModel
    {
        [Display(Name = RetailerResourceKeys.Retailer.TaxId, Prompt = RetailerResourceKeys.Retailer.TaxId)]
        [Required(ErrorMessage = RetailerResourceKeys.Retailer.InvalidTaxId)]
        [Remote("ValidateTaxId", "Retailer")]
        public required string? TaxId { get; init; }

        [Display(Name = RetailerResourceKeys.Retailer.Name, Prompt = RetailerResourceKeys.Retailer.Name)]
        [Required(ErrorMessage = RetailerResourceKeys.Retailer.InvalidName)]
        [Remote("ValidateName", "Retailer")]
        public required string? Name { get; init; }

        public string? CancellationReturnUrl { get; init; }
    }

    public required AddInputModel AddInput { get; init; }
}