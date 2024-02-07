using OrderManager.Core.Models.Retailer;

namespace OrderManager.Core.Abstractions.Repositories;

public interface IRetailerRepository
{
    Task<IEnumerable<Retailer>> GetAsync(
        string? searchTerm,
        string? sortColumn,
        bool? isDescending,
        int? pageNo,
        int? pageSize
    );

    Task<int> GetTotalResultCountAsync(string? searchTerm);
    Task<Retailer?> FindByRetailerNoAsync(int retailerNo);
    Task<Retailer?> FindByVatIdAsync(string vatId);
    Task<Retailer?> FindByNameAsync(string name);
    Task<bool> VerifyExistenceByVatIdAsync(string vatId);
    Task<bool> VerifyExistenceByNameAsync(string name);
    Task<bool> VerifyCurrencyAsync(int retailerNo, DateTimeOffset updatedDtm);
    Task<int> AddAsync(RetailerAddCommand retailer);
    Task ModifyAsync(RetailerModifyCommand retailer);
    Task ObsoleteAsync(RetailerObsoleteCommand retailer);
}