-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Person_Modify_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Person_Modify_vtr
(
    @PersonNo   PersonNo,
    @UpdatedDtm _CurrencyDtm,
    @Email      Email
) AS
BEGIN
    -- Error state initialization --
    DECLARE @State TINYINT = CASE WHEN @@TRANCOUNT = 0 THEN 1
                                  ELSE 2
                             END;

    -- Validation checks --
    DECLARE @CurrentUpdatedDtm _CurrencyDtm;
    SELECT @CurrentUpdatedDtm = UpdatedDtm FROM Person WHERE PersonNo = @PersonNo;

    IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR (51108, -1, @State, @PersonNo);
        END
    IF @CurrentUpdatedDtm != @UpdatedDtm
        BEGIN
            DECLARE @UpdatedDtmString NVARCHAR(MAX) = CONVERT(NVARCHAR, @UpdatedDtm, 127);
            RAISERROR (51109, -1, @State, @PersonNo, @UpdatedDtmString);
        END
    IF EXISTS
        (
            SELECT 1
            FROM Person
            WHERE Email = @Email
              AND PersonNo != @PersonNo
        )
        BEGIN
            RAISERROR (51107, -1, @State, @Email);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Person_Modify_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Person_Modify_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Person_Modify_tr
(
    @PersonNo       PersonNo,
    @UpdatedDtm     _CurrencyDtm,
    @Email          Email,
    @EmailConfirmed _Bool,
    @PersonTypeCode PersonTypeCode,
    @InvitationDtm  _Dtm = NULL,
    @PasswordHash   _Text = NULL
) AS
BEGIN
    DECLARE @ProcName SYSNAME = OBJECT_NAME(@@PROCID);

    ----------------------
    -- Validation block --
    ----------------------
    -- Transaction integrity check --
    EXEC Xact_Integrity_Check;

    -- Parameter checks --
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
            RAISERROR (51104, -1, -1, @PersonTypeCode);
        END
    IF @PersonTypeCode = 'I' AND @InvitationDtm IS NULL
        BEGIN
            RAISERROR (51105, -1, -1);
        END
    IF @PersonTypeCode = 'U' AND @PasswordHash IS NULL
        BEGIN
            RAISERROR (51106, -1, -1);
        END

    -- Offline constraint validation (no locks held) --
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    EXEC Person_Modify_vtr @PersonNo, @UpdatedDtm, @Email;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC Person_Modify_vtr @PersonNo, @UpdatedDtm, @Email;

        -- Database updates --
        DECLARE @PreviousPersonTypeCode PersonTypeCode = (
                                                             SELECT PersonTypeCode
                                                             FROM Person
                                                             WHERE PersonNo = @PersonNo
                                                               AND UpdatedDtm = @UpdatedDtm
        );


        IF @PersonTypeCode = 'U' AND @PreviousPersonTypeCode = 'I'
            BEGIN
                DELETE FROM Person_Invitee WHERE InviteeNo = @PersonNo;
                INSERT INTO Person_User (UserNo, PasswordHash) VALUES (@PersonNo, @PasswordHash);
            END
        ELSE IF @PersonTypeCode = 'U' AND @PreviousPersonTypeCode = 'U'
            BEGIN
                UPDATE Person_User SET PasswordHash = @PasswordHash WHERE UserNo = @PersonNo;
            END
        ELSE IF @PersonTypeCode = 'I' AND @PreviousPersonTypeCode = 'U'
            BEGIN
                DELETE FROM Person_User WHERE UserNo = @PersonNo;
                INSERT INTO Person_Invitee (InviteeNo, InvitationDtm)
                VALUES (@PersonNo, @InvitationDtm);
            END
        ELSE IF @PersonTypeCode = 'I' AND @PreviousPersonTypeCode = 'I'
            BEGIN
                UPDATE Person_Invitee
                SET InvitationDtm = @InvitationDtm
                WHERE InviteeNo = @PersonNo;
            END

        UPDATE Person
        SET Email          = @Email,
            EmailConfirmed = @EmailConfirmed,
            UpdatedDtm     = SYSDATETIMEOFFSET()
        WHERE PersonNo = @PersonNo
          AND UpdatedDtm = @UpdatedDtm;

        -- Commit --
        COMMIT TRANSACTION @ProcName;
        RETURN 0;
    END TRY BEGIN CATCH
        ROLLBACK TRANSACTION @ProcName;
        THROW;
    END CATCH
END
GO
-- rollback DROP PROCEDURE Person_Modify_tr;
