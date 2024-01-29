using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;

namespace OrderManager.MvcApp.Filters;

/// <summary>
/// An exception filter that adds an error to the <see cref="Microsoft.AspNetCore.Mvc.ModelBinding.ModelStateDictionary"/>
/// when an Exception of type <typeparamref name="TException"/> is caught. 
/// </summary>
/// <typeparam name="TException">The type of exception to catch.</typeparam>
public class ModelStateErrorFromExceptionAttribute<TException> : ExceptionFilterAttribute where TException : Exception
{
    /// <summary>
    /// The key of the <see cref="T:Microsoft.AspNetCore.Mvc.ModelBinding.ModelStateEntry" /> to add errors to.
    /// Defaults to the empty string.
    /// </summary>
    public string? Key { get; set; }

    /// <summary>
    /// The error message to add. The Exception's message is used if a message is not provided.
    /// </summary>
    public string? Message { get; set; }

    /// <summary>
    /// Set to true to propagate the exception.
    /// </summary>
    public bool PropagateException { get; set; } = false;

    public override void OnException(ExceptionContext context)
    {
        if (context.Exception is TException)
        {
            context.ModelState.AddModelError(Key ?? "", Message ?? context.Exception.Message);
            context.ExceptionHandled = !PropagateException;
            context.Result = new ViewResult();
        }
    }
}