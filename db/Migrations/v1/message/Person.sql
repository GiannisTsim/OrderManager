-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Person stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC sp_addmessage 51101, 16, 'Person.Email cannot be null or empty.';
-- rollback EXEC sp_dropmessage 51101, 'all';

EXEC sp_addmessage 51102, 16, 'Person.EmailConfirmed cannot be null.';
-- rollback EXEC sp_dropmessage 51102, 'all';

EXEC sp_addmessage 51103, 16, 'Person.PersonTypeCode cannot be null.';
-- rollback EXEC sp_dropmessage 51103, 'all';

EXEC sp_addmessage 51104, 16, 'PersonType[PersonTypeCode=''%s''] does not exist.';
-- rollback EXEC sp_dropmessage 51104, 'all';

EXEC sp_addmessage 51105, 16, 'Person_Invitee.InvitationDtm cannot be null.';
-- rollback EXEC sp_dropmessage 51105, 'all';

EXEC sp_addmessage 51106, 16, 'Person_User.PasswordHash cannot be null.';
-- rollback EXEC sp_dropmessage 51106, 'all';

EXEC sp_addmessage 51107, 16, 'Person[Email=''%s''] already exists.';
-- rollback EXEC sp_dropmessage 51107, 'all';

EXEC sp_addmessage 51108, 16, 'Person[PersonNo=%d] does not exist.';
-- rollback EXEC sp_dropmessage 51108, 'all';

EXEC sp_addmessage 51109, 16, 'Person[PersonNo=%d,UpdatedDtm=''%s''] currency is lost.';
-- rollback EXEC sp_dropmessage 51109, 'all';

EXEC sp_addmessage 51110, 16,
     'Person[PersonNo=%d] cannot be deleted while being associated with a RetailerBranchAgent.';
-- rollback EXEC sp_dropmessage 51110, 'all';

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:PersonAdminRole stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC sp_addmessage 51201, 16, 'AdminRole[AdminRoleCode=''%s''] does not exist.';
-- rollback EXEC sp_dropmessage 51201, 'all';

EXEC sp_addmessage 51202, 16, 'PersonAdminRole[AdminNo=%d,AdminRoleCode=''%s''] already exists.';
-- rollback EXEC sp_dropmessage 51202, 'all';

EXEC sp_addmessage 51203, 16, 'PersonAdminRole[AdminNo=%d,AdminRoleCode=''%s''] does not exist.';
-- rollback EXEC sp_dropmessage 51203, 'all';