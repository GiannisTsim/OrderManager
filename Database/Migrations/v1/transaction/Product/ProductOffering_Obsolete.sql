-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:ProductOffering_Obsolete_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE ProductOffering_Obsolete_vtr
(
    @ProductCode ProductCode,
    @OfferingNo  OfferingNo,
    @UpdatedDtm  _CurrencyDtm
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

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE ProductOffering_Obsolete_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:ProductOffering_Obsolete_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE ProductOffering_Obsolete_tr
(
    @ProductCode ProductCode,
    @OfferingNo  OfferingNo,
    @UpdatedDtm  _CurrencyDtm
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
    EXEC ProductOffering_Obsolete_vtr @ProductCode, @OfferingNo, @UpdatedDtm;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC ProductOffering_Obsolete_vtr @ProductCode, @OfferingNo, @UpdatedDtm;

        -- Database updates --
        UPDATE ProductOffering
        SET IsObsolete = 1,
            UpdatedDtm = SYSDATETIMEOFFSET()
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
-- rollback DROP PROCEDURE ProductOffering_Obsolete_tr;
