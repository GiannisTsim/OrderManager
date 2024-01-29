using Microsoft.Extensions.DependencyInjection;
using OrderManager.Core.Abstractions.Repositories;
using OrderManager.Core.Abstractions.Services;
using OrderManager.Infrastructure.Repositories;
using OrderManager.Infrastructure.Services;

namespace OrderManager.Infrastructure.DependencyInjection;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddServices(this IServiceCollection services)
    {
        services.AddTransient<IEmailSender, EmailSender>();

        return services;
    }

    public static IServiceCollection AddRepositories(this IServiceCollection services)
    {
        services.AddTransient<IPersonRepository, PersonRepository>();
        services.AddTransient<IRoleRepository, RoleRepository>();
        services.AddTransient<IRetailerRepository, RetailerRepository>();
        services.AddTransient<IRetailerBranchRepository, RetailerBranchRepository>();

        return services;
    }

    // public static IServiceCollection AddCustomIdentity(this IServiceCollection services)
    // {
    //     services.AddIdentity<ApplicationUser, ApplicationRole>
    //         (
    //             options =>
    //             {
    //                 options.SignIn.RequireConfirmedAccount = true;
    //                 options.User.RequireUniqueEmail = true;
    //             }
    //         )
    //         .AddCustomUserStore<UserStore>()
    //         .AddCustomRoleStore<RoleStore>()
    //         .AddDefaultTokenProviders();
    //
    //     return services;
    // }
}