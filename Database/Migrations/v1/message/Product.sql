-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Category stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC sp_addmessage 53101, 16, 'Category.Name cannot be null.';
-- rollback EXEC sp_dropmessage 53101, 'all';

EXEC sp_addmessage 53102, 16, 'Category[ParentCategoryNo=%d,Name=''%s''] already exists.';
-- rollback EXEC sp_dropmessage 53102, 'all';

EXEC sp_addmessage 53103, 16, 'Category[CategoryNo=%d] does not exist.';
-- rollback EXEC sp_dropmessage 53103, 'all';

EXEC sp_addmessage 53104, 16,
     'Category_Leaf[CategoryNo_Leaf=%d] cannot be deleted while being associated with a Product.';
-- rollback EXEC sp_dropmessage 53104, 'all';

EXEC sp_addmessage 53105, 16,
     'Category_Branch[CategoryNo_Branch=%d] cannot be deleted.';
-- rollback EXEC sp_dropmessage 53105, 'all';

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Manufacturer stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC sp_addmessage 53201, 16, '';
-- rollback EXEC sp_dropmessage 53201, 'all';


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Product stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
EXEC sp_addmessage 53301, 16, '';
-- rollback EXEC sp_dropmessage 53301, 'all';
