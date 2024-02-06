-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Category_Path_fn stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE FUNCTION dbo.Category_Path_fn
(
    @CategoryNo CategoryNo,
    @Separator  CHAR(1) = ',',
    @Path       NVARCHAR(MAX) = ''
) RETURNS NVARCHAR(MAX) AS
BEGIN
    RETURN (
               SELECT CASE
                          -- Stop recursion when at a root category
                          WHEN ParentCategoryNo = 0
                              THEN CONCAT(CategoryNo, @Path)
                          -- Stop recursion when a circular reference is detected
                          WHEN CHARINDEX(CONVERT(NVARCHAR, CategoryNo), @Path) != 0
                              THEN CONCAT('*', CategoryNo, '*', @Path)
                          -- Else call recursively with parent category as input        
                          ELSE
                              dbo.Category_Path_fn
                              (
                                      ParentCategoryNo,
                                      @Separator,
                                      CONCAT(@Separator, CategoryNo, @Path)
                              )
                      END
               FROM Category
               WHERE CategoryNo = @CategoryNo
    )
END
GO
-- rollback DROP FUNCTION Category_Path_fn;