-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:test stripComments:false endDelimiter:GO contextFilter:@dev runOnChange:true
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC tSQLt.NewTestClass PersonAdminRole_Add;
GO

CREATE OR ALTER PROCEDURE PersonAdminRole_Add.SetUp AS
BEGIN
    EXEC tSQLt.SpyProcedure Xact_Integrity_Check;
END
GO

CREATE OR ALTER PROCEDURE PersonAdminRole_Add.[Test success when adding new Person_Invitee]
AS
BEGIN
    DECLARE @AdminNo PersonNo;
    DECLARE @AdminRoleCode AdminRoleCode = 'prs';
    DECLARE @Email Email = 'test@test.com';
    DECLARE @EmailConfirmed _Bool = 0;
    DECLARE @PersonTypeCode PersonTypeCode = 'I';
    DECLARE @InvitationDtm DATETIMEOFFSET = SYSDATETIMEOFFSET();

    EXEC PersonAdminRole_Add_tr @AdminRoleCode = @AdminRoleCode, @AdminNo = @AdminNo OUTPUT, @Email = @Email,
         @EmailConfirmed = @EmailConfirmed, @PersonTypeCode = @PersonTypeCode, @InvitationDtm = @InvitationDtm;

    SELECT PersonNo,
           Email,
           EmailConfirmed,
           IsObsolete,
           PersonTypeCode,
           InvitationDtm,
           AdminRoleCode
    INTO #Actual
    FROM Person
    INNER JOIN Person_Invitee
    ON Person.PersonNo = Person_Invitee.InviteeNo
    INNER JOIN PersonAdminRole
    ON Person.PersonNo = PersonAdminRole.AdminNo;

    SELECT TOP 0 * INTO #Expected FROM #Actual;
    INSERT INTO #Expected (PersonNo, Email, EmailConfirmed, IsObsolete, PersonTypeCode, InvitationDtm,
                           AdminRoleCode)
    VALUES (@AdminNo, @Email, @EmailConfirmed, 0, @PersonTypeCode, @InvitationDtm, @AdminRoleCode);

    EXEC tSQLt.AssertEqualsTable #Expected, #Actual;
END
GO

CREATE OR ALTER PROCEDURE PersonAdminRole_Add.[Test success when adding new Person_User]
AS
BEGIN
    DECLARE @AdminNo PersonNo;
    DECLARE @AdminRoleCode AdminRoleCode = 'prs';
    DECLARE @Email Email = 'test@test.com';
    DECLARE @EmailConfirmed _Bool = 0;
    DECLARE @PersonTypeCode PersonTypeCode = 'U';
    DECLARE @PasswordHash _Text = 'foo';

    EXEC PersonAdminRole_Add_tr @AdminRoleCode = @AdminRoleCode, @AdminNo = @AdminNo OUTPUT, @Email = @Email,
         @EmailConfirmed = @EmailConfirmed, @PersonTypeCode = @PersonTypeCode, @PasswordHash = @PasswordHash;

    SELECT PersonNo,
           Email,
           EmailConfirmed,
           IsObsolete,
           PersonTypeCode,
           PasswordHash,
           AdminRoleCode
    INTO #Actual
    FROM Person
    INNER JOIN Person_User
    ON Person.PersonNo = Person_User.UserNo
    INNER JOIN PersonAdminRole
    ON Person.PersonNo = PersonAdminRole.AdminNo;

    SELECT TOP 0 * INTO #Expected FROM #Actual;
    INSERT INTO #Expected (PersonNo, Email, EmailConfirmed, IsObsolete, PersonTypeCode, PasswordHash, AdminRoleCode)
    VALUES (@AdminNo, @Email, @EmailConfirmed, 0, @PersonTypeCode, @PasswordHash, @AdminRoleCode);

    EXEC tSQLt.AssertEqualsTable #Expected, #Actual;
END
GO

CREATE OR ALTER PROCEDURE PersonAdminRole_Add.[Test success when called for existing Person]
AS
BEGIN
    DECLARE @AdminNo PersonNo = 1;
    DECLARE @AdminRoleCode AdminRoleCode = 'prs';
    DECLARE @Email Email = 'test@test.com';
    DECLARE @EmailConfirmed _Bool = 0;
    DECLARE @PersonTypeCode PersonTypeCode = 'I';

    INSERT INTO Person (PersonNo, Email, EmailConfirmed, UpdatedDtm, IsObsolete, PersonTypeCode)
    VALUES (@AdminNo, @Email, @EmailConfirmed, SYSDATETIMEOFFSET(), 0, @PersonTypeCode);

    EXEC PersonAdminRole_Add_tr @AdminRoleCode = @AdminRoleCode, @AdminNo = @AdminNo;

    SELECT AdminNo, AdminRoleCode INTO #Actual FROM PersonAdminRole;

    SELECT TOP 0 * INTO #Expected FROM #Actual;
    INSERT INTO #Expected (AdminNo, AdminRoleCode)
    VALUES (@AdminNo, @AdminRoleCode);

    EXEC tSQLt.AssertEqualsTable #Expected, #Actual;
END
GO

