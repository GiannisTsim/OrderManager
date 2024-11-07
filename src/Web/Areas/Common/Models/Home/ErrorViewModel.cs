namespace OrderManager.Web.Areas.Common.Models.Home;

public record ErrorViewModel(string? RequestId)
{
    public bool ShowRequestId => !string.IsNullOrEmpty(RequestId);
}