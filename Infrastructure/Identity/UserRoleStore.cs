using Microsoft.AspNetCore.Identity;
using OrderManager.Core.Models;

namespace OrderManager.Infrastructure.Identity;

public partial class UserStore : IUserRoleStore<ApplicationUser>
{
    public async Task AddToRoleAsync(ApplicationUser user, string roleCode, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));
        if (roleCode == null) throw new ArgumentNullException(nameof(roleCode));
        await _personRepository.AddToRoleAsync(user.Id, user.UpdatedDtm, roleCode);
    }

    public async Task RemoveFromRoleAsync(ApplicationUser user, string roleCode, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));
        if (roleCode == null) throw new ArgumentNullException(nameof(roleCode));
        await _personRepository.RemoveFromRoleAsync(user.Id, user.UpdatedDtm, roleCode);
    }

    public async Task<IList<string>> GetRolesAsync(ApplicationUser user, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));
        return (await _roleRepository.GetByPersonAsync(user.Id)).Select(role => role.RoleCode).ToList();
    }

    public async Task<bool> IsInRoleAsync(ApplicationUser user, string roleCode, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));
        if (roleCode == null) throw new ArgumentNullException(nameof(roleCode));
        return await _personRepository.CheckRoleMembershipAsync(user.Id, roleCode);
    }

    public async Task<IList<ApplicationUser>> GetUsersInRoleAsync(string roleCode, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (roleCode == null) throw new ArgumentNullException(nameof(roleCode));
        var persons = await _personRepository.GetByRoleAsync(roleCode);
        return persons.Select
        (
            person => new ApplicationUser
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
            }
        ).ToList();
    }
}