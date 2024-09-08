-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Retailer stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TYPE RetailerNo FROM INT;
CREATE TYPE RetailerName FROM NVARCHAR(256);
CREATE TYPE TaxId FROM NVARCHAR(30);
CREATE TYPE BranchNo FROM TINYINT;
CREATE TYPE BranchName FROM NVARCHAR(256);
-- rollback DROP TYPE RetailerNo;
-- rollback DROP TYPE RetailerName;
-- rollback DROP TYPE TaxId;
-- rollback DROP TYPE BranchNo;
-- rollback DROP TYPE BranchName;
