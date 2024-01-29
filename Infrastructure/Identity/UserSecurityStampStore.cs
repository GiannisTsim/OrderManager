using Microsoft.AspNetCore.Identity;
using OrderManager.Core.Models;

namespace OrderManager.Infrastructure.Identity;

public partial class UserStore : IUserSecurityStampStore<ApplicationUser>
{
    public Task SetSecurityStampAsync(ApplicationUser user, string securityStamp, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));
        user.SecurityStamp = securityStamp;
        return Task.CompletedTask;
    }

    public Task<string?> GetSecurityStampAsync(ApplicationUser user, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));
        return Task.FromResult(user.SecurityStamp);
    }
}