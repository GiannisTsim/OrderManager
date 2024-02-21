using Microsoft.Extensions.Logging;
using OrderManager.Core.Common.Abstractions;

namespace OrderManager.Infrastructure.Services;

public class EmailSender : IEmailSender
{
    private readonly ILogger<EmailSender> _logger;

    public EmailSender(ILogger<EmailSender> logger)
    {
        _logger = logger;
    }

    public Task SendEmailAsync(string email, string subject, string htmlMessage)
    {
        _logger.LogInformation("OK from SendEmailAsync placeholder");
        return Task.CompletedTask;
    }
}