using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;
using OrderManager.Core.Retailer.Models;
using OrderManager.Localization;
using OrderManager.Localization.Resources.Retailer;

namespace OrderManager.Web.Areas.Administration.Models.Retailer;

public record ModifyViewModel
{
    [DataAnnotationResourceType(typeof(RetailerResource))]
    public record ModifyInputModel
    {
        [Required]
        public required int? RetailerNo { get; init; }

        [Required]
        public required DateTimeOffset? UpdatedDtm { get; init; }

        [Display(Name = RetailerResourceKeys.Retailer.TaxId, Prompt = RetailerResourceKeys.Retailer.TaxId)]
        [Required(ErrorMessage = RetailerResourceKeys.Retailer.InvalidTaxId)]
        [Remote("ValidateTaxId", "Retailer", AdditionalFields = nameof(RetailerNo))]
        public required string? TaxId { get; init; }

        [Display(Name = RetailerResourceKeys.Retailer.Name, Prompt = RetailerResourceKeys.Retailer.Name)]
        [Required(ErrorMessage = RetailerResourceKeys.Retailer.InvalidName)]
        [Remote("ValidateName", "Retailer", AdditionalFields = nameof(RetailerNo))]
        public required string? Name { get; init; }

        public string? CancellationReturnUrl { get; init; }
    }

    public required RetailerDetails Retailer { get; init; }
    public required ModifyInputModel ModifyInput { get; init; }
}