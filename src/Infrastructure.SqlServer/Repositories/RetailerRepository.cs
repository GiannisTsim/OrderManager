using System.Data;
using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using OrderManager.Core.Retailer.Abstractions;
using OrderManager.Core.Retailer.Commands.Retailer;
using OrderManager.Core.Retailer.Exceptions.Retailer;
using OrderManager.Core.Retailer.Models;
using OrderManager.Infrastructure.SqlServer.Constants;

namespace OrderManager.Infrastructure.SqlServer.Repositories;

public class RetailerRepository : IRetailerRepository
{
    private readonly IConfiguration _configuration;

    public RetailerRepository(IConfiguration configuration)
    {
        _configuration = configuration;
    }

    // TODO: Simplify query string or move in database function
    public async Task<IEnumerable<RetailerDetails>> GetDetailsAsync(
        string? searchTerm = null,
        string? sortColumn = null,
        bool? isDescending = false,
        int? pageNo = 1,
        int? pageSize = 10)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        var retailers = await connection.QueryAsync<RetailerDetails>(
            """
            SELECT RetailerNo,
                   TaxId,
                   Name,
                   UpdatedDtm,
                   IsObsolete,
                   BranchCount
            FROM Retailer_V
            WHERE (TaxId LIKE @SearchTerm + '%' OR @SearchTerm IS NULL)
               OR (Name LIKE @SearchTerm + '%' OR @SearchTerm IS NULL)
            ORDER BY CASE WHEN @SortColumn IS NULL THEN RetailerNo END,
                     CASE WHEN @SortColumn = 'TaxId' AND @IsDescending = 0 THEN TaxId END,
                     CASE WHEN @SortColumn = 'TaxId' AND @IsDescending = 1 THEN TaxId END DESC,
                     CASE WHEN @SortColumn = 'Name' AND @IsDescending = 0 THEN Name END,
                     CASE WHEN @SortColumn = 'Name' AND @IsDescending = 1 THEN Name END DESC
            OFFSET (@PageNo - 1) * @PageSize ROWS FETCH NEXT @PageSize ROWS ONLY
            """,
            new
            {
                SearchTerm = searchTerm, SortColumn = sortColumn, IsDescending = isDescending,
                PageNo = pageNo, PageSize = pageSize
            }
        );
        return retailers;
    }

    // TODO: Simplify query string or move in database function
    public async Task<int> GetTotalResultCountAsync(string? searchTerm = null)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        var totalResultCount = await connection.ExecuteScalarAsync<int>(
            """
            SELECT COUNT(*)
            FROM Retailer_V
            WHERE (TaxId LIKE @SearchTerm + '%' OR @SearchTerm IS NULL)
               OR (Name LIKE @SearchTerm + '%' OR @SearchTerm IS NULL)
            """,
            new { SearchTerm = searchTerm }
        );
        return totalResultCount;
    }

    public async Task<RetailerDetails?> FindDetailsByRetailerNoAsync(int retailerNo)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        var retailer = await connection.QuerySingleOrDefaultAsync<RetailerDetails>(
            """
            SELECT RetailerNo,
                   TaxId,
                   Name,
                   UpdatedDtm,
                   IsObsolete,
                   BranchCount
            FROM Retailer_V
            WHERE RetailerNo = @RetailerNo
            """,
            new { RetailerNo = retailerNo }
        );
        return retailer;
    }

    public async Task<RetailerSimple?> FindByTaxIdAsync(string taxId)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        var retailer = await connection.QuerySingleOrDefaultAsync<RetailerSimple>(
            """
            SELECT RetailerNo,
                   TaxId,
                   Name
            FROM Retailer
            WHERE TaxId = @TaxId
            """,
            new { TaxId = taxId }
        );
        return retailer;
    }

    public async Task<RetailerSimple?> FindByNameAsync(string name)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        var retailer = await connection.QuerySingleOrDefaultAsync<RetailerSimple>(
            """
            SELECT RetailerNo,
                   TaxId,
                   Name
            FROM Retailer
            WHERE Name = @Name
            """,
            new { Name = name }
        );
        return retailer;
    }

    public async Task<int> AddAsync(RetailerAddCommand command)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        try
        {
            var p = new DynamicParameters(new { command.TaxId, command.Name });
            p.Add("@RetailerNo", DbType.Int32, direction: ParameterDirection.Output);
            await connection.ExecuteAsync("Retailer_Add_tr", p, commandType: CommandType.StoredProcedure);
            var retailerNo = p.Get<int>("@RetailerNo");
            return retailerNo;
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerInvalidTaxId)
        {
            throw new RetailerInvalidTaxIdException(command.TaxId, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerInvalidName)
        {
            throw new RetailerInvalidNameException(command.Name, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerDuplicateTaxId)
        {
            throw new RetailerDuplicateTaxIdException(command.TaxId, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerDuplicateName)
        {
            throw new RetailerDuplicateNameException(command.Name, ex);
        }
    }

    public async Task ModifyAsync(RetailerModifyCommand command)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        try
        {
            await connection.ExecuteAsync(
                "Retailer_Modify_tr",
                new { command.RetailerNo, command.UpdatedDtm, command.TaxId, command.Name },
                commandType: CommandType.StoredProcedure
            );
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerInvalidTaxId)
        {
            throw new RetailerInvalidTaxIdException(command.TaxId, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerInvalidName)
        {
            throw new RetailerInvalidNameException(command.Name, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerNotFound)
        {
            throw new RetailerNotFoundException(command.RetailerNo, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerCurrencyLost)
        {
            throw new RetailerCurrencyLostException(command.RetailerNo, command.UpdatedDtm, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerDuplicateTaxId)
        {
            throw new RetailerDuplicateTaxIdException(command.TaxId, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerDuplicateName)
        {
            throw new RetailerDuplicateNameException(command.Name, ex);
        }
    }

    public async Task ObsoleteAsync(RetailerObsoleteCommand command)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        try
        {
            await connection.ExecuteAsync(
                "Retailer_Obsolete_tr",
                new { command.RetailerNo, command.UpdatedDtm },
                commandType: CommandType.StoredProcedure
            );
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerNotFound)
        {
            throw new RetailerNotFoundException(command.RetailerNo, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerCurrencyLost)
        {
            throw new RetailerCurrencyLostException(command.RetailerNo, command.UpdatedDtm, ex);
        }
    }

    public async Task RestoreAsync(RetailerRestoreCommand command)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        try
        {
            await connection.ExecuteAsync(
                "Retailer_Restore_tr",
                new { command.RetailerNo, command.UpdatedDtm },
                commandType: CommandType.StoredProcedure
            );
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerNotFound)
        {
            throw new RetailerNotFoundException(command.RetailerNo, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerCurrencyLost)
        {
            throw new RetailerCurrencyLostException(command.RetailerNo, command.UpdatedDtm, ex);
        }
    }
}