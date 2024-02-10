-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Itinerary_Drop_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Itinerary_Drop_vtr
(
    @DepartureWeekday      ItineraryWeekday,
    @DepartureTime         ItineraryTime,
    @VehicleRegistrationNo VehicleRegistrationNo
) AS
BEGIN
    -- Error state initialization --
    DECLARE @State TINYINT = CASE WHEN @@TRANCOUNT = 0 THEN 1
                                  ELSE 2
                             END;

    -- Validation checks --
    DECLARE @DepartureTimeString NVARCHAR(MAX) = CONVERT(NVARCHAR, @DepartureTime, 8);

    IF NOT EXISTS
        (
            SELECT 1
            FROM Itinerary
            WHERE DepartureWeekday = @DepartureWeekday
              AND DepartureTime = @DepartureTime
              AND VehicleRegistrationNo = @VehicleRegistrationNo
        )
        BEGIN
            RAISERROR (54109, -1, @State, @DepartureWeekday, @DepartureTimeString, @VehicleRegistrationNo);
        END

    IF EXISTS
        (
            SELECT 1
            FROM ItineraryStop
            WHERE DepartureWeekday = @DepartureWeekday
              AND DepartureTime = @DepartureTime
              AND VehicleRegistrationNo = @VehicleRegistrationNo
        )
        BEGIN
            RAISERROR (54110, -1, @State, @DepartureWeekday, @DepartureTimeString, @VehicleRegistrationNo);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Itinerary_Drop_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Itinerary_Drop_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Itinerary_Drop_tr
(
    @DepartureWeekday      ItineraryWeekday,
    @DepartureTime         ItineraryTime,
    @VehicleRegistrationNo VehicleRegistrationNo
) AS
BEGIN
    DECLARE @ProcName SYSNAME = OBJECT_NAME(@@PROCID);

    ----------------------
    -- Validation block --
    ----------------------
    BEGIN TRY
        
        -- Transaction integrity check --
        EXEC Xact_Integrity_Check;

        -- Offline constraint validation (no locks held) --
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        EXEC Itinerary_Drop_vtr @DepartureWeekday, @DepartureTime, @VehicleRegistrationNo;

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
        EXEC Itinerary_Drop_vtr @DepartureWeekday, @DepartureTime, @VehicleRegistrationNo;

        -- Database updates --
        DELETE
        FROM Itinerary
        WHERE DepartureWeekday = @DepartureWeekday
          AND DepartureTime = @DepartureTime
          AND VehicleRegistrationNo = @VehicleRegistrationNo;

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
-- rollback DROP PROCEDURE Itinerary_Drop_tr;
