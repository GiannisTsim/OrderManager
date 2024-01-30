-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Category_Leaf_Drop_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Category_Leaf_Drop_vtr
(
    @CategoryNo CategoryNo
) AS
BEGIN
    -- Error state initialization --
    DECLARE @State TINYINT = CASE WHEN @@TRANCOUNT = 0 THEN 1
                                  ELSE 2
                             END;

    -- Validation checks --
    DECLARE @NodeTypeCode NodeTypeCode;
    SELECT @NodeTypeCode = NodeTypeCode
    FROM Category
    WHERE CategoryNo = @CategoryNo;

    IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR (53103, -1, @State, @CategoryNo);
        END
    IF @NodeTypeCode = 'L' AND EXISTS
        (
            SELECT 1
            FROM Product
            WHERE CategoryNo = @CategoryNo
        )
        BEGIN
            RAISERROR (53104, -1, @State, @CategoryNo);
        END
    IF @NodeTypeCode = 'B'
        BEGIN
            RAISERROR (53105, -1, @State, @CategoryNo)
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Category_Leaf_Drop_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Category_Leaf_Drop_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Category_Leaf_Drop_tr
(
    @CategoryNo CategoryNo
) AS
BEGIN
    DECLARE @ProcName SYSNAME = OBJECT_NAME(@@PROCID);

    ----------------------
    -- Validation block --
    ----------------------
    -- Transaction integrity check --
    EXEC Xact_Integrity_Check;

    -- Offline constraint validation (no locks held) --
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    EXEC Category_Leaf_Drop_vtr @CategoryNo;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC Category_Leaf_Drop_vtr @CategoryNo;

        -- Database updates --
        DECLARE @ParentCategoryNo CategoryNo;
        SELECT @ParentCategoryNo = ParentCategoryNo
        FROM Category
        WHERE CategoryNo = @CategoryNo;

        DELETE FROM Category_Leaf WHERE CategoryNo_Leaf = @CategoryNo;
        DELETE FROM Category WHERE CategoryNo = @CategoryNo AND NodeTypeCode = 'L';

        -- Modify parent category to leaf if it has no more subcategories (and it is not the anchor)
        IF @ParentCategoryNo != 0 AND
           NOT EXISTS
               (
                   SELECT 1
                   FROM Category
                   WHERE ParentCategoryNo = @ParentCategoryNo
               )
            BEGIN
                DELETE FROM Category_Branch WHERE CategoryNo_Branch = @ParentCategoryNo;
                INSERT INTO Category_Leaf (CategoryNo_Leaf) VALUES (@ParentCategoryNo)
            END

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
-- rollback DROP PROCEDURE Category_Leaf_Drop_tr;
