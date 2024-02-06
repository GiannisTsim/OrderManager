-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:TEMPLATE_utr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE TEMPLATE_utr
(
) AS
BEGIN
    -- Utility transaction integrity check --
    EXEC XactUtil_Integrity_Check;

    -- Database updates --


    -- Database updates successful --
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE TEMPLATE_utr;