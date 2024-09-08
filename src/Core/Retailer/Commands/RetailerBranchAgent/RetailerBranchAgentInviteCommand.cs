using OrderManager.Core.Person.Commands;
using OrderManager.Core.Person.Commands.Person;

namespace OrderManager.Core.Retailer.Commands.RetailerBranchAgent;

public record RetailerBranchAgentInviteCommand : PersonInviteCommand
{
    public int RetailerNo { get; }
    public int BranchNo { get; }

    public RetailerBranchAgentInviteCommand(int? retailerNo, int? branchNo, string? email) : base(email)
    {
        RetailerNo = retailerNo ?? throw new ArgumentNullException(nameof(retailerNo));
        BranchNo = branchNo ?? throw new ArgumentNullException(nameof(branchNo));
    }
}