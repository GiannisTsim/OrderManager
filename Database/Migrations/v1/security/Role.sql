-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:PersonAdmin stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE ROLE PersonAdmin;
GRANT EXECUTE ON Person_Drop_tr TO PersonAdmin;
GRANT EXECUTE ON Person_Modify_tr TO PersonAdmin;
GRANT EXECUTE ON Person_Obsolete_tr TO PersonAdmin;
GRANT EXECUTE ON Person_Restore_tr TO PersonAdmin;
GRANT EXECUTE ON PersonAdminRole_Add_tr TO PersonAdmin;
GRANT EXECUTE ON PersonAdminRole_Drop_tr TO PersonAdmin;
-- rollback DROP ROLE PersonAdmin;

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:RetailerAdmin stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE ROLE RetailerAdmin;
GRANT EXECUTE ON Retailer_Add_tr TO RetailerAdmin;
GRANT EXECUTE ON Retailer_Drop_tr TO RetailerAdmin;
GRANT EXECUTE ON Retailer_Modify_tr TO RetailerAdmin;
GRANT EXECUTE ON Retailer_Obsolete_tr TO RetailerAdmin;
GRANT EXECUTE ON Retailer_Restore_tr TO RetailerAdmin;
GRANT EXECUTE ON RetailerBranch_Add_tr TO RetailerAdmin;
GRANT EXECUTE ON RetailerBranch_Drop_tr TO RetailerAdmin;
GRANT EXECUTE ON RetailerBranch_Modify_tr TO RetailerAdmin;
GRANT EXECUTE ON RetailerBranch_Obsolete_tr TO RetailerAdmin;
GRANT EXECUTE ON RetailerBranch_Restore_tr TO RetailerAdmin;
GRANT EXECUTE ON RetailerBranchAgent_Add_tr TO RetailerAdmin;
GRANT EXECUTE ON RetailerBranchAgent_Drop_tr TO RetailerAdmin;
GRANT EXECUTE ON RetailerBranchAgent_Obsolete_tr TO RetailerAdmin;
GRANT EXECUTE ON RetailerBranchAgent_Restore_tr TO RetailerAdmin;
-- rollback DROP ROLE RetailerAdmin;

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:ProductAdmin stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE ROLE ProductAdmin;
GRANT EXECUTE ON Category_Leaf_Add_tr TO ProductAdmin;
GRANT EXECUTE ON Category_Leaf_Drop_tr TO ProductAdmin;
GRANT EXECUTE ON Category_Modify_tr TO ProductAdmin;
GRANT EXECUTE ON Manufacturer_Add_tr TO ProductAdmin;
GRANT EXECUTE ON Manufacturer_Drop_tr TO ProductAdmin;
GRANT EXECUTE ON Manufacturer_Modify_tr TO ProductAdmin;
GRANT EXECUTE ON ManufacturerBrand_Add_tr TO ProductAdmin;
GRANT EXECUTE ON ManufacturerBrand_Drop_tr TO ProductAdmin;
GRANT EXECUTE ON ManufacturerBrand_Modify_tr TO ProductAdmin;
GRANT EXECUTE ON Product_Add_tr TO ProductAdmin;
GRANT EXECUTE ON Product_Drop_tr TO ProductAdmin;
GRANT EXECUTE ON Product_Modify_tr TO ProductAdmin;
GRANT EXECUTE ON Product_Obsolete_tr TO ProductAdmin;
GRANT EXECUTE ON Product_Restore_tr TO ProductAdmin;
GRANT EXECUTE ON ProductOffering_Add_tr TO ProductAdmin;
GRANT EXECUTE ON ProductOffering_Drop_tr TO ProductAdmin;
GRANT EXECUTE ON ProductOffering_Modify_tr TO ProductAdmin;
GRANT EXECUTE ON ProductOffering_Obsolete_tr TO ProductAdmin;
GRANT EXECUTE ON ProductOffering_Restore_tr TO ProductAdmin;
-- rollback DROP ROLE ProductAdmin;

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:ItineraryAdmin stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE ROLE ItineraryAdmin;
GRANT EXECUTE ON Itinerary_Add_tr TO ItineraryAdmin;
GRANT EXECUTE ON Itinerary_Drop_tr TO ItineraryAdmin;
GRANT EXECUTE ON Itinerary_Modify_tr TO ItineraryAdmin;
GRANT EXECUTE ON ItineraryStop_Add_tr TO ItineraryAdmin;
GRANT EXECUTE ON ItineraryStop_Drop_tr TO ItineraryAdmin;
-- rollback DROP ROLE ItineraryAdmin;

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:OrderAdmin stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE ROLE OrderAdmin;
-- rollback DROP ROLE OrderAdmin;

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Customer stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE ROLE Customer;
GRANT EXECUTE ON Order_Submit_tr TO Customer;
GRANT EXECUTE ON OrderItem_Add_tr TO Customer;
GRANT EXECUTE ON OrderItem_Drop_tr TO Customer;
GRANT EXECUTE ON OrderItem_Modify_tr TO Customer;
-- rollback DROP ROLE Customer;
