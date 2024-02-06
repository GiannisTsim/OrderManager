-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Manufacturer_Drop_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Manufacturer_Drop_vtr
(
    @ManufacturerNo ManufacturerNo
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
            SELECT 1
            FROM ManufacturerBrand
            WHERE ManufacturerNo = @ManufacturerNo
        )
        BEGIN
            RAISERROR (53204, -1, @State, @ManufacturerNo);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Manufacturer_Drop_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Manufacturer_Drop_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Manufacturer_Drop_tr
(
    @ManufacturerNo ManufacturerNo
) AS
BEGIN
    DECLARE @ProcName SYSNAME = OBJECT_NAME(@@PROCID);

    ----------------------
    -- Validation block --
    ----------------------
    -- Transaction integrity check --
    EXEC Xact_Integrity_Check;

    -- Offline constraint validation (no locks held) --
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    EXEC Manufacturer_Drop_vtr @ManufacturerNo;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC Manufacturer_Drop_vtr @ManufacturerNo;

        -- Database updates --
        DELETE
        FROM Manufacturer
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
-- rollback DROP PROCEDURE Manufacturer_Drop_tr;
