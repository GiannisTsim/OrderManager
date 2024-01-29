using JetBrains.Annotations;
using Microsoft.AspNetCore.Identity;
using OrderManager.Core.Abstractions;
using OrderManager.Core.Abstractions.Repositories;
using OrderManager.Core.Models;

namespace OrderManager.Infrastructure.Identity;

[UsedImplicitly]
public class RoleStore : IRoleStore<ApplicationRole>
{
    private readonly IdentityErrorDescriber _errorDescriber;
    private readonly IRoleRepository _roleRepository;
    private bool _disposed;

    public RoleStore(IdentityErrorDescriber errorDescriber, IRoleRepository roleRepository)
    {
        _errorDescriber = errorDescriber ?? throw new ArgumentNullException(nameof(errorDescriber));
        _roleRepository = roleRepository;
    }

    public void Dispose()
    {
        Dispose(true);
        GC.SuppressFinalize(this);
    }

    public Task<IdentityResult> CreateAsync(ApplicationRole role, CancellationToken cancellationToken)
    {
        throw new NotImplementedException();
    }

    public Task<IdentityResult> UpdateAsync(ApplicationRole role, CancellationToken cancellationToken)
    {
        throw new NotImplementedException();
    }

    public Task<IdentityResult> DeleteAsync(ApplicationRole role, CancellationToken cancellationToken)
    {
        throw new NotImplementedException();
    }

    public Task<string> GetRoleIdAsync(ApplicationRole role, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (role == null) throw new ArgumentNullException(nameof(role));
        return Task.FromResult(role.Id);
    }

    public Task<string?> GetRoleNameAsync(ApplicationRole role, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (role == null) throw new ArgumentNullException(nameof(role));
        return Task.FromResult(role.Name);
    }

    public Task SetRoleNameAsync(ApplicationRole role, string? roleName, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (role == null) throw new ArgumentNullException(nameof(role));
        role.Name = roleName;
        return Task.CompletedTask;
    }

    public Task<string?> GetNormalizedRoleNameAsync(ApplicationRole role, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (role == null) throw new ArgumentNullException(nameof(role));
        return Task.FromResult(role.NormalizedName);
    }

    public Task SetNormalizedRoleNameAsync(
        ApplicationRole role,
        string? normalizedName,
        CancellationToken cancellationToken
    )
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (role == null) throw new ArgumentNullException(nameof(role));
        role.NormalizedName = normalizedName;
        return Task.CompletedTask;
    }

    public async Task<ApplicationRole?> FindByIdAsync(string roleId, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (roleId == null) throw new ArgumentNullException(nameof(roleId));
        var role = await _roleRepository.GetByCodeAsync(roleId);
        if (role != null)
            return new ApplicationRole
                { Id = role.RoleCode, Name = role.Name, NormalizedName = role.Name.ToUpper() };
        return null;
    }

    public async Task<ApplicationRole?> FindByNameAsync(string normalizedRoleName, CancellationToken cancellationToken)
    {
        cancellationToken.ThrowIfCancellationRequested();
        ThrowIfDisposed();
        if (normalizedRoleName == null) throw new ArgumentNullException(nameof(normalizedRoleName));
        var role = await _roleRepository.GetByNameAsync(normalizedRoleName);
        if (role != null)
            return new ApplicationRole
                { Id = role.RoleCode, Name = role.Name, NormalizedName = role.Name.ToUpper() };
        return null;
    }

    protected virtual void Dispose(bool disposing)
    {
        if (_disposed) return;
        _disposed = true;
    }

    ~RoleStore()
    {
        Dispose(false);
    }

    private void ThrowIfDisposed()
    {
        if (_disposed) throw new ObjectDisposedException(GetType().FullName);
    }
}