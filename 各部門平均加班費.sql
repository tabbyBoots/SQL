SELECT P.DeptName AS 部門, --Distinct
(SELECT SUM(A.Amounts) FROM Overtime AS A WHERE A.DeptName = P.DeptName AND YEAR(A.SheetDate) = 2022) AS 加班費,
(SELECT SUM(A.Hours) FROM Overtime AS A WHERE A.DeptName = P.DeptName AND YEAR(A.SheetDate) = 2022) AS 加班時數,
(SUM(P.Amounts)/SUM(P.Hours)) AS 平均每小時加班費
FROM Overtime AS P 
WHERE YEAR(P.SheetDate) = 2022
GROUP BY P.DeptName 
ORDER BY 加班費 DESC