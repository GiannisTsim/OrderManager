using JetBrains.Annotations;
using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using OrderManager.Core.Abstractions;
using OrderManager.Core.Abstractions.Repositories;
using OrderManager.Core.Models;

namespace OrderManager.Infrastructure.Identity;

[UsedImplicitly]
public partial class UserStore : IUserStore<ApplicationUser>
{
    private readonly IdentityErrorDescriber _errorDescriber;
    private readonly IdentityOptions _identityOptions;
    private readonly ILogger<UserStore> _logger;
    private readonly IPersonRepository _personRepository;
    private readonly IRoleRepository _roleRepository;
    private bool _disposed;

    public UserStore(
        IOptions<IdentityOptions> identityOptionsAccessor,
        IdentityErrorDescriber errorDescriber,
        IPersonRepository personRepository,
        ILogger<UserStore> logger,
        IRoleRepository roleRepository
    )
    {
        _identityOptions = identityOptionsAccessor.Value;
        _errorDescriber = errorDescriber ?? throw new ArgumentNullException(nameof(errorDescriber));
        _personRepository = personRepository;
        _logger = logger;
        _roleRepository = roleRepository;
    }

    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);
    }

    public Task<string> GetUserIdAsync(ApplicationUser user, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));
        return Task.FromResult(user.Id.ToString());
    }

    public Task<string?> GetUserNameAsync(ApplicationUser user, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));
        return Task.FromResult(user.UserName);
    }

    public Task SetUserNameAsync(ApplicationUser user, string? userName, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));
        user.UserName = userName;
        return Task.CompletedTask;
    }

    public Task<string?> GetNormalizedUserNameAsync(ApplicationUser user, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));
        return Task.FromResult(user.NormalizedUserName);
    }

    public Task SetNormalizedUserNameAsync(
        ApplicationUser user,
        string? normalizedUserName,
        CancellationToken cancellationToken
    )
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));
        user.NormalizedUserName = normalizedUserName;
        return Task.CompletedTask;
    }

    public async Task<IdentityResult> CreateAsync(ApplicationUser user, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));

        var newPerson = new Person
        {
            UserName = user.UserName ?? throw new InvalidOperationException(),
            Email = user.Email ?? throw new InvalidOperationException(),
            EmailConfirmed = user.EmailConfirmed,
            PasswordHash = user.PasswordHash ?? throw new InvalidOperationException(),
            SecurityStamp = user.SecurityStamp ?? throw new InvalidOperationException(),
            PhoneNumber = user.PhoneNumber,
            PhoneNumberConfirmed = user.PhoneNumberConfirmed,
            LockoutEnabled = user.LockoutEnabled,
            LockoutEnd = user.LockoutEnd,
            AccessFailedCount = user.AccessFailedCount
        };

        try
        {
            await _personRepository.AddAsync(newPerson);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex.Message);
            return IdentityResult.Failed();
        }

        return IdentityResult.Success;
    }

    public async Task<IdentityResult> UpdateAsync(ApplicationUser user, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));

        var modifiedPerson = new Person
        {
            PersonNo = user.Id,
            UserName = user.UserName ?? throw new InvalidOperationException(),
            Email = user.Email ?? throw new InvalidOperationException(),
            EmailConfirmed = user.EmailConfirmed,
            PasswordHash = user.PasswordHash ?? throw new InvalidOperationException(),
            SecurityStamp = user.SecurityStamp ?? throw new InvalidOperationException(),
            PhoneNumber = user.PhoneNumber,
            PhoneNumberConfirmed = user.PhoneNumberConfirmed,
            LockoutEnabled = user.LockoutEnabled,
            LockoutEnd = user.LockoutEnd,
            AccessFailedCount = user.AccessFailedCount,
            UpdatedDtm = user.UpdatedDtm
        };

        try
        {
            await _personRepository.ModifyAsync(modifiedPerson);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex.Message);
            return IdentityResult.Failed();
        }

        return IdentityResult.Success;
    }

    public async Task<IdentityResult> DeleteAsync(ApplicationUser user, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (user == null) throw new ArgumentNullException(nameof(user));

        var person = new Person
        {
            PersonNo = user.Id,
            UserName = user.UserName ?? throw new InvalidOperationException(),
            Email = user.Email ?? throw new InvalidOperationException(),
            EmailConfirmed = user.EmailConfirmed,
            PasswordHash = user.PasswordHash ?? throw new InvalidOperationException(),
            SecurityStamp = user.SecurityStamp ?? throw new InvalidOperationException(),
            PhoneNumber = user.PhoneNumber,
            PhoneNumberConfirmed = user.PhoneNumberConfirmed,
            LockoutEnabled = user.LockoutEnabled,
            LockoutEnd = user.LockoutEnd,
            AccessFailedCount = user.AccessFailedCount,
            UpdatedDtm = user.UpdatedDtm
        };

        try
        {
            await _personRepository.DropAsync(person);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex.Message);
            return IdentityResult.Failed();
        }

        return IdentityResult.Success;
    }

    public async Task<ApplicationUser?> FindByIdAsync(string userId, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (userId == null) throw new ArgumentNullException(nameof(userId));
        var person = await _personRepository.GetByPersonNoAsync(int.Parse(userId));
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

    public async Task<ApplicationUser?> FindByNameAsync(string normalizedUserName, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (normalizedUserName == null) throw new ArgumentNullException(nameof(normalizedUserName));
        var person = await _personRepository.GetByUserNameAsync(normalizedUserName);
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

    protected virtual void Dispose(bool disposing)
    {
        if (_disposed) return;
        _disposed = true;
    }

    ~UserStore()
    {
        Dispose(false);
    }

    private void ThrowIfDisposed()
    {
        if (_disposed) throw new ObjectDisposedException(GetType().FullName);
    }
}