using OrderManager.Core.Retailer.Commands.RetailerBranchAgent;
using OrderManager.Core.Retailer.Models;

namespace OrderManager.Core.Retailer.Abstractions;

public interface IRetailerBranchAgentRepository
{
    Task<int> AddWithInviteeAsync(RetailerBranchAgentInviteCommand command);
    Task AddAsync(RetailerBranchAgentAddCommand command);
    Task ObsoleteAsync(RetailerBranchAgentObsoleteCommand command);
    Task RestoreAsync(RetailerBranchAgentRestoreCommand command);
}