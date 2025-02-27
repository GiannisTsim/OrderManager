using System.Data;
using Dapper;
using OrderManager.Core.Retailer.Abstractions;
using OrderManager.Core.Retailer.Commands.RetailerBranchAgent;
using OrderManager.Infrastructure.SqlServer.Abstractions;
using OrderManager.Infrastructure.SqlServer.Repositories.Abstractions;

namespace OrderManager.Infrastructure.SqlServer.Repositories;

// TODO: Add exception handling
public class RetailerBranchAgentRepository : RepositoryBase, IRetailerBranchAgentRepository
{
    public RetailerBranchAgentRepository(IConnectionStringProvider sqlCredentialProvider) :
        base(sqlCredentialProvider) { }

    public async Task<int> AddWithInviteeAsync(RetailerBranchAgentInviteCommand command)
    {
        var p = new DynamicParameters
        (
            new
            {
                command.RetailerNo, command.BranchNo, command.Email, command.EmailConfirmed, PersonTypeCode = "I",
                command.InvitationDtm
            }
        );
        p.Add("@AgentNo", DbType.Int32, direction: ParameterDirection.Output);

        await using var connection = SqlConnection;
        await connection.ExecuteAsync(
            "RetailerBranchAgent_Add_tr",
            p,
            commandType: CommandType.StoredProcedure
        );

        var agentNo = p.Get<int>("@AgentNo");
        return agentNo;
    }

    public async Task AddAsync(RetailerBranchAgentAddCommand command)
    {
        await using var connection = SqlConnection;
        await connection.ExecuteAsync(
            "RetailerBranchAgent_Add_tr",
            new { command.RetailerNo, command.BranchNo, command.AgentNo },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task ObsoleteAsync(RetailerBranchAgentObsoleteCommand command)
    {
        await using var connection = SqlConnection;
        await connection.ExecuteAsync(
            "RetailerBranchAgent_Obsolete_tr",
            new { command.RetailerNo, command.BranchNo, command.AgentNo, command.UpdatedDtm },
            commandType: CommandType.StoredProcedure
        );
    }

    public async Task RestoreAsync(RetailerBranchAgentRestoreCommand command)
    {
        await using var connection = SqlConnection;
        await connection.ExecuteAsync(
            "RetailerBranchAgent_Restore_tr",
            new { command.RetailerNo, command.BranchNo, command.AgentNo, command.UpdatedDtm },
            commandType: CommandType.StoredProcedure
        );
    }
}