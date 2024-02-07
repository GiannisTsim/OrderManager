using Microsoft.AspNetCore.Mvc.Rendering;

namespace OrderManager.MvcApp.Utilities;

public static class TagBuilderHelpers
{
    public static void ReplaceCssClass(this TagBuilder tagBuilder, string oldClassName, string newClassName)
    {
        if (tagBuilder.Attributes.TryGetValue("class", out var classAttribute))
        {
            tagBuilder.Attributes["class"] = classAttribute!.Replace(oldClassName, newClassName);
        }
    }
}