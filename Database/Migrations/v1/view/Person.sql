-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Person_V stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE VIEW Person_V AS
SELECT Person.PersonNo,
       Email,
       EmailConfirmed,
       UpdatedDtm,
       IsObsolete,
       PersonTypeCode,
       InvitationDtm,
       PasswordHash
FROM Person
LEFT JOIN Person_Invitee
ON PersonNo = InviteeNo
LEFT JOIN Person_User
ON PersonNo = UserNo;
-- rollback DROP VIEW Person_V;