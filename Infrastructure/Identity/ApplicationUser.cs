using Microsoft.AspNetCore.Identity;

namespace OrderManager.Infrastructure.Identity;

public class ApplicationUser : IdentityUser<int>
{
    public DateTimeOffset UpdatedDtm { get; init; }
}