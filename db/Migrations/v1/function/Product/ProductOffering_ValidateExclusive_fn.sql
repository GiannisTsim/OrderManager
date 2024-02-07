-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:ProductOffering_ValidateExclusive_fn stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE FUNCTION ProductOffering_ValidateExclusive_fn
(
    @ProductCode      ProductCode,
    @OfferingNo       OfferingNo,
    @OfferingTypeCode OfferingTypeCode
)
    RETURNS TINYINT
AS
BEGIN
    RETURN (
               SELECT COALESCE((
                                   SELECT 1
                                   FROM ProductOffering
                                   WHERE ProductCode = @ProductCode
                                     AND OfferingNo = @OfferingNo
                                     AND OfferingTypeCode = @OfferingTypeCode
                               ), 0)
    )
END
GO
-- rollback DROP FUNCTION ProductOffering_ValidateExclusive_fn;