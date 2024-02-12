-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Retailer stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE Retailer
(
    RetailerNo RetailerNo   NOT NULL,
    VatId      VatId        NOT NULL,
    Name       RetailerName NOT NULL,
    UpdatedDtm _CurrencyDtm NOT NULL,
    IsObsolete _Bool        NOT NULL,
    CONSTRAINT UC_Retailer_PK PRIMARY KEY CLUSTERED (RetailerNo),
    CONSTRAINT U__Retailer_AK1 UNIQUE (VatId),
    CONSTRAINT U__Retailer_AK2 UNIQUE (Name),
    CONSTRAINT VatId_NotEmpty_ck CHECK (VatId != ''),
    CONSTRAINT RetailerName_NotEmpty_ck CHECK (Name != '')
);
-- rollback DROP TABLE Retailer;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:RetailerBranch stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE RetailerBranch
(
    RetailerNo RetailerNo   NOT NULL,
    BranchNo   BranchNo     NOT NULL,
    Name       BranchName   NOT NULL,
    UpdatedDtm _CurrencyDtm NOT NULL,
    IsObsolete _Bool        NOT NULL,
    CONSTRAINT UC_RetailerBranch_PK PRIMARY KEY CLUSTERED (RetailerNo, BranchNo),
    CONSTRAINT U__RetailerBranch_AK UNIQUE (RetailerNo, Name),
    CONSTRAINT Retailer_Operates_RetailerBranch_fk FOREIGN KEY (RetailerNo) REFERENCES Retailer (RetailerNo),
    CONSTRAINT RetailerBranchName_NotEmpty_ck CHECK (Name != '')
);
-- rollback DROP TABLE RetailerBranch;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:RetailerBranchAgent stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE RetailerBranchAgent
(
    RetailerNo RetailerNo   NOT NULL,
    BranchNo   BranchNo     NOT NULL,
    AgentNo    PersonNo     NOT NULL,
    UpdatedDtm _CurrencyDtm NOT NULL,
    IsObsolete _Bool        NOT NULL,
    CONSTRAINT UC_RetailerBranchAgent_PK PRIMARY KEY CLUSTERED (RetailerNo, BranchNo, AgentNo),
    CONSTRAINT RetailerBranch_Employs_RetailerBranchAgent_fk FOREIGN KEY (RetailerNo, BranchNo) REFERENCES RetailerBranch (RetailerNo, BranchNo),
    CONSTRAINT Person_IsEmployedAs_RetailerBranchAgent_fk FOREIGN KEY (AgentNo) REFERENCES Person (PersonNo)
);
-- rollback DROP TABLE RetailerBranchAgent;