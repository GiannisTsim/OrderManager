-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:ManufacturerBrand_Add_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE ManufacturerBrand_Add_vtr
(
    @ManufacturerNo   ManufacturerNo,
    @Name             BrandName,
    @ManufacturerName ManufacturerName
) AS
BEGIN
    -- Error state initialization --
    DECLARE @State TINYINT = CASE WHEN @@TRANCOUNT = 0 THEN 1
                                  ELSE 2
                             END;

    -- Validation checks --
    IF @ManufacturerNo IS NULL
        BEGIN
            EXEC Manufacturer_Add_vtr @ManufacturerName;
        END
    ELSE
        BEGIN
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
                      AND Name = @Name
                )
                BEGIN
                    RAISERROR (53302, -1, @State, @ManufacturerNo, @Name);
                END
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE ManufacturerBrand_Add_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:ManufacturerBrand_Add_utr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE ManufacturerBrand_Add_utr
(
    @Name             BrandName,
    @ManufacturerNo   ManufacturerNo = NULL OUTPUT,
    @ManufacturerName ManufacturerName = NULL,
    @BrandNo          BrandNo = NULL OUTPUT
) AS
BEGIN
    -- Utility transaction integrity check --
    EXEC XactUtil_Integrity_Check;

    -- Database updates --
    IF @ManufacturerNo IS NULL
        BEGIN
            EXEC Manufacturer_Add_utr @ManufacturerName, @ManufacturerNo OUTPUT;
        END

    SET @BrandNo = COALESCE((
                                SELECT MAX(BrandNo) + 1
                                FROM ManufacturerBrand
                                WHERE ManufacturerNo = @ManufacturerNo
                            ), 1);

    INSERT INTO ManufacturerBrand (ManufacturerNo, BrandNo, Name)
    VALUES (@ManufacturerNo, @BrandNo, @Name);

    -- Database updates successful --
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE ManufacturerBrand_Add_utr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:ManufacturerBrand_Add_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE ManufacturerBrand_Add_tr
(
    @ManufacturerNo   ManufacturerNo OUTPUT,
    @Name             BrandName,
    @ManufacturerName ManufacturerName = NULL,
    @BrandNo          BrandNo = NULL OUTPUT
) AS
BEGIN
    DECLARE @ProcName SYSNAME = OBJECT_NAME(@@PROCID);

    ----------------------
    -- Validation block --
    ----------------------
    BEGIN TRY

        -- Transaction integrity check --
        EXEC Xact_Integrity_Check;

        -- Parameter checks --
        IF @ManufacturerNo IS NULL AND (@ManufacturerName IS NULL OR @ManufacturerName = '')
            BEGIN
                RAISERROR (53201, -1, 1);
            END
        IF @Name IS NULL OR @Name = ''
            BEGIN
                RAISERROR (53301, -1, 1);
            END

        -- Offline constraint validation (no locks held) --
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        EXEC ManufacturerBrand_Add_vtr @ManufacturerNo, @Name, @ManufacturerName;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC ManufacturerBrand_Add_vtr @ManufacturerNo, @Name, @ManufacturerName;

        -- Database updates --
        EXEC ManufacturerBrand_Add_utr @Name, @ManufacturerNo OUTPUT, @ManufacturerName, @BrandNo OUTPUT;

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
-- rollback DROP PROCEDURE ManufacturerBrand_Add_tr;
