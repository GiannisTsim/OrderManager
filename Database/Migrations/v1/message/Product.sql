-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Category stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC sp_addmessage 53101, 16, 'Category.Name cannot be null.';
-- rollback EXEC sp_dropmessage 53101, 'all';

EXEC sp_addmessage 53102, 16, 'Category[ParentCategoryNo=%d,Name=''%s''] already exists.';
-- rollback EXEC sp_dropmessage 53102, 'all';

EXEC sp_addmessage 53103, 16, 'Category[CategoryNo=%d] does not exist.';
-- rollback EXEC sp_dropmessage 53103, 'all';

EXEC sp_addmessage 53104, 16,
     'Category_Leaf[CategoryNo_Leaf=%d] cannot be deleted while being associated with a Product.';
-- rollback EXEC sp_dropmessage 53104, 'all';

EXEC sp_addmessage 53105, 16,
     'Category_Branch[CategoryNo_Branch=%d] cannot be deleted.';
-- rollback EXEC sp_dropmessage 53105, 'all';

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Manufacturer stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC sp_addmessage 53201, 16, 'Manufacturer.Name cannot be null.';
-- rollback EXEC sp_dropmessage 53201, 'all';

EXEC sp_addmessage 53202, 16, 'Manufacturer[Name=''%s''] already exists.';
-- rollback EXEC sp_dropmessage 53202, 'all';

EXEC sp_addmessage 53203, 16, 'Manufacturer[ManufacturerNo=%d] does not exist.';
-- rollback EXEC sp_dropmessage 53203, 'all';

EXEC sp_addmessage 53204, 16,
     'Manufacturer[ManufacturerNo=%d] cannot be deleted while being associated with a ManufacturerBrand.';
-- rollback EXEC sp_dropmessage 53204, 'all';

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:ManufacturerBrand stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC sp_addmessage 53301, 16, 'ManufacturerBrand.Name cannot be null.';
-- rollback EXEC sp_dropmessage 53301, 'all';

EXEC sp_addmessage 53302, 16, 'ManufacturerBrand[ManufacturerNo=%d,Name=''%s''] already exists.';
-- rollback EXEC sp_dropmessage 53302, 'all';

EXEC sp_addmessage 53303, 16, 'ManufacturerBrand[ManufacturerNo=%d,BrandNo=%d] does not exist.';
-- rollback EXEC sp_dropmessage 53303, 'all';

EXEC sp_addmessage 53304, 16,
     'ManufacturerBrand[ManufacturerNo=%d,BrandNo=%d] cannot be deleted while being associated with a Product.';
-- rollback EXEC sp_dropmessage 53304, 'all';

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Product stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC sp_addmessage 53401, 16, 'Product.ProductCode cannot be null.';
-- rollback EXEC sp_dropmessage 53401, 'all';

EXEC sp_addmessage 53402, 16, 'Product.Name cannot be null.';
-- rollback EXEC sp_dropmessage 53402, 'all';

EXEC sp_addmessage 53403, 16, 'Product[ProductCode=''%s''] already exists.';
-- rollback EXEC sp_dropmessage 53403, 'all';

EXEC sp_addmessage 53404, 16, 'Product[ManufacturerNo=%d,BrandNo=%d,Name=''%s''] already exists.';
-- rollback EXEC sp_dropmessage 53404, 'all';

EXEC sp_addmessage 53405, 16, 'Product[ProductCode=''%s''] does not exist.';
-- rollback EXEC sp_dropmessage 53405, 'all';

EXEC sp_addmessage 53406, 16, 'Product[ProductCode=''%s'',UpdateDtm=''%s''] currency is lost.';
-- rollback EXEC sp_dropmessage 53406, 'all';

EXEC sp_addmessage 53407, 16,
     'Product[ProductCode=''%s''] cannot be deleted while being associated with a ProductOffering.';
-- rollback EXEC sp_dropmessage 53407, 'all';

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:ProductOffering stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC sp_addmessage 53501, 16, 'OfferingType[OfferingTypeCode=''%s''] does not exist.';
-- rollback EXEC sp_dropmessage 53501, 'all';

EXEC sp_addmessage 53502, 16, 'ProductOffering_Bundle.UnitCount cannot be null.';
-- rollback EXEC sp_dropmessage 53502, 'all';

EXEC sp_addmessage 53503, 16, 'ProductOffering_Bundle.UnitCount must be greater than zero (0).';
-- rollback EXEC sp_dropmessage 53503, 'all';

EXEC sp_addmessage 53504, 16, 'BundleType.Name cannot be null.';
-- rollback EXEC sp_dropmessage 53504, 'all';

EXEC sp_addmessage 53505, 16, 'BundleType[BundleTypeNo=''%s''] does not exist.';
-- rollback EXEC sp_dropmessage 53505, 'all';

EXEC sp_addmessage 53506, 16, 'BundleType[Name=''%s''] already exists.';
-- rollback EXEC sp_dropmessage 53506, 'all';

EXEC sp_addmessage 53507, 16, 'ProductOffering_Unit[ProductCode=''%s''] already exists.';
-- rollback EXEC sp_dropmessage 53507, 'all';

EXEC sp_addmessage 53508, 16, 'ProductOffering_Bundle[ProductCode=''%s'',UnitCount=%d] already exists.';
-- rollback EXEC sp_dropmessage 53508, 'all';

EXEC sp_addmessage 53509, 16, 'ProductOffering_Bundle[ProductCode=''%s'',BundleTypeNo''%s''] already exists.';
-- rollback EXEC sp_dropmessage 53509, 'all';

EXEC sp_addmessage 53510, 16, 'ProductOffering[ProductCode=''%s'',OfferingNo=%d] does not exist.';
-- rollback EXEC sp_dropmessage 53510, 'all';

EXEC sp_addmessage 53511, 16, 'ProductOffering[ProductCode=''%s'',OfferingNo=%d,UpdatedDtm=''%s''] currency is lost.';
-- rollback EXEC sp_dropmessage 53511, 'all';

EXEC sp_addmessage 53512, 16,
     'ProductOffering[ProductCode=''%s'',OfferingNo=%d] cannot be deleted while being associated with an OrderItem.';
-- rollback EXEC sp_dropmessage 53512, 'all';
