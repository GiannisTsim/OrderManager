using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.DependencyInjection;

namespace OrderManager.Infrastructure.Identity;

public static class IdentityBuilderExtensions
{
    public static IdentityBuilder AddCustomUserStore<TUserStore>(
        this IdentityBuilder builder
    )
        where TUserStore : class
    {
        builder.Services.AddTransient(typeof(IUserStore<>).MakeGenericType(builder.UserType), typeof(TUserStore));
        return builder;
    }

    public static IdentityBuilder AddCustomRoleStore<TRoleStore>(
        this IdentityBuilder builder
    )
        where TRoleStore : class
    {
        if (builder.RoleType == null) throw new InvalidOperationException();
        builder.Services.AddTransient(typeof(IRoleStore<>).MakeGenericType(builder.RoleType), typeof(TRoleStore));
        return builder;
    }
}