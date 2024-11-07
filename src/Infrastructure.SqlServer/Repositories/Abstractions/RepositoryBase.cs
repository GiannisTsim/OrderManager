using Microsoft.Data.SqlClient;
using OrderManager.Infrastructure.SqlServer.Abstractions;

namespace OrderManager.Infrastructure.SqlServer.Repositories.Abstractions;

public abstract class RepositoryBase
{
    private readonly IConnectionStringProvider _connectionStringProvider;

    protected RepositoryBase(IConnectionStringProvider sqlCredentialProvider)
    {
        _connectionStringProvider = sqlCredentialProvider;
    }

    protected SqlConnection SqlConnection => new(_connectionStringProvider.GetConnectionString());
}