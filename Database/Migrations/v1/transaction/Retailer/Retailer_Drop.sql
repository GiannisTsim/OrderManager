-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Retailer_Drop_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Retailer_Drop_vtr
(
    @RetailerNo RetailerNo,
    @UpdatedDtm _CurrencyDtm
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
            FROM RetailerBranch
            WHERE RetailerNo = @RetailerNo
        )
        BEGIN
            RAISERROR (52107, -1, @State, @RetailerNo);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Retailer_Drop_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Retailer_Drop_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Retailer_Drop_tr
(
    @RetailerNo RetailerNo,
    @UpdatedDtm _CurrencyDtm
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
    EXEC Retailer_Drop_vtr @RetailerNo, @UpdatedDtm;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC Retailer_Drop_vtr @RetailerNo, @UpdatedDtm;

        -- Database updates --
        DELETE
        FROM Retailer
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
-- rollback DROP PROCEDURE Retailer_Drop_tr;
