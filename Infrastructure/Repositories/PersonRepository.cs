using System.Data;
using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using OrderManager.Core.Abstractions;
using OrderManager.Core.Abstractions.Repositories;
using OrderManager.Core.Models;

namespace OrderManager.Infrastructure.Repositories;

public class PersonRepository : IPersonRepository
{
    private readonly IConfiguration _configuration;

    public PersonRepository(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    public async Task AddToRoleAsync(int personNo, DateTimeOffset personUpdatedDtm, string roleCode)
    {
        const string query = "PersonRole_Add_tr";
        await using var connection = new SqlConnection(_configuration.GetConnectionString("PersonAdminConnection"));
        await connection.ExecuteAsync
        (
            query,
            new { PersonNo = personNo, PersonUpdatedDtm = personUpdatedDtm, RoleCode = roleCode },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task RemoveFromRoleAsync(int personNo, DateTimeOffset personUpdatedDtm, string roleCode)
    {
        const string query = "PersonRole_Drop_tr";
        await using var connection = new SqlConnection(_configuration.GetConnectionString("PersonAdminConnection"));
        await connection.ExecuteAsync
        (
            query,
            new { PersonNo = personNo, PersonUpdatedDtm = personUpdatedDtm, RoleCode = roleCode },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<bool> CheckRoleMembershipAsync(int personNo, string roleCode)
    {
        const string query = """
                             SELECT true FROM PersonRole
                             WHERE PersonNo = @PersonNo
                             AND RoleCode = @RoleCode
                             """;
        await using var connection = new SqlConnection(_configuration.GetConnectionString("PersonAdminConnection"));
        return await connection.ExecuteScalarAsync<bool>(query, new { PersonNo = personNo, RoleCode = roleCode });
    }

    public async Task<IEnumerable<Person>> GetAllAsync()
    {
        const string query = """
                             SELECT PersonNo,
                                    UserName,
                                    Email,
                                    EmailConfirmed,
                                    PhoneNumber,
                                    PhoneNumberConfirmed,
                                    PasswordHash,
                                    SecurityStamp,
                                    LockoutEnabled,
                                    LockoutEnd,
                                    AccessFailedCount,
                                    UpdatedDtm
                             FROM Person_V
                             WHERE IsObsolete != 1
                             """;
        await using var connection = new SqlConnection(_configuration.GetConnectionString("PersonAdminConnection"));
        return await connection.QueryAsync<Person>(query);
    }

    public async Task<Person?> GetByPersonNoAsync(int personNo)
    {
        const string query = """
                             SELECT PersonNo,
                                    UserName,
                                    Email,
                                    EmailConfirmed,
                                    PasswordHash,
                                    SecurityStamp,
                                    LockoutEnabled,
                                    LockoutEnd,
                                    AccessFailedCount,
                                    PhoneNumber,
                                    PhoneNumberConfirmed,
                                    UpdatedDtm
                             FROM Person_V
                             WHERE PersonNo = @PersonNo
                             AND IsObsolete != 1
                             """;
        await using var connection = new SqlConnection(_configuration.GetConnectionString("PersonAdminConnection"));
        return await connection.QuerySingleOrDefaultAsync<Person?>(query, new { PersonNo = personNo });
    }

    public async Task<Person?> GetByEmailAsync(string normalizedEmail)
    {
        const string query = """
                             SELECT PersonNo,
                                    UserName,
                                    Email,
                                    EmailConfirmed,
                                    PasswordHash,
                                    SecurityStamp,
                                    LockoutEnabled,
                                    LockoutEnd,
                                    AccessFailedCount,
                                    PhoneNumber,
                                    PhoneNumberConfirmed,
                                    UpdatedDtm
                             FROM Person_V
                             WHERE UPPER(Email) = @NormalizedEmail
                             AND IsObsolete != 1
                             """;
        await using var connection = new SqlConnection(_configuration.GetConnectionString("PersonAdminConnection"));
        return await connection.QuerySingleOrDefaultAsync<Person?>(query, new { NormalizedEmail = normalizedEmail });
    }

    public async Task<Person?> GetByUserNameAsync(string normalizedUserName)
    {
        const string query = """
                             SELECT PersonNo,
                                    UserName,
                                    Email,
                                    EmailConfirmed,
                                    PasswordHash,
                                    SecurityStamp,
                                    LockoutEnabled,
                                    LockoutEnd,
                                    AccessFailedCount,
                                    PhoneNumber,
                                    PhoneNumberConfirmed,
                                    UpdatedDtm
                             FROM Person_V
                             WHERE UPPER(UserName) = @NormalizedUserName
                             AND IsObsolete != 1
                             """;
        await using var connection = new SqlConnection(_configuration.GetConnectionString("PersonAdminConnection"));
        return await connection.QuerySingleOrDefaultAsync<Person?>
        (
            query,
            new { NormalizedUserName = normalizedUserName }
        );
    }

    public async Task AddAsync(Person person)
    {
        const string query = "Person_Add_tr";
        await using var connection = new SqlConnection(_configuration.GetConnectionString("PersonAdminConnection"));
        var result = await connection.ExecuteAsync
        (
            query,
            new
            {
                person.UserName, person.Email, person.EmailConfirmed, person.PasswordHash, person.SecurityStamp,
                person.LockoutEnabled, person.LockoutEnd, person.AccessFailedCount, person.PhoneNumber,
                person.PhoneNumberConfirmed
            },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task ModifyAsync(Person person)
    {
        const string query = "Person_Modify_tr";
        await using var connection = new SqlConnection(_configuration.GetConnectionString("PersonAdminConnection"));
        await connection.ExecuteAsync
        (
            query,
            new
            {
                person.PersonNo, person.UpdatedDtm, person.UserName, person.Email, person.EmailConfirmed,
                person.PasswordHash, person.SecurityStamp, person.LockoutEnabled, person.LockoutEnd,
                person.AccessFailedCount, person.PhoneNumber, person.PhoneNumberConfirmed
            },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task<IEnumerable<Person>> GetByRoleAsync(string roleCode)
    {
        const string query = """
                             SELECT Person_V.PersonNo,
                                    UserName,
                                    Email,
                                    EmailConfirmed,
                                    PasswordHash,
                                    SecurityStamp,
                                    LockoutEnabled,
                                    LockoutEnd,
                                    AccessFailedCount,
                                    PhoneNumber,
                                    PhoneNumberConfirmed,
                                    UpdatedDtm
                             FROM Person_V
                             INNER JOIN PersonRole
                             ON Person_V.PersonNo = PersonRole.PersonNo
                             WHERE RoleCode = @RoleCode
                             AND IsObsolete != 1
                             """;
        await using var connection = new SqlConnection(_configuration.GetConnectionString("PersonAdminConnection"));
        return await connection.QueryAsync<Person>(query, new { RoleCode = roleCode });
    }

    public async Task DropAsync(Person person)
    {
        const string query = "Person_Drop_tr";
        await using var connection = new SqlConnection(_configuration.GetConnectionString("PersonAdminConnection"));
        await connection.ExecuteAsync
        (
            query,
            new { person.PersonNo, person.UpdatedDtm },
            commandType: CommandType.StoredProcedure
        );
    }
}