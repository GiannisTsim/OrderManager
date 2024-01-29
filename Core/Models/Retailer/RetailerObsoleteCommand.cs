namespace OrderManager.Core.Models.Retailer;

public record RetailerObsoleteCommand(
    int RetailerNo,
    DateTimeOffset UpdatedDtm
);