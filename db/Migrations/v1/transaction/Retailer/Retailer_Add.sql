-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Retailer_Add_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Retailer_Add_vtr
(
    @TaxId TaxId,
    @Name  RetailerName
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
            FROM Retailer
            WHERE TaxId = @TaxId
        )
        BEGIN
            RAISERROR (52103, -1, @State, @TaxId);
        END
    IF EXISTS
        (
            SELECT 1
            FROM Retailer
            WHERE Name = @Name
        )
        BEGIN
            RAISERROR (52104, -1, @State, @Name);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Retailer_Add_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Retailer_Add_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Retailer_Add_tr
(
    @TaxId      TaxId,
    @Name       RetailerName,
    @RetailerNo RetailerNo = NULL OUTPUT
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
        IF @TaxId IS NULL OR @TaxId = ''
            BEGIN
                RAISERROR (52101, -1 , 1);
            END
        IF @Name IS NULL OR @Name = ''
            BEGIN
                RAISERROR (52102, -1 , 1);
            END

        -- Offline constraint validation (no locks held) --
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        EXEC Retailer_Add_vtr @TaxId, @Name;

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
        EXEC Retailer_Add_vtr @TaxId, @Name;

        -- Database updates --
        SET @RetailerNo = (
                              SELECT COALESCE(MAX(RetailerNo) + 1, 1)
                              FROM Retailer
        );
        INSERT INTO Retailer (RetailerNo, TaxId, Name, UpdatedDtm, IsObsolete)
        VALUES (@RetailerNo, @TaxId, @Name, SYSDATETIMEOFFSET(), 0);

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
-- rollback DROP PROCEDURE Retailer_Add_tr;
