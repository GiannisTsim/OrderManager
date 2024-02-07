-- liquibase formatted sql

-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Order_Submit_vtr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Order_Submit_vtr
(
    @RetailerNo   RetailerNo,
    @BranchNo     BranchNo,
    @AgentNo      PersonNo,
    @OrderNo_Cart OrderNo,
    @UpdatedDtm   _CurrencyDtm
) AS
BEGIN
    -- Error state initialization --
    DECLARE @State TINYINT = CASE WHEN @@TRANCOUNT = 0 THEN 1
                                  ELSE 2
                             END;

    -- Validation checks --
    DECLARE @CurrentUpdatedDtm _CurrencyDtm;
    SELECT @CurrentUpdatedDtm = UpdatedDtm
    FROM [Order]
    WHERE RetailerNo = @RetailerNo
      AND BranchNo = @BranchNo
      AND AgentNo = @AgentNo
      AND OrderNo = @OrderNo_Cart
      AND OrderTypeCode = 'C';

    IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR (55101, -1, @State, @RetailerNo, @BranchNo, @AgentNo, @OrderNo_Cart);
        END
    IF @CurrentUpdatedDtm != @UpdatedDtm
        BEGIN
            DECLARE @UpdatedDtmString NVARCHAR(MAX) = CONVERT(NVARCHAR, @UpdatedDtm, 127);
            RAISERROR (55102, -1, @State, @RetailerNo, @BranchNo, @AgentNo, @OrderNo_Cart, @UpdatedDtmString);
        END

    -- Validation successful--
    RETURN 0;
END
GO
-- rollback DROP PROCEDURE Order_Submit_vtr;


-- ------------------------------------------------------------------------------------------------------------------ --
-- changeset ${AUTHOR}:Order_Submit_tr stripComments:false endDelimiter:GO
-- ------------------------------------------------------------------------------------------------------------------ --
CREATE PROCEDURE Order_Submit_tr
(
    @RetailerNo   RetailerNo,
    @BranchNo     BranchNo,
    @AgentNo      PersonNo,
    @OrderNo_Cart OrderNo,
    @UpdatedDtm   _CurrencyDtm
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
    EXEC Order_Submit_vtr @RetailerNo, @BranchNo, @AgentNo, @OrderNo_Cart, @UpdatedDtm;

    -------------------
    -- Execute block --
    -------------------
    BEGIN TRY
        BEGIN TRANSACTION @ProcName;
        SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

        -- Online constraint validation (holding locks) --
        EXEC Order_Submit_vtr @RetailerNo, @BranchNo, @AgentNo, @OrderNo_Cart, @UpdatedDtm;

        -- Database updates --
        UPDATE [Order]
        SET OrderTypeCode = 'S',
            UpdatedDtm    = SYSDATETIMEOFFSET()
        WHERE RetailerNo = @RetailerNo
          AND BranchNo = @BranchNo
          AND AgentNo = @AgentNo
          AND OrderNo = @OrderNo_Cart
          AND UpdatedDtm = @UpdatedDtm;

        DELETE
        FROM Order_Cart
        WHERE RetailerNo = @RetailerNo
          AND BranchNo = @BranchNo
          AND AgentNo = @AgentNo
          AND OrderNo_Cart = @OrderNo_Cart;

        INSERT INTO Order_Submit (RetailerNo, BranchNo, AgentNo, OrderNo_Submit, OrderDtm, OrderStatusCode)
        VALUES (@RetailerNo, @BranchNo, @AgentNo, @OrderNo_Cart, SYSDATETIMEOFFSET(), 'P');

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
-- rollback DROP PROCEDURE Order_Submit_tr;
