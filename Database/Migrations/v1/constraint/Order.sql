-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:OrderCart_IsExclusive_ck stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
ALTER TABLE Order_Cart
    ADD CONSTRAINT OrderCart_IsExclusive_ck CHECK (dbo.Order_ValidateExclusive_fn(RetailerNo,
                                                                                  BranchNo,
                                                                                  AgentNo,
                                                                                  OrderNo_Cart,
                                                                                  'C') = 1);
-- rollback ALTER TABLE Order_Cart DROP CONSTRAINT OrderCart_IsExclusive_ck;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:OrderSubmit_IsExclusive_ck stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
ALTER TABLE Order_Submit
    ADD CONSTRAINT OrderSubmit_IsExclusive_ck CHECK (dbo.Order_ValidateExclusive_fn(RetailerNo,
                                                                                    BranchNo,
                                                                                    AgentNo,
                                                                                    OrderNo_Submit,
                                                                                    'S') = 1);
-- rollback ALTER TABLE Order_Submit DROP CONSTRAINT OrderSubmit_IsExclusive_ck;