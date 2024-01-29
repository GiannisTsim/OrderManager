using System.Text.Encodings.Web;
using Microsoft.AspNetCore.Antiforgery;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.AspNetCore.Mvc.Routing;
using Microsoft.AspNetCore.Mvc.ViewFeatures;
using Microsoft.Extensions.Options;

namespace OrderManager.MvcApp.Utilities;

// Replace validation classnames to match Bootstrap classnames
// Based on https://gist.github.com/FWest98/9141b3c2f260bee0e46058897d2017d2
// TODO: Stay up to date with relevant issues (e.g. https://github.com/dotnet/aspnetcore/issues/17412)
public class BootstrapValidationHtmlGenerator(
    IAntiforgery antiforgery,
    IOptions<MvcViewOptions> optionsAccessor,
    IModelMetadataProvider metadataProvider,
    IUrlHelperFactory urlHelperFactory,
    HtmlEncoder htmlEncoder,
    ValidationHtmlAttributeProvider validationAttributeProvider
)
    : DefaultHtmlGenerator
        (antiforgery, optionsAccessor, metadataProvider, urlHelperFactory, htmlEncoder, validationAttributeProvider)
{
    protected override TagBuilder GenerateInput(
        ViewContext viewContext,
        InputType inputType,
        ModelExplorer modelExplorer,
        string expression,
        object value,
        bool useViewData,
        bool isChecked,
        bool setId,
        bool isExplicitValue,
        string format,
        IDictionary<string, object> htmlAttributes
    )
    {
        var tagBuilder = base.GenerateInput
        (
            viewContext,
            inputType,
            modelExplorer,
            expression,
            value,
            useViewData,
            isChecked,
            setId,
            isExplicitValue,
            format,
            htmlAttributes
        );
        ReplaceValidationInputCssClassNames(tagBuilder);

        return tagBuilder;
    }

    public override TagBuilder GenerateSelect(
        ViewContext viewContext,
        ModelExplorer modelExplorer,
        string optionLabel,
        string expression,
        IEnumerable<SelectListItem> selectList,
        ICollection<string> currentValues,
        bool allowMultiple,
        object htmlAttributes
    )
    {
        var tagBuilder = base.GenerateSelect
        (
            viewContext,
            modelExplorer,
            optionLabel,
            expression,
            selectList,
            currentValues,
            allowMultiple,
            htmlAttributes
        );
        ReplaceValidationInputCssClassNames(tagBuilder);

        return tagBuilder;
    }

    public override TagBuilder GenerateTextArea(
        ViewContext viewContext,
        ModelExplorer modelExplorer,
        string expression,
        int rows,
        int columns,
        object htmlAttributes
    )
    {
        var tagBuilder = base.GenerateTextArea(viewContext, modelExplorer, expression, rows, columns, htmlAttributes);
        ReplaceValidationInputCssClassNames(tagBuilder);

        return tagBuilder;
    }

    public override TagBuilder GenerateValidationMessage(
        ViewContext viewContext,
        ModelExplorer modelExplorer,
        string expression,
        string message,
        string tag,
        object htmlAttributes
    )
    {
        var tagBuilder = base.GenerateValidationMessage
            (viewContext, modelExplorer, expression, message, tag, htmlAttributes);
        ReplaceValidationMessageCssClassNames(tagBuilder);

        return tagBuilder;
    }

    private static void ReplaceValidationInputCssClassNames(TagBuilder tagBuilder)
    {
        tagBuilder.ReplaceCssClass(HtmlHelper.ValidationInputCssClassName, "is-invalid");
        tagBuilder.ReplaceCssClass(HtmlHelper.ValidationInputValidCssClassName, "is-valid");
    }
    
    private static void ReplaceValidationMessageCssClassNames(TagBuilder tagBuilder)
    {
        tagBuilder.ReplaceCssClass(HtmlHelper.ValidationMessageCssClassName, "invalid-feedback");
        tagBuilder.ReplaceCssClass(HtmlHelper.ValidationMessageValidCssClassName, "valid-feedback");
    }
}