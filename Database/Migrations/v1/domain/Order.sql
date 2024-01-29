-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Order stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TYPE OrderTypeCode FROM CHAR(1);
CREATE TYPE OrderTypeName FROM NVARCHAR(256);
CREATE TYPE OrderStatusCode FROM CHAR(4);
CREATE TYPE OrderStatusName FROM NVARCHAR(256);
CREATE TYPE OrderNo FROM INT;
CREATE TYPE OrderDtm FROM DATETIMEOFFSET(0);
-- rollback DROP TYPE OrderTypeCode;
-- rollback DROP TYPE OrderTypeName;
-- rollback DROP TYPE OrderStatusCode;
-- rollback DROP TYPE OrderStatusName;
-- rollback DROP TYPE OrderNo;
-- rollback DROP TYPE OrderDtm;
