namespace OrderManager.Localization;

[AttributeUsage(AttributeTargets.Class, Inherited = false)]
public class DataAnnotationResourceTypeAttribute : Attribute
{
    public Type ResourceType { get; }

    public DataAnnotationResourceTypeAttribute(Type resourceType)
    {
        ResourceType = resourceType;
    }
}