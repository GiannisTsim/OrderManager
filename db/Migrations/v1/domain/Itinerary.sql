-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Itinerary stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TYPE ItineraryWeekday FROM TINYINT;
CREATE TYPE ItineraryTime FROM TIME(0);
CREATE TYPE VehicleRegistrationNo FROM NCHAR(7);
-- rollback DROP TYPE ItineraryWeekday;
-- rollback DROP TYPE ItineraryTime;
-- rollback DROP TYPE VehicleRegistrationNo;
