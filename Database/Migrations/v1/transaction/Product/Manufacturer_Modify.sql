-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Manufacturer_Modify_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Manufacturer_Modify_vtr
(
    @ManufacturerNo ManufacturerNo,
    @Name           ManufacturerName
) AS
BEGIN
    -- Error state initialization --
    DECLARE @State TINYINT = CASE WHEN @@TRANCOUNT = 0 THEN 1
                                  ELSE 2
                             END;

    -- Validation checks --
    IF NOT EXISTS
        (
            SELECT 1
            FROM Manufacturer
            WHERE ManufacturerNo = @ManufacturerNo
        )
        BEGIN
            RAISERROR (53203, -1, @State, @ManufacturerNo);
        END
    IF EXISTS
        (
            SELECT 1 FROM Manufacturer WHERE Name = @Name AND ManufacturerNo != @ManufacturerNo
        )
        BEGIN
            RAISERROR (53202, -1, @State, @Name)
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Manufacturer_Modify_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Manufacturer_Modify_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Manufacturer_Modify_tr
(
    @ManufacturerNo ManufacturerNo,
    @Name           ManufacturerName
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
    EXEC Manufacturer_Modify_vtr @ManufacturerNo, @Name;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC Manufacturer_Modify_vtr @ManufacturerNo, @Name;

        -- Database updates --
        UPDATE Manufacturer
        SET Name = @Name
        WHERE ManufacturerNo = @ManufacturerNo;

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
-- rollback DROP PROCEDURE Manufacturer_Modify_tr;
