-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:NodeType stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TABLE NodeType
(
    NodeTypeCode NodeTypeCode NOT NULL,
    Name         NodeTypeName NOT NULL,
    CONSTRAINT UC_NodeType_PK PRIMARY KEY CLUSTERED (NodeTypeCode),
    CONSTRAINT U__NodeType_AK UNIQUE (Name)
);
INSERT INTO NodeType (NodeTypeCode, Name)
VALUES ('B', 'Branch'),
       ('L', 'Leaf');
-- rollback DROP TABLE NodeType;