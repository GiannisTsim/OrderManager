-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:_Generic stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC sp_addmessage 50001, 16, 'Transaction cannot be called from within an open transaction.';
-- rollback EXEC sp_dropmessage 50001, 'all';

EXEC sp_addmessage 50002, 16, 'Implicit transactions are not allowed.';
-- rollback EXEC sp_dropmessage 50002, 'all';

EXEC sp_addmessage 50003, 16, 'Utility transaction must be called from within an open transaction.';
-- rollback EXEC sp_dropmessage 50003, 'all';