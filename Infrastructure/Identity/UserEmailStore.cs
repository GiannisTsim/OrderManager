using Microsoft.AspNetCore.Identity;
using OrderManager.Core.Models;

namespace OrderManager.Infrastructure.Identity;

public partial class UserStore : IUserEmailStore<ApplicationUser>
{
    public Task SetEmailAsync(ApplicationUser user, string? email, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));
        user.Email = email;
        return Task.CompletedTask;
    }

    public Task<string?> GetEmailAsync(ApplicationUser user, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));
        return Task.FromResult(user.Email);
    }

    public Task<bool> GetEmailConfirmedAsync(ApplicationUser user, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));
        return Task.FromResult(user.EmailConfirmed);
    }

    public Task SetEmailConfirmedAsync(ApplicationUser user, bool emailConfirmed, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));
        user.EmailConfirmed = emailConfirmed;
        return Task.CompletedTask;
    }

    public async Task<ApplicationUser?> FindByEmailAsync(string normalizedEmail, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (normalizedEmail == null) throw new ArgumentNullException(nameof(normalizedEmail));
        var person = await _personRepository.GetByEmailAsync(normalizedEmail);
        if (person != null)
            return new ApplicationUser
            {
                Id = (int)person.PersonNo!,
                UserName = person.UserName,
                NormalizedUserName = person.UserName.ToUpper(),
                Email = person.Email,
                NormalizedEmail = person.Email.ToUpper(),
                EmailConfirmed = person.EmailConfirmed,
                PasswordHash = person.PasswordHash,
                SecurityStamp = person.SecurityStamp,
                PhoneNumber = person.PhoneNumber,
                PhoneNumberConfirmed = person.PhoneNumberConfirmed ?? false,
                LockoutEnabled = person.LockoutEnabled ?? _identityOptions.Lockout.AllowedForNewUsers,
                AccessFailedCount = person.AccessFailedCount ?? 0,
                LockoutEnd = person.LockoutEnd,
                UpdatedDtm = (DateTimeOffset)person.UpdatedDtm!
            };

        return null;
    }

    public Task<string?> GetNormalizedEmailAsync(ApplicationUser user, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));
        return Task.FromResult(user.NormalizedEmail);
    }

    public Task SetNormalizedEmailAsync(
        ApplicationUser user,
        string? normalizedEmail,
        CancellationToken cancellationToken
    )
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));
        user.NormalizedEmail = normalizedEmail;
        return Task.CompletedTask;
    }
}