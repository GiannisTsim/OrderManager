-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:RetailerBranchAgent_Obsolete_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE RetailerBranchAgent_Obsolete_vtr
(
    @RetailerNo RetailerNo,
    @BranchNo   BranchNo,
    @AgentNo    PersonNo,
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
    FROM RetailerBranchAgent
    WHERE RetailerNo = @RetailerNo
      AND BranchNo = @BranchNo
      AND AgentNo = @AgentNo;

    IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR (52302, -1, @State, @RetailerNo, @BranchNo, @AgentNo);
        END
    IF @CurrentUpdatedDtm != @UpdatedDtm
        BEGIN
            DECLARE @UpdatedDtmString NVARCHAR(MAX) = CONVERT(NVARCHAR, @UpdatedDtm, 127);
            RAISERROR (52303, -1, @State, @RetailerNo, @BranchNo, @AgentNo, @UpdatedDtmString);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE RetailerBranchAgent_Obsolete_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:RetailerBranchAgent_Obsolete_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE RetailerBranchAgent_Obsolete_tr
(
    @RetailerNo RetailerNo,
    @BranchNo   BranchNo,
    @AgentNo    PersonNo,
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
    EXEC RetailerBranchAgent_Obsolete_vtr @RetailerNo, @BranchNo, @AgentNo, @UpdatedDtm;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC RetailerBranchAgent_Obsolete_vtr @RetailerNo, @BranchNo, @AgentNo, @UpdatedDtm;

        -- Database updates --
        UPDATE RetailerBranchAgent
        SET IsObsolete = 1,
            UpdatedDtm = SYSDATETIMEOFFSET()
        WHERE RetailerNo = @RetailerNo
          AND BranchNo = @BranchNo
          AND AgentNo = @AgentNo
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
-- rollback DROP PROCEDURE RetailerBranchAgent_Obsolete_tr;
