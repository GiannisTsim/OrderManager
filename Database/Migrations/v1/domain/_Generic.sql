-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:_Generic stripComments:false
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE TYPE NodeTypeCode FROM CHAR(1);
CREATE TYPE NodeTypeName FROM NVARCHAR(256);
CREATE TYPE _Desc FROM NVARCHAR(32);
CREATE TYPE _DescMax FROM NVARCHAR(256);
CREATE TYPE _Text FROM NVARCHAR(MAX);
CREATE TYPE _IntTiny FROM TINYINT;
CREATE TYPE _IntSmall FROM SMALLINT;
CREATE TYPE _Int FROM INT;
CREATE TYPE _IntBig FROM BIGINT;
CREATE TYPE _Bool FROM BIT NOT NULL;
CREATE TYPE _Dtm FROM DATETIMEOFFSET(0);
CREATE TYPE _CurrencyDtm FROM DATETIMEOFFSET(3);
CREATE TYPE _Weekday FROM TINYINT;
CREATE TYPE _Time FROM TIME(0);
-- rollback DROP TYPE NodeTypeCode;
-- rollback DROP TYPE NodeTypeName;
-- rollback DROP TYPE _Desc;
-- rollback DROP TYPE _DescMax;
-- rollback DROP TYPE _Text;
-- rollback DROP TYPE _IntTiny;
-- rollback DROP TYPE _IntSmall;
-- rollback DROP TYPE _Int;
-- rollback DROP TYPE _IntBig;
-- rollback DROP TYPE _Bool;
-- rollback DROP TYPE _Dtm;
-- rollback DROP TYPE _CurrencyDtm;
-- rollback DROP TYPE _Weekday;
-- rollback DROP TYPE _Time;