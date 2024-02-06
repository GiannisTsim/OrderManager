-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Person stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TYPE PersonTypeCode FROM CHAR(1);
CREATE TYPE PersonTypeName FROM NVARCHAR(256);
CREATE TYPE PersonNo FROM INT;
CREATE TYPE Email FROM NVARCHAR(256);
CREATE TYPE AdminRoleCode FROM NVARCHAR(4);
CREATE TYPE AdminRoleName FROM NVARCHAR(256);
-- rollback DROP TYPE PersonTypeCode;
-- rollback DROP TYPE PersonTypeName;
-- rollback DROP TYPE PersonNo;
-- rollback DROP TYPE Email;
-- rollback DROP TYPE AdminRoleCode;
-- rollback DROP TYPE AdminRoleName;