-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Category_ValidateExclusive_fn stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE FUNCTION Category_ValidateExclusive_fn
(
    @CategoryNo   CategoryNo,
    @NodeTypeCode NodeTypeCode
)
    RETURNS TINYINT
AS
BEGIN
    RETURN (
               SELECT COALESCE((
                                   SELECT 1
                                   FROM Category
                                   WHERE CategoryNo = @CategoryNo
                                     AND NodeTypeCode = @NodeTypeCode
                               ), 0)
    )
END
GO
-- rollback DROP FUNCTION Category_ValidateExclusive_fn;