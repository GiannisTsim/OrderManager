-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:PersonInvitee_IsExclusive_ck stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
ALTER TABLE Person_Invitee
    ADD CONSTRAINT PersonInvitee_IsExclusive_ck CHECK (dbo.Person_ValidateExclusive_fn(InviteeNo, 'I') = 1);
-- rollback ALTER TABLE Person_Invitee DROP CONSTRAINT PersonInvitee_IsExclusive_ck;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:PersonUser_IsExclusive_ck stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
ALTER TABLE Person_User
    ADD CONSTRAINT PersonUser_IsExclusive_ck CHECK (dbo.Person_ValidateExclusive_fn(UserNo, 'U') = 1);
-- rollback ALTER TABLE Person_User DROP CONSTRAINT PersonUser_IsExclusive_ck;