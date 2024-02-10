-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Retailer_Add_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Retailer_Add_vtr
(
    @VatId VatId,
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
            WHERE VatId = @VatId
        )
        BEGIN
            RAISERROR (52103, -1, @State, @VatId);
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
    @VatId      VatId,
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
        IF @VatId IS NULL
            BEGIN
                RAISERROR (52101, -1 , 1);
            END
        IF @Name IS NULL
            BEGIN
                RAISERROR (52102, -1 , 1);
            END

        -- Offline constraint validation (no locks held) --
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        EXEC Retailer_Add_vtr @VatId, @Name;

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
        EXEC Retailer_Add_vtr @VatId, @Name;

        -- Database updates --
        SET @RetailerNo = (
                              SELECT COALESCE(MAX(RetailerNo) + 1, 1)
                              FROM Retailer
        );
        INSERT INTO Retailer (RetailerNo, VatId, Name, UpdatedDtm, IsObsolete)
        VALUES (@RetailerNo, @VatId, @Name, SYSDATETIMEOFFSET(), 0);

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
