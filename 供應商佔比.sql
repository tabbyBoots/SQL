SELECT TypeName AS 類別名稱,
(SELECT COUNT(*) FROM Vendor WHERE VendorType.TypeNo = Vendor.TypeNo) AS 家數,
CAST(((CAST((SELECT COUNT(*) FROM Vendor WHERE VendorType.TypeNo = Vendor.TypeNo) AS decimal) /
CAST((SELECT COUNT(*) FROM Vendor) AS decimal))*100) AS int) AS 佔比
FROM VendorType
ORDER BY 佔比 DESC