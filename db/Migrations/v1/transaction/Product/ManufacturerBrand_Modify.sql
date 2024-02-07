-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:ManufacturerBrand_Modify_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE ManufacturerBrand_Modify_vtr
(
    @ManufacturerNo ManufacturerNo,
    @BrandNo        BrandNo,
    @Name           BrandName
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
            FROM ManufacturerBrand
            WHERE ManufacturerNo = @ManufacturerNo
              AND Name = @Name
              AND BrandNo != @BrandNo
        )
        BEGIN
            RAISERROR (53302, -1, @State, @ManufacturerNo, @Name);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE ManufacturerBrand_Modify_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:ManufacturerBrand_Modify_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE ManufacturerBrand_Modify_tr
(
    @ManufacturerNo ManufacturerNo,
    @BrandNo        BrandNo,
    @Name           BrandName
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
            RAISERROR (53301, -1, 1);
        END

    -- Offline constraint validation (no locks held) --
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    EXEC ManufacturerBrand_Modify_vtr @ManufacturerNo, @BrandNo, @Name;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC ManufacturerBrand_Modify_vtr @ManufacturerNo, @BrandNo, @Name;

        -- Database updates --
        UPDATE ManufacturerBrand
        SET Name = @Name
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
-- rollback DROP PROCEDURE ManufacturerBrand_Modify_tr;
