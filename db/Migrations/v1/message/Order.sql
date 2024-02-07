-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Order stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC sp_addmessage 55101, 16, 'Order_Cart[RetailerNo=%d,BranchNo=%d,AgentNo=%d,OrderNo_Cart=%d] does not exist.';
-- rollback EXEC sp_dropmessage 55101, 'all';

EXEC sp_addmessage 55102, 16,
     'Order[RetailerNo=%d,BranchNo=%d,AgentNo=%d,OrderNo=%d,UpdatedDtm=''%s''] currency is lost.';
-- rollback EXEC sp_dropmessage 55102, 'all';

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:OrderItem stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC sp_addmessage 55201, 16, 'OrderItem.Quantity cannot be null.';
-- rollback EXEC sp_dropmessage 55201, 'all';

EXEC sp_addmessage 55202, 16, 'OrderItem.Quantity must be greater than zero (0).';
-- rollback EXEC sp_dropmessage 55202, 'all';

EXEC sp_addmessage 55203, 16,
     'OrderItem[RetailerNo=%d,BranchNo=%d,AgentNo=%d,OrderNo=%d,ProductCode=''%s'',OfferingNo=%d] already exists.';
-- rollback EXEC sp_dropmessage 55203, 'all';

EXEC sp_addmessage 55204, 16,
     'OrderItem[RetailerNo=%d,BranchNo=%d,AgentNo=%d,OrderNo=%d,ProductCode=''%s'',OfferingNo=%d] does not exist.';
-- rollback EXEC sp_dropmessage 55204, 'all';
