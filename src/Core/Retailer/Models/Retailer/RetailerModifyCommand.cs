using OrderManager.Core.Retailer.Exceptions;

namespace OrderManager.Core.Retailer.Models;

public record RetailerModifyCommand
{
    public int RetailerNo { get; }
    public DateTimeOffset UpdatedDtm { get; }
    public string VatId { get; }
    public string Name { get; }

    public RetailerModifyCommand(int retailerNo, DateTimeOffset updatedDtm, string vatId, string name)
    {
        if (string.IsNullOrWhiteSpace(vatId)) throw new RetailerInvalidVatIdException(vatId);
        if (string.IsNullOrWhiteSpace(name)) throw new RetailerInvalidNameException(name);
        RetailerNo = retailerNo;
        UpdatedDtm = updatedDtm;
        VatId = vatId;
        Name = name;
    }
}