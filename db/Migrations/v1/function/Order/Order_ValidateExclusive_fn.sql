-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Order_ValidateExclusive_fn stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE FUNCTION Order_ValidateExclusive_fn
(
    @RetailerNo    RetailerNo,
    @BranchNo      BranchNo,
    @AgentNo       PersonNo,
    @OrderNo       OrderNo,
    @OrderTypeCode OrderTypeCode
)
    RETURNS TINYINT
AS
BEGIN
    RETURN (
               SELECT COALESCE((
                                   SELECT 1
                                   FROM [Order]
                                   WHERE RetailerNo = @RetailerNo
                                     AND BranchNo = @BranchNo
                                     AND AgentNo = @AgentNo
                                     AND OrderNo = @OrderNo
                                     AND OrderTypeCode = @OrderTypeCode
                               ), 0)
    )
END
GO
-- rollback DROP FUNCTION Order_ValidateExclusive_fn;