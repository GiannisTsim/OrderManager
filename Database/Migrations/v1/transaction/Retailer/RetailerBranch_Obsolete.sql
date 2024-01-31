-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:RetailerBranch_Obsolete_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE RetailerBranch_Obsolete_vtr
(
    @RetailerNo RetailerNo,
    @BranchNo   BranchNo,
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
    FROM RetailerBranch
    WHERE RetailerNo = @RetailerNo
      AND BranchNo = @BranchNo;

    IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR (52203, -1, @State, @RetailerNo, @BranchNo);
        END
    IF @CurrentUpdatedDtm != @UpdatedDtm
        BEGIN
            DECLARE @UpdatedDtmString NVARCHAR(MAX) = CONVERT(NVARCHAR, @UpdatedDtm, 127);
            RAISERROR (52204, -1, @State, @RetailerNo, @BranchNo, @UpdatedDtmString);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE RetailerBranch_Obsolete_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:RetailerBranch_Obsolete_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE RetailerBranch_Obsolete_tr
(
    @RetailerNo RetailerNo,
    @BranchNo   BranchNo,
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
    EXEC RetailerBranch_Obsolete_vtr @RetailerNo, @BranchNo, @UpdatedDtm;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC RetailerBranch_Obsolete_vtr @RetailerNo, @BranchNo, @UpdatedDtm;

        -- Database updates --
        UPDATE RetailerBranch
        SET IsObsolete = 1,
            UpdatedDtm = SYSDATETIMEOFFSET()
        WHERE RetailerNo = @RetailerNo
          AND BranchNo = @BranchNo
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
-- rollback DROP PROCEDURE RetailerBranch_Obsolete_tr;
