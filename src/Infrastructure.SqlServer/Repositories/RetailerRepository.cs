using System.Data;
using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using OrderManager.Core.Retailer.Abstractions;
using OrderManager.Core.Retailer.Exceptions;
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

    public async Task<IEnumerable<RetailerDetails>> GetAsync(
        string? searchTerm = null,
        string? sortColumn = null,
        bool? isDescending = false,
        int? pageNo = 1,
        int? pageSize = 10
    )
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("AdminConnection"));
        var retailers = await connection.QueryAsync<RetailerDetails>
        (
            """
            SELECT RetailerNo,
                   VatId,
                   Name,
                   UpdatedDtm,
                   IsObsolete,
                   BranchCount
            FROM Retailer_V
            WHERE (VatId LIKE @SearchTerm + '%' OR @SearchTerm IS NULL)
               OR (Name LIKE @SearchTerm + '%' OR @SearchTerm IS NULL)
            ORDER BY CASE WHEN @SortColumn IS NULL THEN RetailerNo END,
                     CASE WHEN @SortColumn = 'VatId' AND @IsDescending = 0 THEN VatId END,
                     CASE WHEN @SortColumn = 'VatId' AND @IsDescending = 1 THEN VatId END DESC,
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

    public async Task<int> GetTotalResultCountAsync(
        string? searchTerm = null
    )
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("AdminConnection"));
        var totalResultCount = await connection.ExecuteScalarAsync<int>
        (
            """
            SELECT COUNT(*)
            FROM Retailer_V
            WHERE (VatId LIKE @SearchTerm + '%' OR @SearchTerm IS NULL)
               OR (Name LIKE @SearchTerm + '%' OR @SearchTerm IS NULL)
            """,
            new { SearchTerm = searchTerm }
        );
        return totalResultCount;
    }

    public async Task<RetailerDetails?> FindByRetailerNoAsync(int retailerNo)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("AdminConnection"));
        var retailer = await connection.QuerySingleOrDefaultAsync<RetailerDetails>
        (
            """
            SELECT RetailerNo,
                   VatId,
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

    public async Task<RetailerDetails?> FindByVatIdAsync(string vatId)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("AdminConnection"));
        var retailer = await connection.QuerySingleOrDefaultAsync<RetailerDetails>
        (
            """
            SELECT RetailerNo,
                   VatId,
                   Name,
                   UpdatedDtm,
                   IsObsolete,
                   BranchCount
            FROM Retailer_V
            WHERE VatId = @VatId
            """,
            new { VatId = vatId }
        );
        return retailer;
    }

    public async Task<RetailerDetails?> FindByNameAsync(string name)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("AdminConnection"));
        var retailer = await connection.QuerySingleOrDefaultAsync<RetailerDetails>
        (
            """
            SELECT RetailerNo,
                   VatId,
                   Name,
                   UpdatedDtm,
                   IsObsolete,
                   BranchCount
            FROM Retailer_V
            WHERE Name = @Name
            """,
            new { Name = name }
        );
        return retailer;
    }

    public async Task<bool> VerifyExistenceByVatIdAsync(string vatId)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("AdminConnection"));
        var retailerExists = await connection.ExecuteScalarAsync<bool>
        (
            """
            SELECT CASE WHEN EXISTS (SELECT 1 FROM Retailer WHERE VatId = @VatId) THEN 1 ELSE 0 END
            """,
            new { VatId = vatId }
        );
        return retailerExists;
    }

    public async Task<bool> VerifyExistenceByNameAsync(string name)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("AdminConnection"));
        var retailerExists = await connection.ExecuteScalarAsync<bool>
        (
            """
            SELECT COALESCE ((SELECT 1 FROM Retailer WHERE Name = @Name), 0)
            """,
            new { Name = name }
        );
        return retailerExists;
    }

    public async Task<bool> VerifyCurrencyAsync(int retailerNo, DateTimeOffset updatedDtm)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("AdminConnection"));
        var retailerIsCurrent = await connection.ExecuteScalarAsync<bool>
        (
            """
            SELECT COALESCE((SELECT 1 FROM Retailer WHERE RetailerNo = @RetailerNo AND UpdatedDtm = @UpdatedDtm), 0);
            """,
            new { RetailerNo = retailerNo, UpdatedDtm = updatedDtm }
        );

        return retailerIsCurrent;
    }

    public async Task<int> AddAsync(RetailerAddCommand retailer)
    {
        var p = new DynamicParameters(retailer);
        p.Add("@RetailerNo", DbType.Int32, direction: ParameterDirection.Output);

        await using var connection = new SqlConnection(_configuration.GetConnectionString("AdminConnection"));

        try
        {
            await connection.ExecuteAsync
            (
                "Retailer_Add_tr",
                p,
                commandType: CommandType.StoredProcedure
            );

            var retailerNo = p.Get<int>("@RetailerNo");
            return retailerNo;
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerInvalidVatId)
        {
            throw new RetailerInvalidVatIdException(retailer.VatId, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerInvalidName)
        {
            throw new RetailerInvalidNameException(retailer.Name, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerDuplicateVatId)
        {
            throw new RetailerDuplicateVatIdException(retailer.VatId, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerDuplicateName)
        {
            throw new RetailerDuplicateNameException(retailer.Name, ex);
        }
    }

    public async Task ModifyAsync(RetailerModifyCommand retailer)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("AdminConnection"));

        try
        {
            await connection.ExecuteAsync
            (
                "Retailer_Modify_tr",
                new { retailer.RetailerNo, retailer.UpdatedDtm, retailer.VatId, retailer.Name },
                commandType: CommandType.StoredProcedure
            );
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerInvalidVatId)
        {
            throw new RetailerInvalidVatIdException(retailer.VatId, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerInvalidName)
        {
            throw new RetailerInvalidNameException(retailer.Name, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerNotFound)
        {
            throw new RetailerNotFoundException(retailer.RetailerNo, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerCurrencyLost)
        {
            throw new RetailerCurrencyLostException(retailer.RetailerNo, retailer.UpdatedDtm, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerDuplicateVatId)
        {
            throw new RetailerDuplicateVatIdException(retailer.VatId, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerDuplicateName)
        {
            throw new RetailerDuplicateNameException(retailer.Name, ex);
        }
    }

    public async Task ObsoleteAsync(RetailerObsoleteCommand retailer)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("AdminConnection"));

        try
        {
            await connection.ExecuteAsync
            (
                "Retailer_Obsolete_tr",
                new { retailer.RetailerNo, retailer.UpdatedDtm },
                commandType: CommandType.StoredProcedure
            );
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerNotFound)
        {
            throw new RetailerNotFoundException(retailer.RetailerNo, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerCurrencyLost)
        {
            throw new RetailerCurrencyLostException(retailer.RetailerNo, retailer.UpdatedDtm, ex);
        }
    }

    public async Task RestoreAsync(RetailerRestoreCommand retailer)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("AdminConnection"));

        try
        {
            await connection.ExecuteAsync
            (
                "Retailer_Restore_tr",
                new { retailer.RetailerNo, retailer.UpdatedDtm },
                commandType: CommandType.StoredProcedure
            );
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerNotFound)
        {
            throw new RetailerNotFoundException(retailer.RetailerNo, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerCurrencyLost)
        {
            throw new RetailerCurrencyLostException(retailer.RetailerNo, retailer.UpdatedDtm, ex);
        }
    }
}