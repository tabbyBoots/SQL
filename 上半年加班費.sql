SELECT P.DeptName AS 部門名稱, --Distinct --
(SELECT SUM(A.Amounts) FROM Overtime AS A WHERE A.DeptName = P.DeptName AND YEAR(A.SheetDate) = 2020 AND MONTH(A.SheetDate) BETWEEN 1 AND 6) AS '2020年上半年加班費',
(SELECT SUM(A.Amounts) FROM Overtime AS A WHERE A.DeptName = P.DeptName AND YEAR(A.SheetDate) = 2021 AND MONTH(A.SheetDate) BETWEEN 1 AND 6) AS '2021年上半年加班費',
(SELECT SUM(A.Amounts) FROM Overtime AS A WHERE A.DeptName = P.DeptName AND YEAR(A.SheetDate) = 2022 AND MONTH(A.SheetDate) BETWEEN 1 AND 6) AS '2022年上半年加班費'
FROM Overtime AS P 
WHERE YEAR(P.SheetDate) BETWEEN 2020 AND 2022 AND MONTH(P.SheetDate) BETWEEN 1 AND 6
GROUP BY P.DeptName 
ORDER BY 部門名稱