-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:RetailerBranchAgent_Add_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE RetailerBranchAgent_Add_vtr
(
    @RetailerNo RetailerNo,
    @BranchNo   BranchNo,
    @AgentNo    PersonNo,
    @Email      Email
) AS
BEGIN
    -- Error state initialization --
    DECLARE @State TINYINT = CASE WHEN @@TRANCOUNT = 0 THEN 1
                                  ELSE 2
                             END;

    -- Validation checks --
    IF @AgentNo IS NULL
        BEGIN
            IF EXISTS
                (
                    SELECT 1
                    FROM Person
                    WHERE Email = @Email
                )
                BEGIN
                    RAISERROR (51107, -1, @State, @Email);
                END
        END
    ELSE
        BEGIN
            IF NOT EXISTS
                (
                    SELECT 1
                    FROM Person
                    WHERE PersonNo = @AgentNo
                )
                BEGIN
                    RAISERROR (51108, -1, @State, @AgentNo);
                END
        END
    IF NOT EXISTS
        (
            SELECT 1 FROM RetailerBranch WHERE RetailerNo = @RetailerNo AND BranchNo = @BranchNo
        )
        BEGIN
            RAISERROR (52203, -1, @State, @RetailerNo, @BranchNo);
        END
    IF EXISTS
        (
            SELECT 1
            FROM RetailerBranchAgent
            WHERE RetailerNo = @RetailerNo
              AND BranchNo = @BranchNo
              AND AgentNo = @AgentNo
        )
        BEGIN
            RAISERROR (52301, -1, @State, @RetailerNo, @BranchNo, @AgentNo);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE RetailerBranchAgent_Add_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:RetailerBranchAgent_Add_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE RetailerBranchAgent_Add_tr
(
    @RetailerNo     RetailerNo,
    @BranchNo       BranchNo,
    @AgentNo        PersonNo OUTPUT,
    @Email          Email,
    @EmailConfirmed _Bool,
    @PersonTypeCode PersonTypeCode,
    @InvitationDtm  _Dtm,
    @PasswordHash   _Text
) AS
BEGIN
    DECLARE @ProcName SYSNAME = OBJECT_NAME(@@PROCID);

    ----------------------
    -- Validation block --
    ----------------------
    -- Transaction integrity check --
    EXEC Xact_Integrity_Check;

    -- Parameter checks --
    IF @AgentNo IS NULL
        BEGIN
            IF @Email IS NULL
                BEGIN
                    RAISERROR (51101, -1, 1);
                END
            IF @EmailConfirmed IS NULL
                BEGIN
                    RAISERROR (51102, -1, 1);
                END
            IF @PersonTypeCode IS NULL
                BEGIN
                    RAISERROR (51103, -1, 1);
                END
            IF @PersonTypeCode NOT IN ('I', 'U')
                BEGIN
                    RAISERROR (51104, -1, 1, @PersonTypeCode);
                END
            IF @PersonTypeCode = 'I' AND @InvitationDtm IS NULL
                BEGIN
                    RAISERROR (51105, -1, 1);
                END
            IF @PersonTypeCode = 'U' AND @PasswordHash IS NULL
                BEGIN
                    RAISERROR (51106, -1, 1);
                END
        END

    -- Offline constraint validation (no locks held) --
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    EXEC RetailerBranchAgent_Add_vtr @RetailerNo, @BranchNo, @AgentNo, @Email;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC RetailerBranchAgent_Add_vtr @RetailerNo, @BranchNo, @AgentNo, @Email;

        -- Database updates --
        IF @AgentNo IS NULL
            BEGIN
                EXEC Person_Add_utr @AgentNo, @Email, @EmailConfirmed, @PersonTypeCode, @InvitationDtm, @PasswordHash;
                --                 SET @AgentNo = COALESCE((
                --                                              SELECT MAX(PersonNo) + 1
                --                                              FROM Person
                --                                          ), 1);
                -- 
                --                 INSERT INTO Person(PersonNo, Email, EmailConfirmed, UpdatedDtm, IsObsolete, PersonTypeCode)
                --                 VALUES (@AgentNo, @Email, @EmailConfirmed, SYSDATETIMEOFFSET(), 0, @PersonTypeCode);
                --                 IF @PersonTypeCode = 'I'
                --                     BEGIN
                --                         INSERT INTO Person_Invitee (InviteeNo, InvitationDtm) VALUES (@AgentNo, @InvitationDtm);
                --                     END
                --                 ELSE -- IF @PersonTypeCode = 'U'
                --                     BEGIN
                --                         INSERT INTO Person_User (UserNo, PasswordHash) VALUES (@AgentNo, @PasswordHash);
                --                     END
            END

        INSERT INTO RetailerBranchAgent (RetailerNo, BranchNo, AgentNo, UpdatedDtm, IsObsolete)
        VALUES (@RetailerNo, @BranchNo, @AgentNo, SYSDATETIMEOFFSET(), 0);

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
-- rollback DROP PROCEDURE RetailerBranchAgent_Add_tr;
