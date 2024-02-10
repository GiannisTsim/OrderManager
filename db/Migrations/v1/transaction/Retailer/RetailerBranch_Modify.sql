-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:RetailerBranch_Modify_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE RetailerBranch_Modify_vtr
(
    @RetailerNo RetailerNo,
    @BranchNo   BranchNo,
    @UpdatedDtm _CurrencyDtm,
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
    IF EXISTS
        (
            SELECT 1
            FROM RetailerBranch
            WHERE RetailerNo = @RetailerNo
              AND Name = @Name
              AND BranchNo != @BranchNo
        )
        BEGIN
            RAISERROR (52202, -1, @State, @RetailerNo, @Name);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE RetailerBranch_Modify_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:RetailerBranch_Modify_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE RetailerBranch_Modify_tr
(
    @RetailerNo RetailerNo,
    @BranchNo   BranchNo,
    @UpdatedDtm _CurrencyDtm,
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
        IF @Name IS NULL
            BEGIN
                RAISERROR (52201, -1, 1);
            END

        -- Offline constraint validation (no locks held) --
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        EXEC RetailerBranch_Modify_vtr @RetailerNo, @BranchNo, @UpdatedDtm, @Name;

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
        EXEC RetailerBranch_Modify_vtr @RetailerNo, @BranchNo, @UpdatedDtm, @Name;

        -- Database updates --
        UPDATE RetailerBranch
        SET Name       = @Name,
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
-- rollback DROP PROCEDURE RetailerBranch_Modify_tr;
