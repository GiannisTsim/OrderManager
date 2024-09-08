using OrderManager.Core.Retailer.Commands.RetailerBranch;
using OrderManager.Core.Retailer.Models;

namespace OrderManager.Core.Retailer.Abstractions;

public interface IRetailerBranchRepository
{
    Task<IEnumerable<RetailerBranch>> GetAsync(int retailerNo);
    Task<int> AddAsync(RetailerBranchAddCommand command);
    Task ModifyAsync(RetailerBranchModifyCommand command);
    Task ObsoleteAsync(RetailerBranchObsoleteCommand command);
    Task RestoreAsync(RetailerBranchRestoreCommand command);
}