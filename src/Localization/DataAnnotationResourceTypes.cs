using System.Collections.Concurrent;
using System.Diagnostics.CodeAnalysis;
using System.Reflection;
using Microsoft.Extensions.Localization;

namespace OrderManager.Localization;

public static class DataAnnotationResourceTypes
{
    // TODO: Examine whether caching here is redundant due to framework-level caching of the Type to IStringLocalizer mappings
    private static readonly ConcurrentDictionary<Type, Type> TypeMap = new();

    private static bool TryGetResourceType(Type type, [MaybeNullWhen(false)] out Type resourceType)
    {
        if (TypeMap.TryGetValue(type, out resourceType)) return true;

        var attribute = type.GetCustomAttribute<DataAnnotationResourceTypeAttribute>();
        if (attribute == null) return false;

        TypeMap.TryAdd(type, attribute.ResourceType);
        resourceType = attribute.ResourceType;
        return true;
    }

    public static readonly Func<Type, IStringLocalizerFactory, IStringLocalizer> DataAnnotationLocalizerProvider =
        (type, factory) => TryGetResourceType(type, out var resourceType)
            ? factory.Create(resourceType)
            : factory.Create(type);
}