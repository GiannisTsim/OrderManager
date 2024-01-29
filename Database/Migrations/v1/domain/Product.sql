-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Product stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TYPE CategoryNo FROM TINYINT;
CREATE TYPE CategoryName FROM NVARCHAR(256);
CREATE TYPE ManufacturerNo FROM TINYINT;
CREATE TYPE ManufacturerName FROM NVARCHAR(256);
CREATE TYPE BrandNo FROM TINYINT;
CREATE TYPE BrandName FROM NVARCHAR(256);
CREATE TYPE ProductCode FROM NVARCHAR(10);
CREATE TYPE ProductName FROM NVARCHAR(256);
CREATE TYPE OfferingTypeCode FROM CHAR(1);
CREATE TYPE OfferingTypeName FROM NVARCHAR(256);
CREATE TYPE OfferingNo FROM TINYINT;
CREATE TYPE BundleTypeCode FROM NVARCHAR(4);
CREATE TYPE BundleTypeName FROM NVARCHAR(256);
CREATE TYPE BundleUnitCount FROM TINYINT;
-- rollback DROP TYPE CategoryNo;
-- rollback DROP TYPE CategoryName;
-- rollback DROP TYPE ManufacturerNo;
-- rollback DROP TYPE ManufacturerName;
-- rollback DROP TYPE BrandNo;
-- rollback DROP TYPE BrandName;
-- rollback DROP TYPE ProductCode;
-- rollback DROP TYPE ProductName;
-- rollback DROP TYPE OfferingTypeCode;
-- rollback DROP TYPE OfferingTypeName;
-- rollback DROP TYPE OfferingNo;
-- rollback DROP TYPE BundleTypeCode;
-- rollback DROP TYPE BundleTypeName;
-- rollback DROP TYPE BundleUnitCount;