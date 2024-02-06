-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Person_Add_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Person_Add_vtr
(
    @Email Email
) AS
BEGIN
    -- Error state initialization --
    DECLARE @State TINYINT = CASE WHEN @@TRANCOUNT = 0 THEN 1
                                  ELSE 2
                             END;

    -- Validation checks --
    IF EXISTS
        (
            SELECT 1
            FROM Person
            WHERE Email = @Email
        )
        BEGIN
            RAISERROR (51107, -1, @State, @Email);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Person_Add_vtr;

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Person_Add_utr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Person_Add_utr
(
    @Email          Email,
    @EmailConfirmed _Bool,
    @PersonTypeCode PersonTypeCode,
    @InvitationDtm  _Dtm = NULL,
    @PasswordHash   _Text = NULL,
    @PersonNo       PersonNo = NULL OUTPUT
) AS
BEGIN
    -- Utility transaction integrity check --
    EXEC XactUtil_Integrity_Check;

    -- Database updates --
    SET @PersonNo = COALESCE((
                                 SELECT MAX(PersonNo) + 1
                                 FROM Person
                             ), 1);

    INSERT INTO Person(PersonNo, Email, EmailConfirmed, UpdatedDtm, IsObsolete, PersonTypeCode)
    VALUES (@PersonNo, @Email, @EmailConfirmed, SYSDATETIMEOFFSET(), 0, @PersonTypeCode);

    IF @PersonTypeCode = 'I'
        BEGIN
            INSERT INTO Person_Invitee (InviteeNo, InvitationDtm) VALUES (@PersonNo, @InvitationDtm);
        END
    ELSE IF @PersonTypeCode = 'U'
        BEGIN
            INSERT INTO Person_User (UserNo, PasswordHash) VALUES (@PersonNo, @PasswordHash);
        END

    -- Database updates successful --
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Person_Add_utr;
