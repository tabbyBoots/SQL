```SQL
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		TabbyBoots
-- Create date: 114-02-19
-- Description:	Auto Sheet Num
-- =============================================
CREATE TRIGGER tr_Purchase 
   ON  [dbo].[Purchase] 
   AFTER INSERT,DELETE,UPDATE
AS 
BEGIN

	SET NOCOUNT ON;
	--表單自動編號參數
	DECLARE @LeadCode nvarchar(50) = ''		--前置碼
	DECLARE @CycleCode nvarchar(50) = 'YMD'	--編碼週期 Y=年 YM=年月 YMD =年月日
	DECLARE @NoLength int = 3				--流水序號長度
	
	--宣告變數
	DECLARE @Command nvarchar(50) = ''  --Trigger 指令類型 (Insert , Delete , Update)
	DECLARE @Id int = 0
	DECLARE @SheetDate date				--表單日期
	DECLARE @SheetNo nvarchar(50) = ''	--表單編號
	DECLARE @FindNo nvarchar(50) = ''	--尋找編號
	DECLARE @seq int = 1				--目前最大流水序號
    -- Insert statements for trigger here

	--判斷 Trigger 指令類型
	IF (EXISTS(SELECT * FROM inserted) AND NOT EXISTS(SELECT * FROM deleted)) SET @Command = 'Insert'
	IF (NOT EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)) SET @Command = 'Delete'
	IF (EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted)) SET @Command = 'Update'

	--Trigger 指令類型為新增時才要執行自動編號
	IF (@Command = 'Insert')
	BEGIN
		--取出 Inserted 緩衝區中使用者輸入的資料及 Id
		SET @Id = (SELECT Id from inserted)
		SET @SheetDate = (SELECT SheetDate FROM inserted)
		
		--自動編號程式開始
		SET @SheetNo = @LeadCode  --表單編號一開始為前置碼
		
		--表單編號加入週期值(年 / 年月 / 年月日)
		IF (@CycleCode = 'Y') SET @SheetNo += CONVERT(varchar(4) , @SheetDate , 112) --112日期型別為YYYYMMDD
		IF (@CycleCode = 'YM') SET @SheetNo += CONVERT(varchar(6) , @SheetDate , 112)
		IF (@CycleCode = 'YMD') SET @SheetNo += CONVERT(varchar(8) , @SheetDate , 112)
		
		--到資料庫中找是否相相週期已經有編過了,
		--有的話抓出最大編號+1
		SET @FindNo = @SheetNo + '%'
		IF ( EXISTS(SELECT * FROM Purchase WHERE SheetNo LIKE @FindNo) )
		BEGIN
			SET @FindNo = (SELECT TOP 1 SheetNo FROM Purchase WHERE SheetNo LIKE @FindNo ORDER BY SheetNo DESC)
			SET @seq = CAST( RIGHT(@FindNo, @NoLength) AS int) + 1
		END

		--將最大序號加入表單編號中, 例: 000 + 3 後 = 0003 再取右邊 3 碼 = 003
		SET @SheetNo += RIGHT(REPLICATE('0', @NoLength) + CAST(@seq AS varchar), @NoLength)
		--將表單編號寫回資料表 Purchase 中
		UPDATE Purchase SET SheetNo = @SheetNo WHERE Id = @Id
		--自動編號程式結束
	END

END
GO
```