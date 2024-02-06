-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:OrderItem_Add_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE OrderItem_Add_vtr
(
    @RetailerNo  RetailerNo,
    @BranchNo    BranchNo,
    @AgentNo     PersonNo,
    @ProductCode ProductCode,
    @OfferingNo  OfferingNo
) AS
BEGIN
    -- Error state initialization --
    DECLARE @State TINYINT = CASE WHEN @@TRANCOUNT = 0 THEN 1
                                  ELSE 2
                             END;

    -- Validation checks --
    DECLARE @OrderNo_Cart OrderNo = (
                                        SELECT OrderNo_Cart
                                        FROM Order_Cart
                                        WHERE RetailerNo = @RetailerNo
                                          AND BranchNo = @BranchNo
                                          AND AgentNo = @AgentNo
    );

    IF @OrderNo_Cart IS NOT NULL
        BEGIN
            IF EXISTS
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
                    RAISERROR (55203, -1, @State, @RetailerNo, @BranchNo, @AgentNo, @OrderNo_Cart, @ProductCode, @OfferingNo);
                END
        END
    ELSE IF NOT EXISTS
        (
            SELECT 1
            FROM RetailerBranchAgent
            WHERE RetailerNo = @RetailerNo
              AND BranchNo = @BranchNo
              AND AgentNo = @AgentNo
        )
        BEGIN
            RAISERROR (52302, -1, @State, @RetailerNo, @BranchNo, @AgentNo);
        END

    IF NOT EXISTS
        (
            SELECT 1 FROM ProductOffering WHERE ProductCode = @ProductCode AND OfferingNo = @OfferingNo
        )
        BEGIN
            RAISERROR (53510, -1, @State, @ProductCode, @OfferingNo);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE OrderItem_Add_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:OrderItem_Add_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE OrderItem_Add_tr
(
    @RetailerNo   RetailerNo,
    @BranchNo     BranchNo,
    @AgentNo      PersonNo,
    @ProductCode  ProductCode,
    @OfferingNo   OfferingNo,
    @Quantity     _IntSmall,
    @OrderNo_Cart OrderNo = NULL OUTPUT
) AS
BEGIN
    DECLARE @ProcName SYSNAME = OBJECT_NAME(@@PROCID);

    ----------------------
    -- Validation block --
    ----------------------
    -- Transaction integrity check --
    EXEC Xact_Integrity_Check;

    -- Parameter checks --
    IF @Quantity IS NULL
        BEGIN
            RAISERROR (55201, -1, 1);
        END
    IF @Quantity <= 0
        BEGIN
            RAISERROR (55202, -1, 1);
        END

    -- Offline constraint validation (no locks held) --
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    EXEC OrderItem_Add_vtr @RetailerNo, @BranchNo, @AgentNo, @ProductCode, @OfferingNo;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC OrderItem_Add_vtr @RetailerNo, @BranchNo, @AgentNo, @ProductCode, @OfferingNo;

        -- Database updates --
        SET @OrderNo_Cart = (
                                SELECT OrderNo_Cart
                                FROM Order_Cart
                                WHERE RetailerNo = @RetailerNo
                                  AND BranchNo = @BranchNo
                                  AND AgentNo = @AgentNo
        );

        IF @OrderNo_Cart IS NULL
            BEGIN
                SET @OrderNo_Cart = COALESCE((
                                                 SELECT MAX(OrderNo) + 1
                                                 FROM [Order]
                                                 WHERE RetailerNo = @RetailerNo
                                                   AND BranchNo = @BranchNo
                                                   AND AgentNo = @AgentNo
                                             ), 1);

                INSERT INTO [Order] (RetailerNo, BranchNo, AgentNo, OrderNo, OrderTypeCode, UpdatedDtm)
                VALUES (@RetailerNo, @BranchNo, @AgentNo, @OrderNo_Cart, 'C', SYSDATETIMEOFFSET());
                INSERT INTO Order_Cart (RetailerNo, BranchNo, AgentNo, OrderNo_Cart)
                VALUES (@RetailerNo, @BranchNo, @AgentNo, @OrderNo_Cart);
            END

        INSERT INTO OrderItem (RetailerNo, BranchNo, AgentNo, OrderNo, ProductCode, OfferingNo, Quantity)
        VALUES (@RetailerNo, @BranchNo, @AgentNo, @OrderNo_Cart, @ProductCode, @OfferingNo, @Quantity);

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
-- rollback DROP PROCEDURE OrderItem_Add_tr;
