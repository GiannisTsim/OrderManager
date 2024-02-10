-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:RetailerBranch_Add_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE RetailerBranch_Add_vtr
(
    @RetailerNo RetailerNo,
    @Name       BranchName
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
            FROM Retailer
            WHERE RetailerNo = @RetailerNo
        )
        BEGIN
            RAISERROR (52105, -1, @State, @RetailerNo);
        END
    IF EXISTS
        (
            SELECT 1
            FROM RetailerBranch
            WHERE RetailerNo = @RetailerNo
              AND Name = @Name
        )
        BEGIN
            RAISERROR (52202, -1, @State, @RetailerNo, @Name);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE RetailerBranch_Add_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:RetailerBranch_Add_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE RetailerBranch_Add_tr
(
    @RetailerNo RetailerNo,
    @Name       BranchName,
    @BranchNo   BranchNo = NULL OUTPUT
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
        EXEC RetailerBranch_Add_vtr @RetailerNo, @Name;

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
        EXEC RetailerBranch_Add_vtr @RetailerNo, @Name;

        -- Database updates --
        SET @BranchNo = (
                            SELECT COALESCE(MAX(BranchNo) + 1, 1)
                            FROM RetailerBranch
                            WHERE RetailerNo = @RetailerNo
        );
        INSERT INTO RetailerBranch (RetailerNo, BranchNo, Name, UpdatedDtm, IsObsolete)
        VALUES (@RetailerNo, @BranchNo, @Name, SYSDATETIMEOFFSET(), 0);

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
-- rollback DROP PROCEDURE RetailerBranch_Add_tr;
