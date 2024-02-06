-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Product_Drop_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Product_Drop_vtr
(
    @ProductCode ProductCode,
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
    FROM Product
    WHERE ProductCode = @ProductCode;

    IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR (53405, -1, @State, @ProductCode);
        END
    IF @CurrentUpdatedDtm != @UpdatedDtm
        BEGIN
            DECLARE @UpdatedDtmString NVARCHAR(MAX) = CONVERT(NVARCHAR, @UpdatedDtm, 127);
            RAISERROR (53406, -1, @State, @ProductCode, @UpdatedDtmString);
        END

    IF EXISTS
        (
            SELECT 1
            FROM ProductOffering
            WHERE ProductCode = @ProductCode
        )
        BEGIN
            RAISERROR (53407, -1, @State, @ProductCode);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Product_Drop_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Product_Drop_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Product_Drop_tr
(
    @ProductCode ProductCode,
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
    EXEC Product_Drop_vtr @ProductCode, @UpdatedDtm;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC Product_Drop_vtr @ProductCode, @UpdatedDtm;

        -- Database updates --
        DELETE
        FROM Product
        WHERE ProductCode = @ProductCode
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
-- rollback DROP PROCEDURE Product_Drop_tr;
