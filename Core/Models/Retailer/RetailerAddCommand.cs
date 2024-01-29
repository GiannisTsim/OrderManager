namespace OrderManager.Core.Models.Retailer;

public record RetailerAddCommand(
    string VatId,
    string Name
);

// public record RetailerAddCommand
// {
//     [Required] public required string VatId { get; init; }
//     [Required] public required string Name { get; init; }
// }

// public record RetailerAddCommand
// {
//     [Required] public virtual required string? VatId { get; init; }
//     [Required] public virtual required string? Name { get; init; }
// }