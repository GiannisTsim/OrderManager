-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:ProductOffering_Add_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE ProductOffering_Add_vtr
(
    @ProductCode      ProductCode,
    @OfferingTypeCode OfferingTypeCode,
    @UnitCount        BundleUnitCount,
    @BundleTypeNo     BundleTypeNo,
    @BundleTypeName   BundleTypeName
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
            FROM Product
            WHERE ProductCode = @ProductCode
        )
        BEGIN
            RAISERROR (53405, -1, @State, @ProductCode);
        END

    IF @OfferingTypeCode = 'U'
        BEGIN
            IF EXISTS
                (
                    SELECT 1
                    FROM ProductOffering_Unit
                    WHERE ProductCode = @ProductCode
                )
                BEGIN
                    RAISERROR (53507, -1, @State, @ProductCode)
                END
        END
    ELSE IF @OfferingTypeCode = 'B'
        BEGIN
            IF @BundleTypeNo IS NULL
                BEGIN
                    IF EXISTS
                        (
                            SELECT 1
                            FROM BundleType
                            WHERE Name = @BundleTypeName
                        )
                        BEGIN
                            RAISERROR (53506, -1, @State, @BundleTypeName);
                        END
                END
            ELSE
                BEGIN
                    IF NOT EXISTS
                        (
                            SELECT 1
                            FROM BundleType
                            WHERE BundleTypeNo = @BundleTypeNo
                        )
                        BEGIN
                            RAISERROR (53505, -1, @State, @BundleTypeNo);
                        END
                END

            IF EXISTS
                (
                    SELECT 1 FROM ProductOffering_Bundle WHERE ProductCode = @ProductCode AND UnitCount = @UnitCount
                )
                BEGIN
                    RAISERROR (53508, -1, @State, @ProductCode, @UnitCount);
                END

            IF EXISTS
                (
                    SELECT 1
                    FROM ProductOffering_Bundle
                    WHERE ProductCode = @ProductCode
                      AND BundleTypeNo = @BundleTypeNo
                )
                BEGIN
                    RAISERROR (53509, -1, @State, @ProductCode, @BundleTypeNo);
                END
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE ProductOffering_Add_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:ProductOffering_Add_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE ProductOffering_Add_tr
(
    @ProductCode      ProductCode,
    @OfferingTypeCode OfferingTypeCode,
    @UnitCount        BundleUnitCount = NULL,
    @BundleTypeNo     BundleTypeNo = NULL OUTPUT,
    @BundleTypeName   BundleTypeName = NULL,
    @OfferingNo       OfferingNo = NULL OUTPUT
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
        IF @OfferingTypeCode NOT IN ('U', 'B')
            BEGIN
                RAISERROR (53501, -1, 1);
            END
        IF @OfferingTypeCode = 'B' AND @UnitCount IS NULL
            BEGIN
                RAISERROR (53502, -1, 1);
            END
        IF @OfferingTypeCode = 'B' AND @UnitCount <= 0
            BEGIN
                RAISERROR (53503, -1, 1);
            END
        IF @OfferingTypeCode = 'B' AND @BundleTypeNo IS NULL AND (@BundleTypeName IS NULL OR @BundleTypeName = '')
            BEGIN
                RAISERROR (53504, -1, 1);
            END

        -- Offline constraint validation (no locks held) --
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        EXEC ProductOffering_Add_vtr @ProductCode, @OfferingTypeCode, @UnitCount, @BundleTypeNo, @BundleTypeName;

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
        EXEC ProductOffering_Add_vtr @ProductCode, @OfferingTypeCode, @UnitCount, @BundleTypeNo, @BundleTypeName;

        -- Database updates --
        SET @OfferingNo = COALESCE((
                                       SELECT MAX(OfferingNo) + 1
                                       FROM ProductOffering
                                       WHERE ProductCode = @ProductCode
                                   ), 1);

        INSERT INTO ProductOffering (ProductCode, OfferingNo, OfferingTypeCode, UpdatedDtm, IsObsolete)
        VALUES (@ProductCode, @OfferingNo, @OfferingTypeCode, SYSDATETIMEOFFSET(), 0);

        IF @OfferingTypeCode = 'U'
            BEGIN
                INSERT INTO ProductOffering_Unit (ProductCode, OfferingNo_Unit)
                VALUES (@ProductCode, @OfferingNo);
            END
        ELSE IF @OfferingTypeCode = 'B'
            BEGIN
                IF @BundleTypeNo IS NULL
                    BEGIN
                        SET @BundleTypeNo = COALESCE((
                                                         SELECT MAX(BundleTypeNo) + 1
                                                         FROM BundleType
                                                     ), 1)
                        INSERT INTO BundleType (BundleTypeNo, Name)
                        VALUES (@BundleTypeNo, @BundleTypeName);
                    END

                INSERT INTO ProductOffering_Bundle (ProductCode, OfferingNo_Bundle, UnitCount, BundleTypeNo)
                VALUES (@ProductCode, @OfferingNo, @UnitCount, @BundleTypeNo);
            END

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
-- rollback DROP PROCEDURE ProductOffering_Add_tr;
