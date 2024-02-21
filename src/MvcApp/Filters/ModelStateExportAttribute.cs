using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using OrderManager.MvcApp.Constants;
using OrderManager.MvcApp.Utilities;

namespace OrderManager.MvcApp.Filters;

/// <summary>
/// An action filter that exports an invalid <see cref="Microsoft.AspNetCore.Mvc.ModelBinding.ModelStateDictionary"/>
/// into the <see cref="T:Microsoft.AspNetCore.Mvc.ViewFeatures.ITempDataDictionary" />.
/// </summary>
public class ModelStateExportAttribute : ActionFilterAttribute
{
    public override void OnActionExecuted(ActionExecutedContext context)
    {
        // Only export when ModelState is not valid
        if (context.ModelState.IsValid) return;

        // Only export on redirect
        if (context.Result is not IKeepTempDataResult) return;

        if (context.Controller is not Controller controller) return;
        var modelState = ModelStateHelpers.SerializeModelState(context.ModelState);
        controller.TempData[TempDataKeys.ModelStateTransfer] = modelState;
    }
}