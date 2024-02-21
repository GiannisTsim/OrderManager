using OrderManager.Core.Retailer.Models;

namespace OrderManager.Core.Retailer.Abstractions;

public interface IRetailerBranchRepository
{
    Task<IEnumerable<RetailerBranch>> GetAsync(int retailerNo);
}