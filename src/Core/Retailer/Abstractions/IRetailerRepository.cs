using OrderManager.Core.Retailer.Commands.Retailer;
using OrderManager.Core.Retailer.Models;

namespace OrderManager.Core.Retailer.Abstractions;

public interface IRetailerRepository
{
    Task<IEnumerable<RetailerDetails>> GetDetailsAsync(
        string? searchTerm,
        string? sortColumn,
        bool? isDescending,
        int? pageNo,
        int? pageSize);

    Task<int> GetTotalResultCountAsync(string? searchTerm);
    Task<RetailerDetails?> FindDetailsByRetailerNoAsync(int retailerNo);
    Task<RetailerSimple?> FindByTaxIdAsync(string taxId);
    Task<RetailerSimple?> FindByNameAsync(string name);
    Task<int> AddAsync(RetailerAddCommand retailer);
    Task ModifyAsync(RetailerModifyCommand retailer);
    Task ObsoleteAsync(RetailerObsoleteCommand retailer);
    Task RestoreAsync(RetailerRestoreCommand retailer);
}