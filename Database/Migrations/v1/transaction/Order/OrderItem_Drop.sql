-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:OrderItem_Drop_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE OrderItem_Drop_vtr
(
    @RetailerNo   RetailerNo,
    @BranchNo     BranchNo,
    @AgentNo      PersonNo,
    @OrderNo_Cart OrderNo,
    @ProductCode  ProductCode,
    @OfferingNo   OfferingNo
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
            FROM Order_Cart
            WHERE RetailerNo = @RetailerNo
              AND BranchNo = @BranchNo
              AND AgentNo = @AgentNo
              AND OrderNo_Cart = @OrderNo_Cart
        )
        BEGIN
            RAISERROR (55101, -1, @State, @RetailerNo, @BranchNo, @AgentNo, @OrderNo_Cart);
        END

    IF NOT EXISTS
        (
            SELECT 1
            FROM OrderItem
            WHERE RetailerNo = @RetailerNo
              AND BranchNo = @BranchNo
              AND AgentNo = @AgentNo
              AND OrderNo = @OrderNo_Cart
              AND ProductCode = @ProductCode
              AND OfferingNo = @OfferingNo
        )
        BEGIN
            RAISERROR (55204, -1, @State, @RetailerNo, @BranchNo, @AgentNo, @OrderNo_Cart, @ProductCode, @OfferingNo);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE OrderItem_Drop_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${author}:OrderItem_Drop_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE OrderItem_Drop_tr
(
    @RetailerNo   RetailerNo,
    @BranchNo     BranchNo,
    @AgentNo      PersonNo,
    @OrderNo_Cart OrderNo,
    @ProductCode  ProductCode,
    @OfferingNo   OfferingNo
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
    EXEC OrderItem_Drop_vtr @RetailerNo, @BranchNo, @AgentNo, @OrderNo_Cart, @ProductCode, @OfferingNo;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC OrderItem_Drop_vtr @RetailerNo, @BranchNo, @AgentNo, @OrderNo_Cart, @ProductCode, @OfferingNo;

        -- Database updates --
        DELETE
        FROM OrderItem
        WHERE RetailerNo = @RetailerNo
          AND BranchNo = @BranchNo
          AND AgentNo = @AgentNo
          AND OrderNo = @OrderNo_Cart
          AND ProductCode = @ProductCode
          AND OfferingNo = @OfferingNo;

        UPDATE [Order]
        SET UpdatedDtm = SYSDATETIMEOFFSET()
        WHERE RetailerNo = @RetailerNo
          AND BranchNo = @BranchNo
          AND AgentNo = @AgentNo
          AND OrderNo = @OrderNo_Cart;
        
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
-- rollback DROP PROCEDURE OrderItem_Drop_tr;
