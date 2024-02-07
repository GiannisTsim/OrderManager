namespace OrderManager.MvcApp.Areas.Administration.Models.Retailer;

public record ModifyViewModel(
    Core.Models.Retailer.Retailer Retailer,
    ModifyInputModel ModifyInputModel
);