-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Person_Add_utr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Person_Add_utr
(
    @PersonNo       PersonNo OUTPUT,
    @Email          Email,
    @EmailConfirmed _Bool,
    @PersonTypeCode PersonTypeCode,
    @InvitationDtm  _Dtm,
    @PasswordHash   _Text
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
    ELSE -- IF @PersonTypeCode = 'U'
        BEGIN
            INSERT INTO Person_User (UserNo, PasswordHash) VALUES (@PersonNo, @PasswordHash);
        END

    -- Database updates successful --
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Person_Add_utr;
