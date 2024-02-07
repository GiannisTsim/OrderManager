-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Person_ValidateExclusive_fn stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE FUNCTION Person_ValidateExclusive_fn
(
    @PersonNo       PersonNo,
    @PersonTypeCode PersonTypeCode
)
    RETURNS TINYINT
AS
BEGIN
    RETURN (
               SELECT COALESCE((
                                   SELECT 1
                                   FROM Person
                                   WHERE PersonNo = @PersonNo
                                     AND PersonTypeCode = @PersonTypeCode
                               ), 0)
    )
END
GO
-- rollback DROP FUNCTION Person_ValidateExclusive_fn;