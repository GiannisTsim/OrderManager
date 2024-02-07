-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Itinerary_V stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE VIEW Itinerary_V AS
SELECT DepartureWeekday,
       DepartureTime,
       VehicleRegistrationNo,
       OrderDeadlineWeekday,
       OrderDeadlineTime,
       dbo.UpcomingWeekdayTime_ToDtm_fn(DepartureWeekday, DepartureTime)         AS NextDepartureDtm,
       dbo.UpcomingWeekdayTime_ToDtm_fn(OrderDeadlineWeekday, OrderDeadlineTime) AS NextOrderDeadlineDtm
FROM Itinerary;
-- rollback DROP VIEW Itinerary_V;
