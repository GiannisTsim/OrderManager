namespace OrderManager.Infrastructure.SqlServer.Abstractions;

public interface IConnectionStringProvider
{
    public string GetConnectionString();
}