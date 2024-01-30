-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:ManufacturerBrand_Drop_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE ManufacturerBrand_Drop_vtr
(
    @ManufacturerNo ManufacturerNo,
    @BrandNo        BrandNo
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
            FROM ManufacturerBrand
            WHERE ManufacturerNo = @ManufacturerNo
              AND BrandNo = @BrandNo
        )
        BEGIN
            RAISERROR (53303, -1, @State, @ManufacturerNo, @BrandNo);
        END
    IF EXISTS
        (
            SELECT 1
            FROM Product
            WHERE ManufacturerNo = @ManufacturerNo
              AND BrandNo = @BrandNo
        )
        BEGIN
            RAISERROR (53304, -1, @State, @ManufacturerNo, @BrandNo);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE ManufacturerBrand_Drop_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:ManufacturerBrand_Drop_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE ManufacturerBrand_Drop_tr
(
    @ManufacturerNo ManufacturerNo,
    @BrandNo        BrandNo
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
    EXEC ManufacturerBrand_Drop_vtr @ManufacturerNo, @BrandNo;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC ManufacturerBrand_Drop_vtr @ManufacturerNo, @BrandNo;

        -- Database updates --
        DELETE
        FROM ManufacturerBrand
        WHERE ManufacturerNo = @ManufacturerNo
          AND BrandNo = @BrandNo;

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
-- rollback DROP PROCEDURE ManufacturerBrand_Drop_tr;
