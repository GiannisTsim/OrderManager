-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Category_Modify_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Category_Modify_vtr
(
    @CategoryNo       CategoryNo,
    @ParentCategoryNo CategoryNo,
    @Name             CategoryName
) AS
BEGIN
    -- Error state initialization --
    DECLARE @State TINYINT = CASE WHEN @@TRANCOUNT = 0 THEN 1
                                  ELSE 2
                             END;

    -- Validation checks --
    IF NOT EXISTS
        (
            SELECT 1
            FROM Category
            WHERE CategoryNo = @CategoryNo
        )
        BEGIN
            RAISERROR (53103, -1, @State, @CategoryNo);
        END

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
-- rollback DROP PROCEDURE Category_Modify_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Category_Modify_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Category_Modify_tr
(
    @CategoryNo       CategoryNo,
    @Name             CategoryName,
    @ParentCategoryNo CategoryNo = 0
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
        IF @Name IS NULL
            BEGIN
                RAISERROR (53101, -1, 1);
            END

        -- Offline constraint validation (no locks held) --
        SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
        EXEC Category_Modify_vtr @CategoryNo, @ParentCategoryNo, @Name;

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
        EXEC Category_Modify_vtr @CategoryNo, @ParentCategoryNo, @Name;

        -- Database updates --
        DECLARE @PreviousParentCategoryNo CategoryNo;
        SELECT @PreviousParentCategoryNo = ParentCategoryNo
        FROM Category
        WHERE CategoryNo = @CategoryNo;

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

        UPDATE Category SET ParentCategoryNo = @ParentCategoryNo, Name = @Name WHERE CategoryNo = @CategoryNo;

        -- Modify previous parent category to leaf if it has no more subcategories (and it is not the anchor)
        IF @PreviousParentCategoryNo != 0 AND
           NOT EXISTS
               (
                   SELECT 1
                   FROM Category
                   WHERE ParentCategoryNo = @PreviousParentCategoryNo
               )
            BEGIN
                DELETE FROM Category_Branch WHERE CategoryNo_Branch = @PreviousParentCategoryNo;
                INSERT INTO Category_Leaf (CategoryNo_Leaf) VALUES (@PreviousParentCategoryNo)
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
-- rollback DROP PROCEDURE Category_Modify_tr;
