-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Category stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE Category
(
    CategoryNo       CategoryNo   NOT NULL,
    ParentCategoryNo CategoryNo   NOT NULL,
    Name             CategoryName NOT NULL,
    NodeTypeCode     NodeTypeCode NOT NULL,
    CONSTRAINT UC_Category_PK PRIMARY KEY (CategoryNo),
    CONSTRAINT U__Category_AK UNIQUE (ParentCategoryNo, Name),
    CONSTRAINT NodeType_Discriminates_Category_fk FOREIGN KEY (NodeTypeCode) REFERENCES NodeType (NodeTypeCode),
    CONSTRAINT CategoryName_NotEmpty_ck CHECK (Name != '')
);

CREATE TABLE Category_Branch
(
    CategoryNo_Branch CategoryNo NOT NULL,
    CONSTRAINT UC_CategoryBranch_PK PRIMARY KEY (CategoryNo_Branch),
    CONSTRAINT Category_Is_CategoryBranch_fk FOREIGN KEY (CategoryNo_Branch) REFERENCES Category (CategoryNo)
);

CREATE TABLE Category_Leaf
(
    CategoryNo_Leaf CategoryNo NOT NULL,
    CONSTRAINT UC_CategoryLeaf_PK PRIMARY KEY (CategoryNo_Leaf),
    CONSTRAINT Category_Is_CategoryLeaf_fk FOREIGN KEY (CategoryNo_Leaf) REFERENCES Category (CategoryNo)
);

-- Insert the Anchor, before any constraint that would prevent it
INSERT INTO Category (CategoryNo, ParentCategoryNo, Name, NodeTypeCode)
VALUES (0, 0, '[Anchor]', 'B');
INSERT INTO Category_Branch (CategoryNo_Branch)
VALUES (0);

-- Apply the Foreign Key constraint after the Anchor row is in place
ALTER TABLE Category
    ADD CONSTRAINT CategoryBranch_Contains_Category_fk FOREIGN KEY (ParentCategoryNo) REFERENCES Category_Branch (CategoryNo_Branch);

-- rollback ALTER TABLE Category DROP CONSTRAINT CategoryBranch_Contains_Category_fk;
-- rollback DROP TABLE Category_Branch;
-- rollback DROP TABLE Category_Leaf;
-- rollback DROP TABLE Category;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Manufacturer stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE Manufacturer
(
    ManufacturerNo ManufacturerNo   NOT NULL,
    Name           ManufacturerName NOT NULL,
    CONSTRAINT UC_Manufacturer_PK PRIMARY KEY (ManufacturerNo),
    CONSTRAINT U__Manufacturer_AK UNIQUE (Name),
    CONSTRAINT ManufacturerName_NotEmpty_ck CHECK (Name != '')
);
-- rollback DROP TABLE Manufacturer;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:ManufacturerBrand stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE ManufacturerBrand
(
    ManufacturerNo ManufacturerNo NOT NULL,
    BrandNo        BrandNo        NOT NULL,
    Name           BrandName      NOT NULL,
    CONSTRAINT UC_ManufacturerBrand_PK PRIMARY KEY (ManufacturerNo, BrandNo),
    CONSTRAINT U__ManufacturerBrand_AK UNIQUE (ManufacturerNo, Name),
    CONSTRAINT Manufacturer_Owns_ManufacturerBrand_fk FOREIGN KEY (ManufacturerNo) REFERENCES Manufacturer (ManufacturerNo),
    CONSTRAINT ManufacturerBrandName_NotEmpty_ck CHECK (Name != '')
);
-- rollback DROP TABLE ManufacturerBrand;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Product stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE Product
(
    ProductCode    ProductCode    NOT NULL,
    ManufacturerNo ManufacturerNo NOT NULL,
    BrandNo        BrandNo        NOT NULL,
    Name           ProductName    NOT NULL,
    CategoryNo     CategoryNo     NOT NULL,
    UpdatedDtm     _CurrencyDtm   NOT NULL,
    IsObsolete     _Bool          NOT NULL,
    CONSTRAINT UC_Product_PK PRIMARY KEY (ProductCode),
    CONSTRAINT U__Product_AK UNIQUE (ManufacturerNo, BrandNo, Name),
    CONSTRAINT Category_Classifies_Product_fk FOREIGN KEY (CategoryNo) REFERENCES Category_Leaf (CategoryNo_Leaf),
    CONSTRAINT ManufacturerBrand_Labels_Product_fk FOREIGN KEY (ManufacturerNo, BrandNo) REFERENCES ManufacturerBrand (ManufacturerNo, BrandNo),
    CONSTRAINT ProductCode_NotEmpty_ck CHECK (ProductCode != ''),
    CONSTRAINT ProductName_NotEmpty_ck CHECK (Name != '')
);
-- rollback DROP TABLE Product;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:OfferingType stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE OfferingType
(
    OfferingTypeCode OfferingTypeCode NOT NULL,
    Name             OfferingTypeName NOT NULL,
    CONSTRAINT UC_OfferingType_PK PRIMARY KEY (OfferingTypeCode),
    CONSTRAINT U__OfferingType_AK UNIQUE (Name)
);
INSERT INTO OfferingType (OfferingTypeCode, Name)
VALUES ('U', 'Unit'),
       ('B', 'Bundle');
