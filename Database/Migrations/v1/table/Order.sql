-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:OrderType stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE OrderType
(
    OrderTypeCode OrderTypeCode NOT NULL,
    Name          OrderTypeName NOT NULL,
    CONSTRAINT UC_OrderType_PK PRIMARY KEY CLUSTERED (OrderTypeCode),
    CONSTRAINT U__OrderType_AK UNIQUE (Name),
);
INSERT INTO OrderType (OrderTypeCode, Name)
VALUES ('C', 'Cart'),
       ('S', 'Submit');
-- rollback DROP TABLE OrderType;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:OrderStatus stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE OrderStatus
(
    OrderStatusCode OrderStatusCode NOT NULL,
    Name            OrderStatusName NOT NULL,
    CONSTRAINT UC_OrderStatus_PK PRIMARY KEY CLUSTERED (OrderStatusCode),
    CONSTRAINT U__OrderStatus_AK UNIQUE (Name),
);
INSERT INTO OrderStatus (OrderStatusCode, Name)
VALUES ('P', 'Pending'),
       ('C', 'Complete'),
       ('X', 'Cancelled');
-- rollback DROP TABLE OrderStatus;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Order stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE [Order]
(
    RetailerNo    RetailerNo    NOT NULL,
    BranchNo      BranchNo      NOT NULL,
    AgentNo       PersonNo      NOT NULL,
    OrderNo       OrderNo       NOT NULL,
    OrderTypeCode OrderTypeCode NOT NULL,
    UpdatedDtm    _CurrencyDtm  NOT NULL,
    CONSTRAINT UC_Order_PK PRIMARY KEY CLUSTERED (RetailerNo, BranchNo, AgentNo, OrderNo),
    CONSTRAINT RetailerBranchAgent_Places_Order_fk FOREIGN KEY (RetailerNo, BranchNo, AgentNo) REFERENCES RetailerBranchAgent (RetailerNo, BranchNo, AgentNo),
    CONSTRAINT OrderType_Discriminates_Order_fk FOREIGN KEY (OrderTypeCode) REFERENCES OrderType (OrderTypeCode)
);
-- rollback DROP TABLE [Order];


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Order_Cart stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE Order_Cart
(
    RetailerNo   RetailerNo NOT NULL,
    BranchNo     BranchNo   NOT NULL,
    AgentNo      PersonNo   NOT NULL,
    OrderNo_Cart OrderNo    NOT NULL,
    CONSTRAINT UC_OrderCart_PK PRIMARY KEY CLUSTERED (RetailerNo, BranchNo, AgentNo, OrderNo_Cart),
    CONSTRAINT UC_OrderCart_AK UNIQUE (RetailerNo, BranchNo, AgentNo),
    CONSTRAINT Order_Is_OrderCart_fk FOREIGN KEY (RetailerNo, BranchNo, AgentNo, OrderNo_Cart) REFERENCES [Order] (RetailerNo, BranchNo, AgentNo, OrderNo),
);
-- rollback DROP TABLE Order_Cart;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Order_Submit stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE Order_Submit
(
    RetailerNo      RetailerNo      NOT NULL,
    BranchNo        BranchNo        NOT NULL,
    AgentNo         PersonNo        NOT NULL,
    OrderNo_Submit  OrderNo         NOT NULL,
    OrderDtm        OrderDtm        NOT NULL,
    OrderStatusCode OrderStatusCode NOT NULL,
    CONSTRAINT UC_OrderSubmit_PK PRIMARY KEY CLUSTERED (RetailerNo, BranchNo, AgentNo, OrderNo_Submit),
    CONSTRAINT UC_OrderSubmit_AK UNIQUE (RetailerNo, BranchNo, AgentNo, OrderDtm),
    CONSTRAINT Order_Is_OrderSubmit_fk FOREIGN KEY (RetailerNo, BranchNo, AgentNo, OrderNo_Submit) REFERENCES [Order] (RetailerNo, BranchNo, AgentNo, OrderNo),
    CONSTRAINT OrderStatus_Classifies_OrderSubmit_fk FOREIGN KEY (OrderStatusCode) REFERENCES OrderStatus (OrderStatusCode)
);
-- rollback DROP TABLE Order_Submit;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:OrderItem stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE OrderItem
(
    RetailerNo  RetailerNo  NOT NULL,
    BranchNo    BranchNo    NOT NULL,
    AgentNo     PersonNo    NOT NULL,
    OrderNo     OrderNo     NOT NULL,
    ProductCode ProductCode NOT NULL,
    OfferingNo  OfferingNo  NOT NULL,
    Quantity    _IntSmall   NOT NULL,
    CONSTRAINT UC_OrderItem_PK PRIMARY KEY CLUSTERED (RetailerNo, BranchNo, AgentNo, OrderNo, ProductCode, OfferingNo),
    CONSTRAINT Order_Comprises_OrderItem_fk FOREIGN KEY (RetailerNo, BranchNo, AgentNo, OrderNo) REFERENCES [Order] (RetailerNo, BranchNo, AgentNo, OrderNo),
    CONSTRAINT ProductOffering_IsPurchasedIn_OrderItem_fk FOREIGN KEY (ProductCode, OfferingNo) REFERENCES ProductOffering (ProductCode, OfferingNo),
    CONSTRAINT OrderItem_Quantity_GT_0_ck CHECK (Quantity > 0)
);
-- rollback DROP TABLE OrderItem;
