using Microsoft.Extensions.DependencyInjection;
using OrderManager.Core.Retailer.Abstractions;
using OrderManager.Infrastructure.SqlServer.Repositories;

namespace OrderManager.Infrastructure.SqlServer;

public static class DependencyInjection
{
    public static IServiceCollection AddRepositories(this IServiceCollection services)
    {
        services.AddSingleton<IRetailerRepository, RetailerRepository>();
        services.AddSingleton<IRetailerBranchRepository, RetailerBranchRepository>();
        services.AddSingleton<IRetailerBranchAgentRepository, RetailerBranchAgentRepository>();

        return services;
    }
}