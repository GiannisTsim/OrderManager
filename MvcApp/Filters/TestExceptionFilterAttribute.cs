using Microsoft.AspNetCore.Mvc.Filters;

namespace OrderManager.MvcApp.Filters;

public class TestExceptionFilterAttribute : ExceptionFilterAttribute
{
    public override void OnException(ExceptionContext context)
    {
        Console.WriteLine(nameof(TestExceptionFilterAttribute) + nameof(OnException));
        context.ExceptionHandled = true;
    }
}