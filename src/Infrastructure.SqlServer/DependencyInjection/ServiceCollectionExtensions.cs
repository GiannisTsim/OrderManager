using Microsoft.Extensions.DependencyInjection;
using OrderManager.Core.Retailer.Abstractions;
using OrderManager.Infrastructure.SqlServer.Repositories;

namespace OrderManager.Infrastructure.SqlServer.DependencyInjection;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddRepositories(this IServiceCollection services)
    {
        services.AddTransient<IRetailerRepository, RetailerRepository>();
        services.AddTransient<IRetailerBranchRepository, RetailerBranchRepository>();

        return services;
    }
}