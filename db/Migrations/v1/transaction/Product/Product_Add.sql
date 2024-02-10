-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Product_Add_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Product_Add_vtr
(
    @ProductCode      ProductCode,
    @Name             ProductName,
    @ManufacturerNo   ManufacturerNo,
    @BrandNo          BrandNo,
    @CategoryNo       CategoryNo,
    @ManufacturerName ManufacturerName,
    @BrandName        BrandName,
    @CategoryName     CategoryName,
    @ParentCategoryNo CategoryNo
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
            FROM Product
            WHERE ProductCode = @ProductCode
        )
        BEGIN
            RAISERROR (53403, -1, @State, @ProductCode);
        END

    IF @CategoryNo IS NULL
        BEGIN
            EXEC Category_Leaf_Add_vtr @ParentCategoryNo, @CategoryName;
        END
    ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM Category
            WHERE CategoryNo = @CategoryNo
        )
        BEGIN
            RAISERROR (53103, -1, @State, @CategoryNo);
        END

    IF @ManufacturerNo IS NULL OR @BrandNo IS NULL
        BEGIN
            EXEC ManufacturerBrand_Add_vtr @ManufacturerNo, @BrandName, @ManufacturerName;
        END
    ELSE
        BEGIN
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
                      AND Name = @Name
                )
                BEGIN
                    RAISERROR (53404, -1, @State, @ManufacturerNo, @BrandNo, @Name);
                END
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Product_Add_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Product_Add_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Product_Add_tr
(
    @ProductCode      ProductCode,
    @Name             ProductName,
    @ManufacturerNo   ManufacturerNo = NULL OUTPUT,
    @BrandNo          BrandNo = NULL OUTPUT,
    @CategoryNo       CategoryNo = NULL OUTPUT,
    @ManufacturerName ManufacturerName = NULL,
    @BrandName        BrandName = NULL,
    @CategoryName     CategoryName = NULL,
    @ParentCategoryNo CategoryNo = 0
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
        IF @CategoryNo IS NULL AND @CategoryName IS NULL
            BEGIN
                RAISERROR (53101, -1, 1);
            END
        IF @ManufacturerNo IS NULL AND @ManufacturerName IS NULL
            BEGIN
                RAISERROR (53201, -1, 1);
            END
        IF @BrandNo IS NULL AND @BrandName IS NULL
            BEGIN
                RAISERROR (53301, -1, 1);
            END
        IF @ProductCode IS NULL
            BEGIN
                RAISERROR (53401, -1, 1);
            END
        IF @Name IS NULL
            BEGIN
                RAISERROR (53402, -1, 1);
            END

        -- Offline constraint validation (no locks held) --
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        EXEC Product_Add_vtr @ProductCode, @Name, @ManufacturerNo, @BrandNo, @CategoryNo, @ManufacturerName, @BrandName,
             @CategoryName, @ParentCategoryNo;

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
        EXEC Product_Add_vtr @ProductCode, @Name, @ManufacturerNo, @BrandNo, @CategoryNo, @ManufacturerName, @BrandName,
             @CategoryName, @ParentCategoryNo;

        -- Database updates --
        IF @CategoryNo IS NULL
            BEGIN
                EXEC Category_Leaf_Add_utr @CategoryName, @ParentCategoryNo, @CategoryNo OUTPUT;
            END

        IF @ManufacturerNo IS NULL OR @BrandNo IS NULL
            BEGIN
                EXEC ManufacturerBrand_Add_utr @BrandName, @ManufacturerNo OUTPUT, @ManufacturerName, @BrandNo OUTPUT;
            END

        INSERT INTO Product (ProductCode, ManufacturerNo, BrandNo, Name, CategoryNo, UpdatedDtm, IsObsolete)
        VALUES (@ProductCode, @ManufacturerNo, @BrandNo, @Name, @CategoryNo, SYSDATETIMEOFFSET(), 0);

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
-- rollback DROP PROCEDURE Product_Add_tr;
