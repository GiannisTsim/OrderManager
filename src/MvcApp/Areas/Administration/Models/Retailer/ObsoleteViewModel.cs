using System.ComponentModel.DataAnnotations;
using Microsoft.AspNetCore.Mvc;
using OrderManager.Core.Retailer.Models;

namespace OrderManager.MvcApp.Areas.Administration.Models.Retailer;

public record ObsoleteViewModel
{
    public record ObsoleteInputModel
    {
        [Required] [HiddenInput] public required DateTimeOffset? UpdatedDtm { get; init; }
    }

    public required RetailerDetails Retailer { get; init; }
    public required ObsoleteInputModel ObsoleteInput { get; init; }
}