CREATE OR ALTER PROCEDURE PersonAdminRole_Add.[Test error with code when PersonAdminRole already exists]
AS
BEGIN
    DECLARE @AdminNo PersonNo = 1;
    DECLARE @AdminRoleCode AdminRoleCode = 'prs';

    INSERT INTO Person (PersonNo, Email, EmailConfirmed, UpdatedDtm, IsObsolete, PersonTypeCode)
    VALUES (@AdminNo, 'test@test.com', 0, SYSDATETIMEOFFSET(), 0, 'I');
    INSERT INTO PersonAdminRole (AdminNo, AdminRoleCode) VALUES (@AdminNo, @AdminRoleCode);

    EXEC tSQLt.ExpectException @ExpectedErrorNumber = 51202, @ExpectedSeverity = 16;
    EXEC PersonAdminRole_Add_tr @AdminRoleCode = @AdminRoleCode, @AdminNo = @AdminNo;
END
GO

CREATE OR ALTER PROCEDURE PersonAdminRole_Add.[Test error with code when called for Person that does not exist]
AS
BEGIN
    EXEC tSQLt.ExpectException @ExpectedErrorNumber = 51108, @ExpectedSeverity = 16;
    EXEC PersonAdminRole_Add_tr @AdminRoleCode = 'prs', @AdminNo = 7;
END
GO

CREATE OR ALTER PROCEDURE PersonAdminRole_Add.[Test error with code when AdminRole does not exist]
AS
BEGIN
    DECLARE @AdminNo PersonNo = 1;

    INSERT INTO Person (PersonNo, Email, EmailConfirmed, UpdatedDtm, IsObsolete, PersonTypeCode)
    VALUES (@AdminNo, 'test@test.com', 0, SYSDATETIMEOFFSET(), 0, 'I');

    EXEC tSQLt.ExpectException @ExpectedErrorNumber = 51201, @ExpectedSeverity = 16;
    EXEC PersonAdminRole_Add_tr @AdminRoleCode = 'foo', @AdminNo = @AdminNo;
END
GO

CREATE OR ALTER PROCEDURE PersonAdminRole_Add.[Test error with code when adding new Person with an existing Email]
AS
BEGIN
    DECLARE @Email Email = 'test@test.com';

    INSERT INTO Person (PersonNo, Email, EmailConfirmed, UpdatedDtm, IsObsolete, PersonTypeCode)
    VALUES (1, @Email, 0, SYSDATETIMEOFFSET(), 0, 'I');

    EXEC tSQLt.ExpectException @ExpectedErrorNumber = 51107, @ExpectedSeverity = 16;
    EXEC PersonAdminRole_Add_tr @AdminRoleCode = 'prs', @Email = @Email, @EmailConfirmed = 0, @PersonTypeCode = 'U',
         @PasswordHash = 'foo';
END
GO

CREATE OR ALTER PROCEDURE PersonAdminRole_Add.[Test error with code when adding new Person with invalid Email]
AS
BEGIN
    EXEC tSQLt.ExpectException @ExpectedErrorNumber = 51101, @ExpectedSeverity = 16;
    EXEC PersonAdminRole_Add_tr @AdminRoleCode = 'prs', @Email = NULL, @EmailConfirmed = 0, @PersonTypeCode = 'U',
         @PasswordHash = 'foo';
END
GO

CREATE OR ALTER PROCEDURE PersonAdminRole_Add.[Test error with code when adding new Person with NULL EmailConfirmed]
AS
BEGIN
    EXEC tSQLt.ExpectException @ExpectedErrorNumber = 51102, @ExpectedSeverity = 16;
    EXEC PersonAdminRole_Add_tr @AdminRoleCode = 'prs', @Email = 'test@test.com', @EmailConfirmed = NULL,
         @PersonTypeCode = 'U', @PasswordHash = 'foo';
END
GO

CREATE OR ALTER PROCEDURE PersonAdminRole_Add.[Test error with code when adding new Person with NULL PersonTypeCode]
AS
BEGIN
    EXEC tSQLt.ExpectException @ExpectedErrorNumber = 51103, @ExpectedSeverity = 16;
    EXEC PersonAdminRole_Add_tr @AdminRoleCode = 'prs', @Email = 'test@test.com', @EmailConfirmed = 0,
         @PersonTypeCode = NULL, @PasswordHash = 'foo';
END
GO

CREATE OR ALTER PROCEDURE PersonAdminRole_Add.[Test error with code when adding new Person with invalid PersonTypeCode]
AS
BEGIN
    EXEC tSQLt.ExpectException @ExpectedErrorNumber = 51104, @ExpectedSeverity = 16;
    EXEC PersonAdminRole_Add_tr @AdminRoleCode = 'prs', @Email = 'test@test.com', @EmailConfirmed = 0,
         @PersonTypeCode = 'X', @PasswordHash = 'foo';
END
GO

CREATE OR ALTER PROCEDURE PersonAdminRole_Add.[Test error with code when adding new Person_Invitee with NULL InvitationDtm]
AS
BEGIN
    EXEC tSQLt.ExpectException @ExpectedErrorNumber = 51105, @ExpectedSeverity = 16;
    EXEC PersonAdminRole_Add_tr @AdminRoleCode = 'prs', @Email = 'test@test.com', @EmailConfirmed = 0,
         @PersonTypeCode = 'I', @InvitationDtm = NULL;
END
GO

CREATE OR ALTER PROCEDURE PersonAdminRole_Add.[Test error with code when adding new Person_User with NULL PasswordHash]
AS
BEGIN
    EXEC tSQLt.ExpectException @ExpectedErrorNumber = 51106, @ExpectedSeverity = 16;
    EXEC PersonAdminRole_Add_tr @AdminRoleCode = 'prs', @Email = 'test@test.com', @EmailConfirmed = 0,
         @PersonTypeCode = 'U', @PasswordHash = NULL;
END
GO

-- rollback EXEC tSQLt.DropClass 'PersonAdminRole_Add_tr'