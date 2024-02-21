using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using OrderManager.MvcApp.Constants;
using OrderManager.MvcApp.Utilities;

namespace OrderManager.MvcApp.Filters;

/// <summary>
/// An action filter that imports a <see cref="Microsoft.AspNetCore.Mvc.ModelBinding.ModelStateDictionary"/>
/// from the <see cref="T:Microsoft.AspNetCore.Mvc.ViewFeatures.ITempDataDictionary" />.
/// </summary>
public class ModelStateImportAttribute : ActionFilterAttribute
{
    public override void OnActionExecuted(ActionExecutedContext context)
    {
        var controller = context.Controller as Controller;
        if (controller?.TempData[TempDataKeys.ModelStateTransfer] is not string serializedModelState) return;

        // Only import when viewing
        if (context.Result is not ViewResult) return;

        var modelState = ModelStateHelpers.DeserializeModelState(serializedModelState);
        context.ModelState.Merge(modelState);
    }
}