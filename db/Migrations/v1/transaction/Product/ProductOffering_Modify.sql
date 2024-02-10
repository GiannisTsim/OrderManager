-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:ProductOffering_Modify_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE ProductOffering_Modify_vtr
(
    @ProductCode      ProductCode,
    @OfferingNo       OfferingNo,
    @UpdatedDtm       _CurrencyDtm,
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
    DECLARE @CurrentUpdatedDtm _CurrencyDtm;
    SELECT @CurrentUpdatedDtm = UpdatedDtm
    FROM ProductOffering
    WHERE ProductCode = @ProductCode
      AND OfferingNo = @OfferingNo;

    IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR (53510, -1, @State, @ProductCode, @OfferingNo);
        END
    IF @CurrentUpdatedDtm != @UpdatedDtm
        BEGIN
            DECLARE @UpdatedDtmString NVARCHAR(MAX) = CONVERT(NVARCHAR, @UpdatedDtm, 127);
            RAISERROR (53511, -1, @State, @ProductCode, @OfferingNo, @UpdatedDtmString);
        END

    IF @OfferingTypeCode = 'U'
        BEGIN
            IF EXISTS
                (
                    SELECT 1
                    FROM ProductOffering_Unit
                    WHERE ProductCode = @ProductCode
                      AND OfferingNo_Unit != @OfferingNo
                )
                BEGIN
                    RAISERROR (53507, -1, @State, @ProductCode);
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
                    SELECT 1
                    FROM ProductOffering_Bundle
                    WHERE ProductCode = @ProductCode
                      AND UnitCount = @UnitCount
                      AND OfferingNo_Bundle != @OfferingNo
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
                      AND OfferingNo_Bundle != @OfferingNo
                )
                BEGIN
                    RAISERROR (53509, -1, @State, @ProductCode, @BundleTypeNo);
                END
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE ProductOffering_Modify_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:ProductOffering_Modify_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE ProductOffering_Modify_tr
(
    @ProductCode      ProductCode,
    @OfferingNo       OfferingNo,
    @UpdatedDtm       _CurrencyDtm,
    @OfferingTypeCode OfferingTypeCode,
    @UnitCount        BundleUnitCount = NULL,
    @BundleTypeNo     BundleTypeNo = NULL OUTPUT,
    @BundleTypeName   BundleTypeName = NULL
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
        IF @OfferingTypeCode = 'B' AND @BundleTypeNo IS NULL AND @BundleTypeName IS NULL
            BEGIN
                RAISERROR (53504, -1, 1);
            END

        -- Offline constraint validation (no locks held) --
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        EXEC ProductOffering_Modify_vtr @ProductCode, @OfferingNo, @UpdatedDtm, @OfferingTypeCode, @UnitCount,
             @BundleTypeNo, @BundleTypeName;

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
        EXEC ProductOffering_Modify_vtr @ProductCode, @OfferingNo, @UpdatedDtm, @OfferingTypeCode, @UnitCount,
             @BundleTypeNo, @BundleTypeName;

        -- Database updates --
        DECLARE @PreviousOfferingTypeCode OfferingTypeCode = (
                                                                 SELECT OfferingTypeCode
                                                                 FROM ProductOffering
                                                                 WHERE ProductCode = @ProductCode
                                                                   AND OfferingNo = @OfferingNo
                                                                   AND UpdatedDtm = @UpdatedDtm
        );

        IF @OfferingTypeCode = 'U'
            BEGIN
                IF @PreviousOfferingTypeCode = 'B'
                    BEGIN
                        DELETE
                        FROM ProductOffering_Bundle
                        WHERE ProductCode = @ProductCode
                          AND OfferingNo_Bundle = @OfferingNo;
                        INSERT INTO ProductOffering_Unit (ProductCode, OfferingNo_Unit)
                        VALUES (@ProductCode, @OfferingNo);
                    END
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

                IF @PreviousOfferingTypeCode = 'U'
                    BEGIN
                        DELETE
                        FROM ProductOffering_Unit
                        WHERE ProductCode = @ProductCode
                          AND OfferingNo_Unit = @OfferingNo;
                        INSERT INTO ProductOffering_Bundle (ProductCode, OfferingNo_Bundle, UnitCount, BundleTypeNo)
                        VALUES (@ProductCode, @OfferingNo, @UnitCount, @BundleTypeNo);
                    END
                ELSE IF @PreviousOfferingTypeCode = 'B'
                    BEGIN
                        UPDATE ProductOffering_Bundle
                        SET UnitCount    = @UnitCount,
                            BundleTypeNo = @BundleTypeNo
                        WHERE ProductCode = @ProductCode
                          AND OfferingNo_Bundle = @OfferingNo;
                    END
            END

        UPDATE ProductOffering
        SET OfferingTypeCode = @OfferingTypeCode,
            UpdatedDtm       = SYSDATETIMEOFFSET()
        WHERE ProductCode = @ProductCode
          AND OfferingNo = @OfferingNo
          AND UpdatedDtm = @UpdatedDtm;

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
-- rollback DROP PROCEDURE ProductOffering_Modify_tr;
