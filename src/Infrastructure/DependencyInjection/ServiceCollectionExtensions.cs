using Microsoft.Extensions.DependencyInjection;
using OrderManager.Core.Abstractions.Services;
using OrderManager.Infrastructure.Services;

namespace OrderManager.Infrastructure.DependencyInjection;

public static class ServiceCollectionExtensions
{
    public static IServiceCollection AddServices(this IServiceCollection services)
    {
        services.AddTransient<IEmailSender, EmailSender>();

        return services;
    }
}