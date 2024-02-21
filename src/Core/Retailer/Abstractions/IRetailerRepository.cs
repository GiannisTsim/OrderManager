using OrderManager.Core.Retailer.Models;

namespace OrderManager.Core.Retailer.Abstractions;

public interface IRetailerRepository
{
    Task<IEnumerable<RetailerDetails>> GetAsync(
        string? searchTerm,
        string? sortColumn,
        bool? isDescending,
        int? pageNo,
        int? pageSize
    );

    Task<int> GetTotalResultCountAsync(string? searchTerm);
    Task<RetailerDetails?> FindByRetailerNoAsync(int retailerNo);
    Task<RetailerDetails?> FindByVatIdAsync(string vatId);
    Task<RetailerDetails?> FindByNameAsync(string name);
    Task<bool> VerifyExistenceByVatIdAsync(string vatId);
    Task<bool> VerifyExistenceByNameAsync(string name);
    Task<bool> VerifyCurrencyAsync(int retailerNo, DateTimeOffset updatedDtm);
    Task<int> AddAsync(RetailerAddCommand retailer);
    Task ModifyAsync(RetailerModifyCommand retailer);
    Task ObsoleteAsync(RetailerObsoleteCommand retailer);
    Task RestoreAsync(RetailerRestoreCommand retailer);
}