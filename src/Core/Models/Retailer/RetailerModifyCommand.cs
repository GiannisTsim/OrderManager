namespace OrderManager.Core.Models.Retailer;

public record RetailerModifyCommand(
    int RetailerNo,
    DateTimeOffset UpdatedDtm,
    string VatId,
    string Name
);

// public record RetailerModifyCommand
// {
//     [Required] public virtual required int RetailerNo { get; init; }
//     [Required] public virtual required DateTimeOffset UpdatedDtm { get; init; }
//     [Required] public virtual required string VatId { get; init; }
//     [Required] public virtual required string Name { get; init; }
// }

// public record RetailerModifyCommand
// {
//     [Required] public virtual required int? RetailerNo { get; init; }
//     [Required] public virtual required DateTimeOffset? UpdatedDtm { get; init; }
//     [Required] public virtual required string? VatId { get; init; }
//     [Required] public virtual required string? Name { get; init; }
// }