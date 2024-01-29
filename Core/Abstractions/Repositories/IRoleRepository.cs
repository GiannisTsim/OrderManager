using OrderManager.Core.Models;

namespace OrderManager.Core.Abstractions.Repositories;

public interface IRoleRepository
{
    Task<IEnumerable<Role>> GetAllAsync();
    Task<Role?> GetByCodeAsync(string roleCode);
    Task<Role?> GetByNameAsync(string normalizedName);
    Task<IEnumerable<Role>> GetByPersonAsync(int personNo);
}