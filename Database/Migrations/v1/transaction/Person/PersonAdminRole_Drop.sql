-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:PersonAdminRole_Drop_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE PersonAdminRole_Drop_vtr
(
    @AdminNo       PersonNo,
    @AdminRoleCode AdminRoleCode
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
            FROM PersonAdminRole
            WHERE AdminNo = @AdminNo
              AND AdminRoleCode = @AdminRoleCode
        )
        BEGIN
            RAISERROR (51203, -1, @State, @AdminNo, @AdminRoleCode);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE PersonAdminRole_Drop_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:PersonAdminRole_Drop_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE PersonAdminRole_Drop_tr
(
    @AdminNo       PersonNo,
    @AdminRoleCode AdminRoleCode
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
    EXEC PersonAdminRole_Drop_vtr @AdminNo, @AdminRoleCode;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC PersonAdminRole_Drop_vtr @AdminNo, @AdminRoleCode;

        -- Database updates --
        DELETE
        FROM PersonAdminRole
        WHERE AdminNo = @AdminNo
          AND AdminRoleCode = @AdminRoleCode;

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
-- rollback DROP PROCEDURE PersonAdminRole_Drop_tr;
