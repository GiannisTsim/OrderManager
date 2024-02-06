using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using OrderManager.Core.Abstractions.Repositories;
using OrderManager.Core.Models.RetailerBranch;

namespace OrderManager.Infrastructure.SqlServer.Repositories;

public class RetailerBranchRepository : IRetailerBranchRepository
{
    private readonly IConfiguration _configuration;

    public RetailerBranchRepository(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public async Task<IEnumerable<RetailerBranch>> GetAsync(int retailerNo)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("AdminConnection"));
        return await connection.QueryAsync<RetailerBranch>
        (
            """
            SELECT RetailerNo,
                   BranchNo,
                   Name,
                   UpdatedDtm,
                   IsObsolete,
                   WeeklyDeliveryCount,
                   NextDeliveryDtm
            FROM RetailerBranch_V
            """
        );
    }
}