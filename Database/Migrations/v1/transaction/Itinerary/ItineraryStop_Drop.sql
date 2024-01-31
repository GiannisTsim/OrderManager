-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:ItineraryStop_Drop_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE ItineraryStop_Drop_vtr
(
    @DepartureWeekday      ItineraryWeekday,
    @DepartureTime         ItineraryTime,
    @VehicleRegistrationNo VehicleRegistrationNo,
    @RetailerNo            RetailerNo,
    @BranchNo              BranchNo
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
            FROM ItineraryStop
            WHERE DepartureWeekday = @DepartureWeekday
              AND DepartureTime = @DepartureTime
              AND VehicleRegistrationNo = @VehicleRegistrationNo
              AND RetailerNo = @RetailerNo
              AND BranchNo = @BranchNo
        )
        BEGIN
            DECLARE @DepartureTimeString NVARCHAR(MAX) = CONVERT(NVARCHAR, @DepartureTime, 8);
            RAISERROR (54202, -1, @State, @DepartureWeekday, @DepartureTimeString, @VehicleRegistrationNo, @RetailerNo, @BranchNo);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE ItineraryStop_Drop_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:ItineraryStop_Drop_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE ItineraryStop_Drop_tr
(
    @DepartureWeekday      ItineraryWeekday,
    @DepartureTime         ItineraryTime,
    @VehicleRegistrationNo VehicleRegistrationNo,
    @RetailerNo            RetailerNo,
    @BranchNo              BranchNo
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
    EXEC ItineraryStop_Drop_vtr @DepartureWeekday, @DepartureTime, @VehicleRegistrationNo, @RetailerNo, @BranchNo;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC ItineraryStop_Drop_vtr @DepartureWeekday, @DepartureTime, @VehicleRegistrationNo, @RetailerNo, @BranchNo;

        -- Database updates --
        DELETE
        FROM ItineraryStop
        WHERE DepartureWeekday = @DepartureWeekday
          AND DepartureTime = @DepartureTime
          AND VehicleRegistrationNo = @VehicleRegistrationNo
          AND RetailerNo = @RetailerNo
          AND BranchNo = @BranchNo;

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
-- rollback DROP PROCEDURE ItineraryStop_Drop_tr;
