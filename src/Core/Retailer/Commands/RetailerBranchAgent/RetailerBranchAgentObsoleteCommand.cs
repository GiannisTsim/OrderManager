namespace OrderManager.Core.Retailer.Commands.RetailerBranchAgent;

public record RetailerBranchAgentObsoleteCommand
{
    public int RetailerNo { get; }
    public int BranchNo { get; }
    public int AgentNo { get; }
    public DateTimeOffset UpdatedDtm { get; }

    public RetailerBranchAgentObsoleteCommand(int? retailerNo, int? branchNo, int? agentNo, DateTimeOffset? updatedDtm)
    {
        RetailerNo = retailerNo ?? throw new ArgumentNullException(nameof(retailerNo));
        BranchNo = branchNo ?? throw new ArgumentNullException(nameof(branchNo));
        AgentNo = agentNo ?? throw new ArgumentNullException(nameof(agentNo));
        UpdatedDtm = updatedDtm ?? throw new ArgumentNullException(nameof(updatedDtm));
    }
}