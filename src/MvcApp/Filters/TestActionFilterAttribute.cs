using Microsoft.AspNetCore.Mvc.Filters;

namespace OrderManager.MvcApp.Filters;

public class TestActionFilterAttribute : ActionFilterAttribute
{
    public override void OnActionExecuting(ActionExecutingContext context)
    {
        Console.WriteLine(nameof(TestActionFilterAttribute) + nameof(OnActionExecuting));
    }

    public override void OnActionExecuted(ActionExecutedContext context)
    {
        Console.WriteLine(nameof(TestActionFilterAttribute) + nameof(OnActionExecuted));
    }
}