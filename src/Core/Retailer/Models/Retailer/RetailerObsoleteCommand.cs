namespace OrderManager.Core.Retailer.Models;

public record RetailerObsoleteCommand(
    int RetailerNo,
    DateTimeOffset UpdatedDtm
);