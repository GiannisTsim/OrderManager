using System.Text.Json;
using Microsoft.AspNetCore.Mvc.ModelBinding;

namespace OrderManager.Web.Utilities;

public static class ModelStateHelper
{
    private class ModelStateTransferValue
    {
        public required string Key { get; init; }
        public required string? AttemptedValue { get; init; }
        public required object? RawValue { get; init; }
        public required ICollection<string> ErrorMessages { get; init; }
    }

    public static string SerializeModelState(ModelStateDictionary modelState)
    {
        var errorList = modelState.Select
        (
            kvp => new ModelStateTransferValue
            {
                Key = kvp.Key,
                AttemptedValue = kvp.Value?.AttemptedValue,
                RawValue = kvp.Value?.RawValue,
                ErrorMessages = kvp.Value?.Errors.Select(err => err.ErrorMessage).ToList() ?? [],
            }
        );
        return JsonSerializer.Serialize(errorList);
    }

    public static ModelStateDictionary DeserializeModelState(string serializedErrorList)
    {
        var errorList = JsonSerializer.Deserialize<List<ModelStateTransferValue>>(serializedErrorList);
        var modelState = new ModelStateDictionary();

        if (errorList == null) return modelState;

        foreach (var item in errorList)
        {
            modelState.SetModelValue(item.Key, item.RawValue, item.AttemptedValue);
            foreach (var error in item.ErrorMessages)
            {
                modelState.AddModelError(item.Key, error);
            }
        }

        return modelState;
    }
}