SELECT Grade, IDNo, FullName, Gender, '高雄分校' as SchoolName, '03' as SiteNo
FROM SchoolKaohsiung
UNION ALL
SELECT GradeYear, StudIDNo, StudName, StudGender, '台中分校' as SchoolName, '02' as SiteNo
FROM SchoolTaichung
UNION ALL
SELECT GradeNo, StudentID, StudentName, GenderCode, '台北分校' as SchoolName, '01' as SiteNo
FROM SchoolTaipei         
ORDER BY SiteNo, Grade, IDNo