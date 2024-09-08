namespace OrderManager.Core.Retailer.Commands.RetailerBranchAgent;

public record RetailerBranchAgentAddCommand
{
    public int RetailerNo { get; }
    public int BranchNo { get; }
    public int AgentNo { get; }

    public RetailerBranchAgentAddCommand(int? retailerNo, int? branchNo, int? agentNo)
    {
        RetailerNo = retailerNo ?? throw new ArgumentNullException(nameof(retailerNo));
        BranchNo = branchNo ?? throw new ArgumentNullException(nameof(branchNo));
        AgentNo = agentNo ?? throw new ArgumentNullException(nameof(agentNo));
    }
}