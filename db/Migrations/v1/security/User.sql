-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:WebAdmin stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE LOGIN OrderManagerWebAdmin WITH PASSWORD = '${WEB_ADMIN_PASSWORD}';
CREATE USER WebAdmin FOR LOGIN OrderManagerWebAdmin;
ALTER ROLE PersonAdmin ADD MEMBER WebAdmin;
ALTER ROLE RetailerAdmin ADD MEMBER WebAdmin;
ALTER ROLE ProductAdmin ADD MEMBER WebAdmin;
ALTER ROLE ItineraryAdmin ADD MEMBER WebAdmin;
ALTER ROLE OrderAdmin ADD MEMBER WebAdmin;
ALTER ROLE db_datareader ADD MEMBER WebAdmin;
-- rollback DROP USER WebAdmin;
-- rollback DROP LOGIN OrderManagerWebAdmin;

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:WebCustomer stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE LOGIN OrderManagerWebCustomer WITH PASSWORD = '${WEB_CUSTOMER_PASSWORD}';
CREATE USER WebCustomer FOR LOGIN OrderManagerWebCustomer;
ALTER ROLE Customer ADD MEMBER WebCustomer;
-- rollback DROP USER WebCustomer;
-- rollback DROP LOGIN OrderManagerWebCustomer;

