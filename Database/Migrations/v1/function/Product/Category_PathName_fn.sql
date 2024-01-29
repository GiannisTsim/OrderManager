-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Category_PathName_fn stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE FUNCTION dbo.Category_PathName_fn
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
                              THEN CONCAT(Name, @Path)
                          -- Stop recursion when a circular reference is detected
                          WHEN CHARINDEX(CONVERT(NVARCHAR, Name), @Path) != 0
                              THEN CONCAT('*', Name, '*', @Path)
                          -- Else call recursively with parent category as input       
                          ELSE
                              dbo.Category_PathName_fn
                              (
                                      ParentCategoryNo,
                                      @Separator,
                                      CONCAT(@Separator, Name, @Path)
                              )
                      END
               FROM Category
               WHERE CategoryNo = @CategoryNo
    )
END
GO
-- rollback DROP FUNCTION Category_PathName_fn;