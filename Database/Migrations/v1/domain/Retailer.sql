-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Retailer stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TYPE RetailerNo FROM INT;
CREATE TYPE RetailerName FROM NVARCHAR(256);
CREATE TYPE VatId FROM NVARCHAR(30);
CREATE TYPE BranchNo FROM TINYINT;
CREATE TYPE BranchName FROM NVARCHAR(256);
-- rollback DROP TYPE RetailerNo;
-- rollback DROP TYPE RetailerName;
-- rollback DROP TYPE VatId;
-- rollback DROP TYPE BranchNo;
-- rollback DROP TYPE BranchName;
