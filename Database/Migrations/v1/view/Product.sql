-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Category_V stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE VIEW Category_V AS
SELECT CategoryNo,
       ParentCategoryNo,
       Name,
       NodeTypeCode,
       dbo.Category_Path_fn(CategoryNo, ',', DEFAULT)     AS Path,
       dbo.Category_PathName_fn(CategoryNo, '/', DEFAULT) AS PathName
FROM Category
WHERE CategoryNo != 0;
-- rollback DROP VIEW Category_V;
