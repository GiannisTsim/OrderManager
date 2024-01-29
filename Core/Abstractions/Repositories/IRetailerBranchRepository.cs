using OrderManager.Core.Models.RetailerBranch;

namespace OrderManager.Core.Abstractions.Repositories;

public interface IRetailerBranchRepository
{
    Task<IEnumerable<RetailerBranch>> GetAsync(int retailerNo);
}