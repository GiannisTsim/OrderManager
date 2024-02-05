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
        services.AddTransient<IRetailerRepository, RetailerRepository>();
        services.AddTransient<IRetailerBranchRepository, RetailerBranchRepository>();

        return services;
    }
}