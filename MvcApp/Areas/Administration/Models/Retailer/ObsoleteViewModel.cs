namespace OrderManager.MvcApp.Areas.Administration.Models.Retailer;

public record ObsoleteViewModel(
    Core.Models.Retailer.Retailer Retailer,
    ObsoleteInputModel ObsoleteInputModel
);