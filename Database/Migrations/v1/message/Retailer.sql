-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Retailer stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC sp_addmessage 52101, 16, 'Retailer.VatId cannot be null.';
-- rollback EXEC sp_dropmessage 52101, 'all';

EXEC sp_addmessage 52102, 16, 'Retailer.Name cannot be null.';
-- rollback EXEC sp_dropmessage 52102, 'all';

EXEC sp_addmessage 52103, 16, 'Retailer[VatId=''%s''] already exists.';
-- rollback EXEC sp_dropmessage 52103, 'all';

EXEC sp_addmessage 52104, 16, 'Retailer[Name=''%s''] already exists.';
-- rollback EXEC sp_dropmessage 52104, 'all';

EXEC sp_addmessage 52105, 16, 'Retailer[RetailerNo=%d] does not exist.';
-- rollback EXEC sp_dropmessage 52105, 'all';

EXEC sp_addmessage 52106, 16, 'Retailer[RetailerNo=%d,UpdatedDtm=''%s''] currency is lost.';
-- rollback EXEC sp_dropmessage 52106, 'all';

EXEC sp_addmessage 52107, 16, 'Retailer[RetailerNo=%d] cannot be deleted while being associated with a RetailerBranch.';
-- rollback EXEC sp_dropmessage 52107, 'all';

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:RetailerBranch stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC sp_addmessage 52201, 16, 'RetailerBranch.Name cannot be null.';
-- rollback EXEC sp_dropmessage 52201, 'all';

EXEC sp_addmessage 52202, 16, 'RetailerBranch[RetailerNo=%d,Name=''%s''] already exists.';
-- rollback EXEC sp_dropmessage 52202, 'all';

EXEC sp_addmessage 52203, 16, 'RetailerBranch[RetailerNo=%d,BranchNo=%d] does not exist.';
-- rollback EXEC sp_dropmessage 52203, 'all';

EXEC sp_addmessage 52204, 16, 'RetailerBranch[RetailerNo=%d,BranchNo=%d,UpdatedDtm=''%s''] currency is lost.';
-- rollback EXEC sp_dropmessage 52204, 'all';

EXEC sp_addmessage 52205, 16,
     'RetailerBranch[RetailerNo=%d,BranchNo=%d] cannot be deleted while being associated with a RetailerBranchAgent.';
-- rollback EXEC sp_dropmessage 52205, 'all';

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:RetailerBranchAgent stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC sp_addmessage 52301, 16, 'RetailerBranchAgent[RetailerNo=%d,BranchNo=%d,AgentNo=%d] already exists.';
-- rollback EXEC sp_dropmessage 52301, 'all';

EXEC sp_addmessage 52302, 16, 'RetailerBranchAgent[RetailerNo=%d,BranchNo=%d,AgentNo=%d] does not exist.';
-- rollback EXEC sp_dropmessage 52302, 'all';

EXEC sp_addmessage 52303, 16,
     'RetailerBranchAgent[RetailerNo=%d,BranchNo=%d,AgentNo=%d,UpdatedDtm=''%s''] currency is lost.';
-- rollback EXEC sp_dropmessage 52303, 'all';

EXEC sp_addmessage 52304, 16,
     'RetailerBranchAgent[RetailerNo=%d,BranchNo=%d,AgentNo=%d] cannot be deleted while being associated with an Order.';
-- rollback EXEC sp_dropmessage 52304, 'all';