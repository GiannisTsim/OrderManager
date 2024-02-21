using OrderManager.Core.Retailer.Abstractions;
using OrderManager.Core.Retailer.Exceptions;
using OrderManager.Core.Retailer.Models;

namespace OrderManager.Core.Retailer.Services;

public class RetailerService
{
    private readonly IRetailerRepository _retailerRepository;

    public RetailerService(IRetailerRepository retailerRepository)
    {
        _retailerRepository = retailerRepository;
    }

    public async Task AddAsync(RetailerAddCommand command)
    {
        if (await _retailerRepository.VerifyExistenceByNameAsync(command.Name))
        {
            throw new RetailerDuplicateNameException(command.Name);
        }

        if (await _retailerRepository.VerifyExistenceByVatIdAsync(command.VatId))
        {
            throw new RetailerDuplicateVatIdException(command.VatId);
        }

        // await _retailerRepository.AddAsync(command);
    }

    public async Task<bool> ValidateVatId(string vatId)
    {
        return !await _retailerRepository.VerifyExistenceByVatIdAsync(vatId);
    }

    public async Task<bool> ValidateName(string name)
    {
        return !await _retailerRepository.VerifyExistenceByNameAsync(name);
    }
}