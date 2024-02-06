-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Itinerary stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC sp_addmessage 54101, 16, 'Itinerary.DepartureWeekday cannot be null.';
-- rollback EXEC sp_dropmessage 54101, 'all';

EXEC sp_addmessage 54102, 16, 'Itinerary.DepartureWeekday must be an integer in [1,7].';
-- rollback EXEC sp_dropmessage 54102, 'all';

EXEC sp_addmessage 54103, 16, 'Itinerary.DepartureTime cannot be null.';
-- rollback EXEC sp_dropmessage 54103, 'all';

EXEC sp_addmessage 54104, 16, 'Itinerary.VehicleRegistrationNo cannot be null.';
-- rollback EXEC sp_dropmessage 54104, 'all';

EXEC sp_addmessage 54105, 16, 'Itinerary.OrderDeadlineWeekday cannot be null.';
-- rollback EXEC sp_dropmessage 54105, 'all';

EXEC sp_addmessage 54106, 16, 'Itinerary.OrderDeadlineWeekday must be an integer in [1,7].';
-- rollback EXEC sp_dropmessage 54106, 'all';

EXEC sp_addmessage 54107, 16, 'Itinerary.OrderDeadlineTime cannot be null.';
-- rollback EXEC sp_dropmessage 54107, 'all';

EXEC sp_addmessage 54108, 16,
     'Itinerary[DepartureWeekday=%d,DepartureTime=''%s'',VehicleRegistrationNo=''%s''] already exists.';
-- rollback EXEC sp_dropmessage 54108, 'all';

EXEC sp_addmessage 54109, 16,
     'Itinerary[DepartureWeekday=%d,DepartureTime=''%s'',VehicleRegistrationNo=''%s''] does not exist.';
-- rollback EXEC sp_dropmessage 54109, 'all';

EXEC sp_addmessage 54110, 16,
     'Itinerary[DepartureWeekday=%d,DepartureTime=''%s'',VehicleRegistrationNo=''%s''] cannot be deleted while being associated with an ItineraryStop.';
-- rollback EXEC sp_dropmessage 54110, 'all';

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:ItineraryStop stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC sp_addmessage 54201, 16,
     'ItineraryStop[DepartureWeekday=%d,DepartureTime=''%s'',VehicleRegistrationNo=''%s'',RetailerNo=%d,BranchNo=%d] already exists.';
-- rollback EXEC sp_dropmessage 54201, 'all';

EXEC sp_addmessage 54202, 16,
     'ItineraryStop[DepartureWeekday=%d,DepartureTime=''%s'',VehicleRegistrationNo=''%s'',RetailerNo=%d,BranchNo=%d] does not exist.';
-- rollback EXEC sp_dropmessage 54202, 'all';