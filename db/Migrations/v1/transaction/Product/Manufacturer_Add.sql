-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Manufacturer_Add_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Manufacturer_Add_vtr
(
    @Name ManufacturerName
) AS
BEGIN
    -- Error state initialization --
    DECLARE @State TINYINT = CASE WHEN @@TRANCOUNT = 0 THEN 1
                                  ELSE 2
                             END;

    -- Validation checks --
    IF EXISTS
        (
            SELECT 1
            FROM Manufacturer
            WHERE Name = @Name
        )
        BEGIN
            RAISERROR (53202, -1, @State, @Name);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Manufacturer_Add_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Manufacturer_Add_utr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Manufacturer_Add_utr
(
    @Name           ManufacturerName,
    @ManufacturerNo ManufacturerNo = NULL OUTPUT
) AS
BEGIN
    -- Utility transaction integrity check --
    EXEC XactUtil_Integrity_Check;

    -- Database updates --
    SET @ManufacturerNo = COALESCE((
                                       SELECT MAX(ManufacturerNo) + 1
                                       FROM Manufacturer
                                   ), 1);

    INSERT INTO Manufacturer (ManufacturerNo, Name)
    VALUES (@ManufacturerNo, @Name);

    -- Database updates successful --
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Manufacturer_Add_utr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Manufacturer_Add_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Manufacturer_Add_tr
(
    @Name           ManufacturerName,
    @ManufacturerNo ManufacturerNo = NULL OUTPUT
) AS
BEGIN
    DECLARE @ProcName SYSNAME = OBJECT_NAME(@@PROCID);

    ----------------------
    -- Validation block --
    ----------------------
    -- Transaction integrity check --
    EXEC Xact_Integrity_Check;

    -- Parameter checks --
    IF @Name IS NULL
        BEGIN
            RAISERROR (53201, -1, 1);
        END

    -- Offline constraint validation (no locks held) --
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    EXEC Manufacturer_Add_vtr @Name;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC Manufacturer_Add_vtr @Name;

        -- Database updates --
        EXEC Manufacturer_Add_utr @Name, @ManufacturerNo OUTPUT;

        -- Commit --
        COMMIT TRANSACTION @ProcName;
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION @ProcName;
        THROW;
    END CATCH
END
GO
-- rollback DROP PROCEDURE Manufacturer_Add_tr;
