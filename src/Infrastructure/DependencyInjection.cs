using Microsoft.Extensions.DependencyInjection;
using OrderManager.Core.Common.Abstractions;
using OrderManager.Infrastructure.Services;

namespace OrderManager.Infrastructure;

public static class DependencyInjection
{
    public static IServiceCollection AddServices(this IServiceCollection services)
    {
        services.AddSingleton<IEmailSender, EmailSender>();

        return services;
    }
}