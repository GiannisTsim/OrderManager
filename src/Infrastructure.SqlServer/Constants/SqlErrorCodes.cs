namespace OrderManager.Infrastructure.SqlServer.Constants;

public static class SqlErrorCodes
{
    // Person cluster
    public const int PersonDuplicateEmail = 51107;
    public const int PersonNotFound = 51108;
    public const int PersonCurrencyLost = 51109;

    public const int PersonAdminRoleDuplicate = 51202;
    public const int PersonAdminRoleNotFound = 51203;

    // Retailer cluster
    public const int RetailerInvalidVatId = 52101;
    public const int RetailerInvalidName = 52102;
    public const int RetailerDuplicateVatId = 52103;
    public const int RetailerDuplicateName = 52104;
    public const int RetailerNotFound = 52105;
    public const int RetailerCurrencyLost = 52106;

    public const int RetailerBranchInvalidName = 52201;
    public const int RetailerBranchDuplicateName = 52202;
    public const int RetailerBranchNotFound = 52203;
    public const int RetailerBranchCurrencyLost = 52204;

    public const int RetailerBranchAgentDuplicate = 52301;
    public const int RetailerBranchAgentNotFound = 52302;
    public const int RetailerBranchAgentCurrencyLost = 52303;

    // Product cluster
    public const int CategoryInvalidName = 53101;
    public const int CategoryDuplicateName = 53102;
    public const int CategoryNotFound = 53103;

    public const int ManufacturerInvalidName = 53201;
    public const int ManufacturerDuplicateName = 53202;
    public const int ManufacturerNotFound = 53203;

    public const int ManufacturerBrandInvalidName = 53301;
    public const int ManufacturerBrandDuplicateName = 53302;
    public const int ManufacturerBrandNotFound = 53303;

    public const int ProductInvalidCode = 53401;
    public const int ProductInvalidName = 53402;
    public const int ProductDuplicateCode = 53403;
    public const int ProductDuplicateName = 53404;
    public const int ProductNotFound = 53405;
    public const int ProductCurrencyLost = 53406;

    public const int ProductOfferingNotFound = 53510;
    public const int ProductOfferingCurrencyLost = 53511;

    // Itinerary cluster

    // Order cluster
}