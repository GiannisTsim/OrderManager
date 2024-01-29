-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Itinerary stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE Itinerary
(
    DepartureWeekday      ItineraryWeekday      NOT NULL,
    DepartureTime         ItineraryTime         NOT NULL,
    VehicleRegistrationNo VehicleRegistrationNo NOT NULL,
    OrderDeadlineWeekday  _Weekday              NOT NULL,
    OrderDeadlineTime     _Time                 NOT NULL,
    CONSTRAINT UC_Itinerary_PK PRIMARY KEY CLUSTERED (DepartureWeekday, DepartureTime, VehicleRegistrationNo),
    CONSTRAINT Itinerary_DepartureWeekday_IsValid_ck CHECK (DepartureWeekday BETWEEN 1 AND 7),
    CONSTRAINT Itinerary_OrderDeadlineWeekday_IsValid_ck CHECK (OrderDeadlineWeekday BETWEEN 1 AND 7)
);
-- rollback DROP TABLE Itinerary;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:ItineraryStop stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE ItineraryStop
(
    DepartureWeekday      ItineraryWeekday      NOT NULL,
    DepartureTime         ItineraryTime         NOT NULL,
    VehicleRegistrationNo VehicleRegistrationNo NOT NULL,
    RetailerNo            RetailerNo            NOT NULL,
    BranchNo              BranchNo              NOT NULL,
    CONSTRAINT UC_ItineraryStop_PK PRIMARY KEY CLUSTERED (DepartureWeekday, DepartureTime, VehicleRegistrationNo,
                                                          RetailerNo, BranchNo),
    CONSTRAINT RetailerBranch_Constitutes_ItineraryStop_fk FOREIGN KEY (RetailerNo, BranchNo) REFERENCES RetailerBranch (RetailerNo, BranchNo),
    CONSTRAINT Itinerary_Comprises_ItineraryStop_fk FOREIGN KEY (DepartureWeekday, DepartureTime, VehicleRegistrationNo) REFERENCES Itinerary (DepartureWeekday, DepartureTime, VehicleRegistrationNo)
);
-- rollback DROP TABLE ItineraryStop;