-- rollback DROP TABLE OfferingType;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:BundleType stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE BundleType
(
    BundleTypeNo BundleTypeNo   NOT NULL,
    Name         BundleTypeName NOT NULL,
    CONSTRAINT UC_BundleType_PK PRIMARY KEY (BundleTypeNo),
    CONSTRAINT U__BundleType_AK UNIQUE (Name),
    CONSTRAINT BundleTypeName_NotEmpty_ck CHECK (Name != '')
);
-- rollback DROP TABLE BundleType;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:ProductOffering stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --    
CREATE TABLE ProductOffering
(
    ProductCode      ProductCode      NOT NULL,
    OfferingNo       OfferingNo       NOT NULL,
    OfferingTypeCode OfferingTypeCode NOT NULL,
    UpdatedDtm       _CurrencyDtm     NOT NULL,
    IsObsolete       _Bool            NOT NULL,
    CONSTRAINT UC_ProductOffering_PK PRIMARY KEY (ProductCode, OfferingNo),
    CONSTRAINT Product_IsOfferedAs_ProductOffering_fk FOREIGN KEY (ProductCode) REFERENCES Product (ProductCode),
    CONSTRAINT OfferingType_Discriminates_ProductOffering_fk FOREIGN KEY (OfferingTypeCode) REFERENCES OfferingType (OfferingTypeCode)
);
-- rollback DROP TABLE ProductOffering;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:ProductOffering_Unit stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE ProductOffering_Unit
(
    ProductCode     ProductCode NOT NULL,
    OfferingNo_Unit OfferingNo  NOT NULL,
    CONSTRAINT UC_ProductOfferingUnit_PK PRIMARY KEY (ProductCode, OfferingNo_Unit),
    CONSTRAINT U__ProductOfferingUnit_AK UNIQUE (ProductCode),
    CONSTRAINT ProductOffering_Is_ProductOfferingUnit_fk FOREIGN KEY (ProductCode, OfferingNo_Unit) REFERENCES ProductOffering (ProductCode, OfferingNo)
);
-- rollback DROP TABLE ProductOffering_Unit;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:ProductOffering_Bundle stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE ProductOffering_Bundle
(
    ProductCode       ProductCode     NOT NULL,
    OfferingNo_Bundle OfferingNo      NOT NULL,
    UnitCount         BundleUnitCount NOT NULL,
    BundleTypeNo      BundleTypeNo    NOT NULL,
    CONSTRAINT UC_ProductOfferingBundle_PK PRIMARY KEY (ProductCode, OfferingNo_Bundle),
    CONSTRAINT U__ProductOfferingBundle_AK1 UNIQUE (ProductCode, UnitCount),
    CONSTRAINT U__ProductOfferingBundle_AK2 UNIQUE (ProductCode, BundleTypeNo),
    CONSTRAINT ProductOffering_Is_ProductOfferingBundle_fk FOREIGN KEY (ProductCode, OfferingNo_Bundle) REFERENCES ProductOffering (ProductCode, OfferingNo),
    CONSTRAINT BundleType_Describes_ProductOfferingBundle_fk FOREIGN KEY (BundleTypeNo) REFERENCES BundleType (BundleTypeNo),
    CONSTRAINT ProductOfferingBundle_UnitCount_GT_0_ck CHECK (UnitCount > 0)
);
-- rollback DROP TABLE ProductOffering_Bundle;
