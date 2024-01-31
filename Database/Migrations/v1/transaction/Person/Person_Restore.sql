-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Person_Restore_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Person_Restore_vtr
(
    @PersonNo   PersonNo,
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
    FROM Person
    WHERE PersonNo = @PersonNo;

    IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR (51108, -1, @State, @PersonNo);
        END
    IF @CurrentUpdatedDtm != @UpdatedDtm
        BEGIN
            DECLARE @UpdatedDtmString NVARCHAR(MAX) = CONVERT(NVARCHAR, @UpdatedDtm, 127);
            RAISERROR (51109, -1, @State, @PersonNo, @UpdatedDtmString);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Person_Restore_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Person_Restore_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Person_Restore_tr
(
    @PersonNo   PersonNo,
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
    EXEC Person_Restore_vtr @PersonNo, @UpdatedDtm;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC Person_Restore_vtr @PersonNo, @UpdatedDtm;

        -- Database updates --
        UPDATE Person
        SET IsObsolete = 0,
            UpdatedDtm = SYSDATETIMEOFFSET()
        WHERE PersonNo = @PersonNo
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
-- rollback DROP PROCEDURE Person_Restore_tr;
