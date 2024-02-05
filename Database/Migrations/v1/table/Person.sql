-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:PersonType stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE PersonType
(
    PersonTypeCode PersonTypeCode NOT NULL,
    Name           PersonTypeName NOT NULL,
    CONSTRAINT UC_PersonType_PK PRIMARY KEY CLUSTERED (PersonTypeCode),
    CONSTRAINT U__PersonTyper_AK UNIQUE (Name)
);
INSERT INTO PersonType (PersonTypeCode, Name)
VALUES ('I', 'Invitee'),
       ('U', 'User');
-- rollback DROP TABLE PersonType;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Person stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE Person
(
    PersonNo       PersonNo       NOT NULL,
    Email          Email          NOT NULL,
    EmailConfirmed _Bool          NOT NULL,
    UpdatedDtm     _CurrencyDtm   NOT NULL,
    IsObsolete     _Bool          NOT NULL,
    PersonTypeCode PersonTypeCode NOT NULL,
    CONSTRAINT UC_Person_PK PRIMARY KEY CLUSTERED (PersonNo),
    CONSTRAINT U__Person_AK UNIQUE (Email),
    CONSTRAINT PersonType_Discriminates_Person_fk FOREIGN KEY (PersonTypeCode) REFERENCES PersonType (PersonTypeCode)
);
-- rollback DROP TABLE Person;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Person_Invitee stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE Person_Invitee
(
    InviteeNo     PersonNo NOT NULL,
    InvitationDtm _Dtm     NOT NULL,
    CONSTRAINT UC_PersonInvitee_PK PRIMARY KEY CLUSTERED (InviteeNo),
    CONSTRAINT Person_Is_PersonInvitee_fk FOREIGN KEY (InviteeNo) REFERENCES Person (PersonNo)
);
-- rollback DROP TABLE Person_Invitee;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Person_User stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE Person_User
(
    UserNo       PersonNo NOT NULL,
    PasswordHash _Text    NOT NULL,
    CONSTRAINT UC_PersonUser_PK PRIMARY KEY CLUSTERED (UserNo),
    CONSTRAINT Person_Is_PersonUser_fk FOREIGN KEY (UserNo) REFERENCES Person (PersonNo)
);
-- rollback DROP TABLE Person_User;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:AdminRole stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE AdminRole
(
    AdminRoleCode AdminRoleCode NOT NULL,
    Name          AdminRoleName NOT NULL,
    CONSTRAINT UC_AdminRole_PK PRIMARY KEY CLUSTERED (AdminRoleCode),
    CONSTRAINT U__AdminRole_AK UNIQUE (Name)
);
INSERT INTO AdminRole (AdminRoleCode, Name)
VALUES ('prs', 'Person admin'),
       ('rtl', 'Retailer admin'),
       ('prd', 'Product admin'),
       ('ord', 'Order admin'),
       ('itn', 'Itinerary admin');
-- rollback DROP TABLE AdminRole;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:PersonAdminRole stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE PersonAdminRole
(
    AdminNo       PersonNo      NOT NULL,
    AdminRoleCode AdminRoleCode NOT NULL,
    CONSTRAINT UC_PersonAdminRole_PK PRIMARY KEY CLUSTERED (AdminNo, AdminRoleCode),
    CONSTRAINT Person_Occupies_PersonAdminRole_fk FOREIGN KEY (AdminNo) REFERENCES Person (PersonNo),
    CONSTRAINT AdminRole_Enables_PersonAdminRole_fk FOREIGN KEY (AdminRoleCode) REFERENCES AdminRole (AdminRoleCode)
);
-- rollback DROP TABLE PersonAdminRole;