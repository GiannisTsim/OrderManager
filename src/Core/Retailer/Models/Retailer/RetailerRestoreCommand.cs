namespace OrderManager.Core.Retailer.Models;

public record RetailerRestoreCommand(
    int RetailerNo,
    DateTimeOffset UpdatedDtm
);