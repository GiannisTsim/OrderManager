-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Retailer_Modify_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Retailer_Modify_vtr
(
    @RetailerNo RetailerNo,
    @UpdatedDtm _CurrencyDtm,
    @TaxId      TaxId,
    @Name       RetailerName
) AS
BEGIN
    -- Error state initialization --
    DECLARE @State TINYINT = CASE WHEN @@TRANCOUNT = 0 THEN 1
                                  ELSE 2
                             END;

    -- Validation checks --
    DECLARE @CurrentUpdatedDtm _CurrencyDtm;
    SELECT @CurrentUpdatedDtm = UpdatedDtm
    FROM Retailer
    WHERE RetailerNo = @RetailerNo;

    IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR (52105, -1, @State, @RetailerNo);
        END
    IF @CurrentUpdatedDtm != @UpdatedDtm
        BEGIN
            DECLARE @UpdatedDtmString NVARCHAR(MAX) = CONVERT(NVARCHAR, @UpdatedDtm, 127);
            RAISERROR (52106, -1, @State, @RetailerNo, @UpdatedDtmString);
        END
    IF EXISTS
        (
            SELECT 1
            FROM Retailer
            WHERE TaxId = @TaxId
              AND RetailerNo != @RetailerNo
        )
        BEGIN
            RAISERROR (52103, -1, @State, @TaxId);
        END
    IF EXISTS
        (
            SELECT 1
            FROM Retailer
            WHERE Name = @Name
              AND RetailerNo != @RetailerNo
        )
        BEGIN
            RAISERROR (52104, -1, @State, @Name);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Retailer_Modify_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Retailer_Modify_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Retailer_Modify_tr
(
    @RetailerNo RetailerNo,
    @UpdatedDtm _CurrencyDtm,
    @TaxId      TaxId,
    @Name       RetailerName
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
        IF @TaxId IS NULL OR @TaxId = ''
            BEGIN
                RAISERROR (52101, -1 , 1);
            END
        IF @Name IS NULL OR @Name = ''
            BEGIN
                RAISERROR (52102, -1 , 1);
            END

        -- Offline constraint validation (no locks held) --
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        EXEC Retailer_Modify_vtr @RetailerNo, @UpdatedDtm, @TaxId, @Name;

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
        EXEC Retailer_Modify_vtr @RetailerNo, @UpdatedDtm, @TaxId, @Name;

        -- Database updates --
        UPDATE Retailer
        SET Name       = @Name,
            TaxId      = @TaxId,
            UpdatedDtm = SYSDATETIMEOFFSET()
        WHERE RetailerNo = @RetailerNo
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
-- rollback DROP PROCEDURE Retailer_Modify_tr;
