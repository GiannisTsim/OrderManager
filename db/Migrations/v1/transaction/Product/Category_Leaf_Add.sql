-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Category_Leaf_Add_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Category_Leaf_Add_vtr
(
    @ParentCategoryNo CategoryNo,
    @Name             CategoryName
) AS
BEGIN
    -- Error state initialization --
    DECLARE @State TINYINT = CASE WHEN @@TRANCOUNT = 0 THEN 1
                                  ELSE 2
                             END;

    -- Validation checks --
    DECLARE @ParentNodeTypeCode NodeTypeCode;
    SELECT @ParentNodeTypeCode = NodeTypeCode
    FROM Category
    WHERE CategoryNo = @ParentCategoryNo;

    IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR (53103, -1, @State, @ParentCategoryNo);
        END
    IF @ParentNodeTypeCode = 'L' AND EXISTS
        (
            SELECT 1
            FROM Product
            WHERE CategoryNo = @ParentCategoryNo
        )
        BEGIN
            RAISERROR (53104, -1, @State, @ParentCategoryNo);
        END
    IF @ParentNodeTypeCode = 'B' AND EXISTS
        (
            SELECT 1 FROM Category WHERE ParentCategoryNo = @ParentCategoryNo AND Name = @Name
        )
        BEGIN
            RAISERROR (53102, -1, @State, @ParentCategoryNo, @Name);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Category_Leaf_Add_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Category_Leaf_Add_utr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Category_Leaf_Add_utr
(
    @Name             CategoryName,
    @ParentCategoryNo CategoryNo = 0,
    @CategoryNo       CategoryNo = NULL OUTPUT
) AS
BEGIN
    -- Utility transaction integrity check --
    EXEC XactUtil_Integrity_Check;

    -- Database updates --
    IF (
           SELECT NodeTypeCode
           FROM Category
           WHERE CategoryNo = @ParentCategoryNo
       ) = 'L'
        BEGIN
            DELETE FROM Category_Leaf WHERE CategoryNo_Leaf = @ParentCategoryNo;
            INSERT INTO Category_Branch (CategoryNo_Branch) VALUES (@ParentCategoryNo);
            UPDATE Category SET NodeTypeCode = 'B' WHERE CategoryNo = @ParentCategoryNo;
        END

    SET @CategoryNo = (
                          SELECT MAX(CategoryNo) + 1
                          FROM Category
    )

    INSERT INTO Category (CategoryNo, ParentCategoryNo, Name, NodeTypeCode)
    VALUES (@CategoryNo, @ParentCategoryNo, @Name, 'L');
    INSERT INTO Category_Leaf (CategoryNo_Leaf)
    VALUES (@CategoryNo);

    -- Database updates successful --
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Category_Leaf_Add_utr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Category_Leaf_Add_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Category_Leaf_Add_tr
(
    @Name             CategoryName,
    @ParentCategoryNo CategoryNo = 0,
    @CategoryNo       CategoryNo = NULL OUTPUT
) AS
BEGIN
    DECLARE @ProcName SYSNAME = OBJECT_NAME(@@PROCID);

    ----------------------
    -- Validation block --
    ----------------------
    BEGIN TRY

        -- Transaction integrity check --
        EXEC Xact_Integrity_Check;

        -- Parameter checks --
        IF @Name IS NULL OR @Name = ''
            BEGIN
                RAISERROR (53101, -1, 1);
            END

        -- Offline constraint validation (no locks held) --
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        EXEC Category_Leaf_Add_vtr @ParentCategoryNo, @Name;

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC Category_Leaf_Add_vtr @ParentCategoryNo, @Name;

        -- Database updates --
        EXEC Category_Leaf_Add_utr @Name, @ParentCategoryNo, @CategoryNo OUTPUT;

        -- Commit --
        COMMIT TRANSACTION @ProcName;
        RETURN 0;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION @ProcName;
        THROW;
    END CATCH
END
GO
-- rollback DROP PROCEDURE Category_Leaf_Add_tr;
