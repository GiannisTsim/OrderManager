using OrderManager.Infrastructure.SqlServer.Abstractions;

namespace OrderManager.Web.SqlConnection;

public class ConnectionStringProvider : IConnectionStringProvider
{
    private readonly ILogger<ConnectionStringProvider> _logger;
    private readonly IConfiguration _configuration;


    public ConnectionStringProvider(ILogger<ConnectionStringProvider> logger, IConfiguration configuration)
    {
        _logger = logger;
        _configuration = configuration;
    }

    public string GetConnectionString()
    {
        var sqlConnectionContext = SqlConnectionContext.Current;
        if (sqlConnectionContext == null)
        {
            throw new InvalidOperationException("SqlConnectionContext is null");
        }

        if (sqlConnectionContext.ConnectionStringName == null)
        {
            throw new InvalidOperationException($"SqlConnectionContext.ConnectionStringName is null");
        }

        var connectionString = _configuration.GetConnectionString(sqlConnectionContext.ConnectionStringName);
        if (connectionString == null)
        {
            throw new InvalidOperationException(
                $"Connection string '{sqlConnectionContext.ConnectionStringName}' not found");
        }

        return connectionString;
    }
}