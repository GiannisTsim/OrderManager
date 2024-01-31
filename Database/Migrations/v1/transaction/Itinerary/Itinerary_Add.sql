-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Itinerary_Add_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Itinerary_Add_vtr
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
    IF EXISTS
        (
            SELECT 1
            FROM Itinerary
            WHERE DepartureWeekday = @DepartureWeekday
              AND DepartureTime = @DepartureTime
              AND VehicleRegistrationNo = @VehicleRegistrationNo
        )
        BEGIN
            DECLARE @DepartureTimeString NVARCHAR(MAX) = CONVERT(NVARCHAR, @DepartureTime, 8);
            RAISERROR (54108, -1, @State, @DepartureWeekday, @DepartureTimeString, @VehicleRegistrationNo);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Itinerary_Add_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Itinerary_Add_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Itinerary_Add_tr
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
    -- Transaction integrity check --
    EXEC Xact_Integrity_Check;

    -- Parameter checks --
    IF @DepartureWeekday IS NULL
        BEGIN
            RAISERROR (54101, -1, 1);
        END
    IF @DepartureWeekday < 1 OR @DepartureWeekday > 7
        BEGIN
            RAISERROR (54102, -1, 1);
        END
    IF @DepartureTime IS NULL
        BEGIN
            RAISERROR (54103, -1, 1);
        END
    IF @VehicleRegistrationNo IS NULL
        BEGIN
            RAISERROR (54104, -1, 1);
        END
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
    EXEC Itinerary_Add_vtr @DepartureWeekday, @DepartureTime, @VehicleRegistrationNo;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC Itinerary_Add_vtr @DepartureWeekday, @DepartureTime, @VehicleRegistrationNo;

        -- Database updates --
        INSERT INTO Itinerary (DepartureWeekday, DepartureTime, VehicleRegistrationNo, OrderDeadlineWeekday,
                               OrderDeadlineTime)
        VALUES (@DepartureWeekday, @DepartureTime, @VehicleRegistrationNo, @OrderDeadlineWeekday, @OrderDeadlineTime);

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
-- rollback DROP PROCEDURE Itinerary_Add_tr;
