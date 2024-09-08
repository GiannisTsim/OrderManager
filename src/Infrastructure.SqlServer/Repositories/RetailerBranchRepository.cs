using System.Data;
using Dapper;
using Microsoft.Data.SqlClient;
using Microsoft.Extensions.Configuration;
using OrderManager.Core.Retailer.Abstractions;
using OrderManager.Core.Retailer.Commands.RetailerBranch;
using OrderManager.Core.Retailer.Exceptions.Retailer;
using OrderManager.Core.Retailer.Exceptions.RetailerBranch;
using OrderManager.Core.Retailer.Models;
using OrderManager.Infrastructure.SqlServer.Constants;

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
        await using var connection = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
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

    public async Task<int> AddAsync(RetailerBranchAddCommand command)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        try
        {
            var p = new DynamicParameters(new { command.RetailerNo, command.Name });
            p.Add("@BranchNo", DbType.Int32, direction: ParameterDirection.Output);
            await connection.ExecuteAsync("RetailerBranch_Add_tr", p, commandType: CommandType.StoredProcedure);
            var branchNo = p.Get<int>("@BranchNo");
            return branchNo;
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerBranchInvalidName)
        {
            throw new RetailerBranchInvalidNameException(command.Name, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerBranchDuplicateName)
        {
            throw new RetailerBranchDuplicateNameException(command.RetailerNo, command.Name, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerNotFound)
        {
            throw new RetailerNotFoundException(command.RetailerNo, ex);
        }
    }

    public async Task ModifyAsync(RetailerBranchModifyCommand command)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        try
        {
            await connection.ExecuteAsync
            (
                "RetailerBranch_Modify_tr",
                new { command.RetailerNo, command.BranchNo, command.UpdatedDtm, command.Name },
                commandType: CommandType.StoredProcedure
            );
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerBranchInvalidName)
        {
            throw new RetailerBranchInvalidNameException(command.Name, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerBranchNotFound)
        {
            throw new RetailerBranchNotFoundException(command.RetailerNo, command.BranchNo, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerBranchCurrencyLost)
        {
            throw new RetailerBranchCurrencyLostException
                (command.RetailerNo, command.BranchNo, command.UpdatedDtm, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerBranchDuplicateName)
        {
            throw new RetailerBranchDuplicateNameException(command.RetailerNo, command.Name, ex);
        }
    }

    public async Task ObsoleteAsync(RetailerBranchObsoleteCommand command)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        try
        {
            await connection.ExecuteAsync
            (
                "RetailerBranch_Obsolete_tr",
                new { command.RetailerNo, command.BranchNo, command.UpdatedDtm },
                commandType: CommandType.StoredProcedure
            );
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerBranchNotFound)
        {
            throw new RetailerBranchNotFoundException(command.RetailerNo, command.BranchNo, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerBranchCurrencyLost)
        {
            throw new RetailerBranchCurrencyLostException
                (command.RetailerNo, command.BranchNo, command.UpdatedDtm, ex);
        }
    }

    public async Task RestoreAsync(RetailerBranchRestoreCommand command)
    {
        await using var connection = new SqlConnection(_configuration.GetConnectionString("DefaultConnection"));
        try
        {
            await connection.ExecuteAsync
            (
                "RetailerBranch_Restore_tr",
                new { command.RetailerNo, command.BranchNo, command.UpdatedDtm },
                commandType: CommandType.StoredProcedure
            );
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerBranchNotFound)
        {
            throw new RetailerBranchNotFoundException(command.RetailerNo, command.BranchNo, ex);
        }
        catch (SqlException ex) when (ex.Number == SqlErrorCodes.RetailerBranchCurrencyLost)
        {
            throw new RetailerBranchCurrencyLostException
                (command.RetailerNo, command.BranchNo, command.UpdatedDtm, ex);
        }
    }
}