-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Itinerary_Modify_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Itinerary_Modify_vtr
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
    IF NOT EXISTS
        (
            SELECT 1
            FROM Itinerary
            WHERE DepartureWeekday = @DepartureWeekday
              AND DepartureTime = @DepartureTime
              AND VehicleRegistrationNo = @VehicleRegistrationNo
        )
        BEGIN
            DECLARE @DepartureTimeString NVARCHAR(MAX) = CONVERT(NVARCHAR, @DepartureTime, 8);
            RAISERROR (54109, -1, @State, @DepartureWeekday, @DepartureTimeString, @VehicleRegistrationNo);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Itinerary_Modify_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Itinerary_Modify_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Itinerary_Modify_tr
(
    @DepartureWeekday      ItineraryWeekday,
    @DepartureTime         ItineraryTime,
    @VehicleRegistrationNo VehicleRegistrationNo,
    @OrderDeadlineWeekday  ItineraryWeekday,
    @OrderDeadlineTime     ItineraryTime
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
        IF @OrderDeadlineWeekday IS NULL
            BEGIN
                RAISERROR (54105, -1, 1);
            END
        IF @OrderDeadlineWeekday < 1 OR @OrderDeadlineWeekday > 7
            BEGIN
                RAISERROR (54106, -1, 1);
            END
        IF @OrderDeadlineTime IS NULL
            BEGIN
                RAISERROR (54107, -1, 1);
            END

        -- Offline constraint validation (no locks held) --
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        EXEC Itinerary_Modify_vtr @DepartureWeekday, @DepartureTime, @VehicleRegistrationNo;

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
        EXEC Itinerary_Modify_vtr @DepartureWeekday, @DepartureTime, @VehicleRegistrationNo;

        -- Database updates --
        UPDATE Itinerary
        SET OrderDeadlineWeekday = @OrderDeadlineWeekday,
            OrderDeadlineTime    = @OrderDeadlineTime
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
-- rollback DROP PROCEDURE Itinerary_Modify_tr;
