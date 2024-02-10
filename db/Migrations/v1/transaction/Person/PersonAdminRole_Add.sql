-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:PersonAdminRole_Add_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE PersonAdminRole_Add_vtr
(
    @AdminNo       PersonNo,
    @Email         Email,
    @AdminRoleCode AdminRoleCode
) AS
BEGIN
    -- Error state initialization --
    DECLARE @State TINYINT = CASE WHEN @@TRANCOUNT = 0 THEN 1
                                  ELSE 2
                             END;

    -- Validation checks --
    IF @AdminNo IS NULL
        BEGIN
            EXEC Person_Add_vtr @Email;
        END
    ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM Person
            WHERE PersonNo = @AdminNo
        )
        BEGIN
            RAISERROR (51108, -1, @State, @AdminNo);
        END

    IF EXISTS
        (
            SELECT 1
            FROM PersonAdminRole
            WHERE AdminNo = @AdminNo
              AND AdminRoleCode = @AdminRoleCode
        )
        BEGIN
            RAISERROR (51202, -1, @State, @AdminNo, @AdminRoleCode);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE PersonAdminRole_Add_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:PersonAdminRole_Add_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE PersonAdminRole_Add_tr
(
    @AdminRoleCode  AdminRoleCode,
    @AdminNo        PersonNo = NULL OUTPUT,
    @Email          Email = NULL,
    @EmailConfirmed _Bool = NULL,
    @PersonTypeCode PersonTypeCode = NULL,
    @InvitationDtm  _Dtm = NULL,
    @PasswordHash   _Text = NULL
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
        IF @AdminNo IS NULL
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
        IF NOT EXISTS
            (
                SELECT 1
                FROM AdminRole
                WHERE AdminRoleCode = @AdminRoleCode
            )
            BEGIN
                RAISERROR (51201, -1, 1, @AdminRoleCode);
            END

        -- Offline constraint validation (no locks held) --
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        EXEC PersonAdminRole_Add_vtr @AdminNo, @Email, @AdminRoleCode;

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
        EXEC PersonAdminRole_Add_vtr @AdminNo, @Email, @AdminRoleCode;

        -- Database updates --
        IF @AdminNo IS NULL
            BEGIN
                EXEC Person_Add_utr @Email, @EmailConfirmed, @PersonTypeCode, @InvitationDtm, @PasswordHash,
                     @AdminNo OUTPUT;
            END

        INSERT INTO PersonAdminRole (AdminNo, AdminRoleCode) VALUES (@AdminNo, @AdminRoleCode);

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
-- rollback DROP PROCEDURE PersonAdminRole_Add_tr;
