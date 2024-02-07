using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc.ViewFeatures;

namespace OrderManager.MvcApp.Filters;

[AttributeUsage(AttributeTargets.Class | AttributeTargets.Method, AllowMultiple = true)]
public class TempDataExceptionFilterAttribute<T> : Attribute, IFilterFactory
{
    public bool IsReusable => false;
    public string? Key { get; set; }
    public string? Message { get; set; }

    public IFilterMetadata CreateInstance(IServiceProvider serviceProvider)
    {
        var tempDataDictionaryFactory = serviceProvider.GetRequiredService<ITempDataDictionaryFactory>();
        return new TempDataExceptionFilter(tempDataDictionaryFactory, Key, Message);
    }

    private class TempDataExceptionFilter : IExceptionFilter
    {
        private readonly ITempDataDictionaryFactory _tempDataDictionaryFactory;
        private readonly string _key;
        private readonly string? _message;

        public TempDataExceptionFilter(
            ITempDataDictionaryFactory tempDataDictionaryFactory,
            string? key,
            string? message
        )
        {
            _tempDataDictionaryFactory = tempDataDictionaryFactory;
            _key = key ?? "";
            _message = message;
        }

        public void OnException(ExceptionContext context)
        {
            if (context.Exception is T)
            {
                var tempDataDictionary = _tempDataDictionaryFactory.GetTempData(context.HttpContext);

                context.ModelState.AddModelError(_key, _message ?? context.Exception.Message);
                context.ExceptionHandled = true;
                context.Result = new ViewResult();
            }
        }
    }
}