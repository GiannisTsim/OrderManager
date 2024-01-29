using OrderManager.Core.Models;

namespace OrderManager.Core.Abstractions.Repositories;

public interface IPersonRepository
{
    Task<IEnumerable<Person>> GetAllAsync();
    Task<Person?> GetByPersonNoAsync(int personNo);
    Task<Person?> GetByEmailAsync(string normalizedEmail);
    Task<Person?> GetByUserNameAsync(string normalizedUserName);
    Task AddAsync(Person person);
    Task ModifyAsync(Person person);
    Task DropAsync(Person person);
    Task AddToRoleAsync(int personNo, DateTimeOffset personUpdatedDtm, string roleName);
    Task RemoveFromRoleAsync(int personNo, DateTimeOffset personUpdatedDtm, string roleName);
    Task<bool> CheckRoleMembershipAsync(int personNo, string roleName);
    Task<IEnumerable<Person>> GetByRoleAsync(string roleName);
}