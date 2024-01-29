-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Category_Add_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Category_Add_vtr
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
-- rollback DROP PROCEDURE Category_Add_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:Category_Add_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Category_Add_tr
(
    @ParentCategoryNo CategoryNo,
    @Name             CategoryName,
    @CategoryNo       CategoryNo OUTPUT
) AS
BEGIN
    DECLARE @ProcName SYSNAME = OBJECT_NAME(@@PROCID);

    -- Set parent category to anchor when null
    SET @ParentCategoryNo = COALESCE(@ParentCategoryNo, 0);

    ----------------------
    -- Validation block --
    ----------------------
    -- Transaction integrity check --
    EXEC Xact_Integrity_Check;

    -- Parameter checks --
    IF @Name IS NULL
        BEGIN
            RAISERROR (53101, -1, 1);
        END

    -- Offline constraint validation (no locks held) --
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    EXEC Category_Add_vtr @ParentCategoryNo, @Name;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC Category_Add_vtr @ParentCategoryNo, @Name;

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
-- rollback DROP PROCEDURE Category_Add_tr;
