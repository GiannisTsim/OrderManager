-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Category_NI_ParentPath_ck stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
ALTER TABLE Category
    WITH NOCHECK
        ADD CONSTRAINT Category_NI_ParentPath_ck CHECK
        (
        CHARINDEX(CONVERT(NVARCHAR, CategoryNo), dbo.Category_Path_fn(ParentCategoryNo, DEFAULT, DEFAULT)) = 0
        );
-- rollback ALTER TABLE Category DROP CONSTRAINT Category_NI_ParentPath_ck;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:CategoryBranch_IsExclusive_ck stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
ALTER TABLE Category_Branch
    ADD CONSTRAINT CategoryBranch_IsExclusive_ck CHECK (dbo.Category_ValidateExclusive_fn(CategoryNo_Branch, 'B') = 1);
-- rollback ALTER TABLE Category_Branch DROP CONSTRAINT CategoryBranch_IsExclusive_ck;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:CategoryLeaf_IsExclusive_ck stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
ALTER TABLE Category_Leaf
    ADD CONSTRAINT CategoryLeaf_IsExclusive_ck CHECK (dbo.Category_ValidateExclusive_fn(CategoryNo_Leaf, 'L') = 1);
-- rollback ALTER TABLE Category_Leaf DROP CONSTRAINT CategoryLeaf_IsExclusive_ck;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:ProductOfferingUnit_IsExclusive_ck stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
ALTER TABLE ProductOffering_Unit
    ADD CONSTRAINT ProductOfferingUnit_IsExclusive_ck CHECK (dbo.ProductOffering_ValidateExclusive_fn(ProductCode,
                                                                                                      OfferingNo_Unit,
                                                                                                      'U') = 1);
-- rollback ALTER TABLE ProductOffering_Unit DROP CONSTRAINT ProductOfferingUnit_IsExclusive_ck;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:ProductOfferingBundle_IsExclusive_ck stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
ALTER TABLE ProductOffering_Bundle
    ADD CONSTRAINT ProductOfferingBundle_IsExclusive_ck CHECK (dbo.ProductOffering_ValidateExclusive_fn(ProductCode,
                                                                                                        OfferingNo_Bundle,
                                                                                                        'B') = 1);
-- rollback ALTER TABLE ProductOffering_Bundle DROP CONSTRAINT ProductOfferingBundle_IsExclusive_ck;
