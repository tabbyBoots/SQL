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
CREATE TRIGGER [dbo].[tr_Inventory] 
   ON  [dbo].[Inventory]
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN
	SET NOCOUNT ON;

    DECLARE @Command nvarchar(50) = ''
	DECLARE @SheetCode nvarchar(50) = ''
	DECLARE @ProductNo nvarchar(50) = ''
	DECLARE @WareHouseNo nvarchar(50) = ''
	DECLARE @Id int = 0
	DECLARE @Qty int = 0

	IF EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted) SET @Command = 'INSERT'
	IF NOT EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted) SET @Command = 'DELETE'
	IF EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted) SET @Command = 'UPDATE'

	--庫存單據新增及修改
	IF (@Command = 'INSERT' OR @Command = 'UPDATE')
	BEGIN
		IF (UPDATE(SheetCode) OR UPDATE(WareHouseNo))
		BEGIN
			--庫存量減少
			IF (@Command = 'UPDATE')
			BEGIN
				SET @Id = (SELECT Id FROM deleted)
				SET @SheetCode = (SELECT SheetCode FROM deleted)
				SET @WareHouseNo = (SELECT WareHouseNo FROM deleted)

				DECLARE delete_cursor CURSOR FOR 
					SELECT ProductNo , Qty FROM InventoryDetail WHERE ParentId = @Id
				OPEN delete_cursor  
				FETCH NEXT FROM delete_cursor INTO  @ProductNo , @Qty
				WHILE @@FETCH_STATUS = 0  
				BEGIN  
					IF (@SheetCode = 'I') SET @Qty *= -1
					EXEC dbo.sp_count_inventory @WareHouseNo , @ProductNo , @Qty

					FETCH NEXT FROM delete_cursor INTO  @ProductNo , @Qty
				END
				CLOSE delete_cursor;  
				DEALLOCATE delete_cursor;
			END
			--庫存量增加
			IF (@Command = 'INSERT' OR @Command = 'UPDATE')
			BEGIN
				SET @Id = (SELECT Id FROM inserted)
				SET @SheetCode = (SELECT SheetCode FROM inserted)
				SET @WareHouseNo = (SELECT WareHouseNo FROM inserted)

				DECLARE update_cursor CURSOR FOR 
					SELECT ProductNo , Qty FROM InventoryDetail WHERE ParentId = @Id
				OPEN update_cursor  
				FETCH NEXT FROM update_cursor INTO  @ProductNo , @Qty
				WHILE @@FETCH_STATUS = 0  
				BEGIN  
					IF (@SheetCode = 'O') SET @Qty *= -1
					EXEC dbo.sp_count_inventory @WareHouseNo , @ProductNo , @Qty

					FETCH NEXT FROM update_cursor INTO  @ProductNo , @Qty
				END
				CLOSE update_cursor;  
				DEALLOCATE update_cursor;
			END
		END
	END
END
GO
