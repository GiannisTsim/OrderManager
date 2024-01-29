namespace OrderManager.Core.Models;

public class Person
{
    public int? PersonNo { get; init; }
    public required string UserName { get; init; }
    public required string Email { get; init; }
    public required bool EmailConfirmed { get; init; }
    public required string SecurityStamp { get; init; }
    public DateTimeOffset? UpdatedDtm { get; init; }
    public string? PasswordHash { get; init; }
    public bool? LockoutEnabled { get; init; }
    public int? AccessFailedCount { get; init; }
    public DateTimeOffset? LockoutEnd { get; init; }
    public string? PhoneNumber { get; init; }
    public bool? PhoneNumberConfirmed { get; init; }
}