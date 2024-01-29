-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:XactUtil_Integrity_Check stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE XactUtil_Integrity_Check
AS
BEGIN
    IF @@TRANCOUNT = 0
        RAISERROR (50003, -1, 1);
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE XactUtil_Integrity_Check;