using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using OrderManager.Core.Abstractions;
using OrderManager.Core.Abstractions.Repositories;
using OrderManager.Core.Models;

namespace OrderManager.Infrastructure.Repositories;

public class RoleRepository : IRoleRepository
{
    private readonly IConfiguration _configuration;

    public RoleRepository(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public async Task<IEnumerable<Role>> GetAllAsync()
    {
        const string query = """
                             SELECT Role.RoleCode,
                                    Role.Name
                             FROM Role
                             """;
        await using var connection = new SqlConnection(_configuration.GetConnectionString("PersonAdminConnection"));
        return await connection.QueryAsync<Role>(query);
    }

    public async Task<Role?> GetByCodeAsync(string roleCode)
    {
        const string query = """
                             SELECT Role.RoleCode,
                                    Role.Name
                             FROM Role
                             WHERE RoleCode = @RoleCode
                             """;
        await using var connection = new SqlConnection(_configuration.GetConnectionString("PersonAdminConnection"));
        return await connection.QuerySingleOrDefaultAsync<Role>(query, new { RoleCode = roleCode });
    }

    public async Task<Role?> GetByNameAsync(string normalizedName)
    {
        const string query = """
                             SELECT Role.RoleCode,
                                    Role.Name
                             FROM Role
                             WHERE UPPER(Name) = @NormalizedName
                             """;
        await using var connection = new SqlConnection(_configuration.GetConnectionString("PersonAdminConnection"));
        return await connection.QuerySingleOrDefaultAsync<Role>(query, new { NormalizedName = normalizedName });
    }

    public async Task<IEnumerable<Role>> GetByPersonAsync(int personNo)
    {
        const string query = """
                             SELECT Role.RoleCode,
                                    Role.Name
                             FROM Role
                             INNER JOIN PersonRole
                             ON Role.RoleCode = PersonRole.RoleCode
                             WHERE PersonNo = @PersonNo
                             """;
        await using var connection = new SqlConnection(_configuration.GetConnectionString("PersonAdminConnection"));
        return await connection.QueryAsync<Role>(query, new { PersonNo = personNo });
    }
}