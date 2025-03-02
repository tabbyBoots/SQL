USE [demodb]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author: Johnson
-- Create date: 2022/12/15
-- Description:	
-- =============================================
CREATE TRIGGER [dbo].[tr_InventoryDetail] 
   ON  [dbo].[InventoryDetail] 
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @Command nvarchar(50) = ''
	DECLARE @ParentId int = 0
	DECLARE @Qty int = 0
	DECLARE @SheetCode nvarchar(50) = ''
	DECLARE @WarehouseNo nvarchar(50) = ''
	DECLARE @ProductNo nvarchar(50) = ''

	IF EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted) SET @Command = 'INSERT'
	IF NOT EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted) SET @Command = 'DELETE'
	IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted) SET @Command = 'UPDATE'

	--減少庫存量
	IF (@Command = 'DELETE' OR @Command = 'UPDATE')
	BEGIN
		DECLARE delete_cursor CURSOR FOR 
			SELECT ParentId , ProductNo , Qty  FROM deleted 
		OPEN delete_cursor  
		FETCH NEXT FROM delete_cursor INTO @ParentId, @ProductNo , @Qty ;  
		WHILE @@FETCH_STATUS = 0  
		BEGIN
			SET @SheetCode = (SELECT SheetCode FROM Inventory WHERE Id = @ParentId)
			SET @WarehouseNo = (SELECT WarehouseNo FROM Inventory WHERE Id = @ParentId)
			IF (@SheetCode = 'I') SET @Qty *= -1
			EXEC dbo.sp_count_inventory @WarehouseNo , @ProductNo , @Qty

			FETCH NEXT FROM delete_cursor INTO @ParentId, @ProductNo , @Qty ; 
		END
		CLOSE delete_cursor;  
		DEALLOCATE delete_cursor;  
	END
	-- 增加庫存量
	IF (@Command = 'INSERT' OR @Command = 'UPDATE')
	BEGIN
		DECLARE insert_cursor CURSOR FOR 
			SELECT ParentId , ProductNo , Qty  FROM inserted 
		OPEN insert_cursor  
		FETCH NEXT FROM insert_cursor INTO @ParentId, @ProductNo , @Qty ;  
		WHILE @@FETCH_STATUS = 0  
		BEGIN
			SET @SheetCode = (SELECT SheetCode FROM Inventory WHERE Id = @ParentId)
			SET @WarehouseNo = (SELECT WarehouseNo FROM Inventory WHERE Id = @ParentId)
			IF (@SheetCode = 'O') SET @Qty *= -1
			EXEC dbo.sp_count_inventory @WarehouseNo , @ProductNo , @Qty

			FETCH NEXT FROM insert_cursor INTO @ParentId, @ProductNo , @Qty ; 
		END
		CLOSE insert_cursor;  
		DEALLOCATE insert_cursor;
	END
END
GO
