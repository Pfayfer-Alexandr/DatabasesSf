WITH RECURSIVE ManagerSubordinates AS (
    -- Находим всех менеджеров с подчиненными
    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID,
        COUNT(s.EmployeeID) AS DirectSubordinates
    FROM Employees e
    JOIN Roles r ON e.RoleID = r.RoleID
    LEFT JOIN Employees s ON e.EmployeeID = s.ManagerID
    WHERE r.RoleName = 'Менеджер'
    GROUP BY e.EmployeeID, e.Name, e.ManagerID, e.DepartmentID, e.RoleID
    HAVING COUNT(s.EmployeeID) > 0
),

RecursiveSubordinates AS (
    -- Базовый случай: менеджеры с прямыми подчиненными
    SELECT
        ms.EmployeeID,
        ms.Name,
        ms.ManagerID,
        ms.DepartmentID,
        ms.RoleID,
        ms.DirectSubordinates AS TotalSubordinates
    FROM ManagerSubordinates ms

    UNION ALL

    -- Рекурсивный случай: добавляем подчиненных подчиненных
    SELECT
        rs.EmployeeID,
        rs.Name,
        rs.ManagerID,
        rs.DepartmentID,
        rs.RoleID,
        rs.TotalSubordinates + COUNT(e.EmployeeID) AS TotalSubordinates
    FROM RecursiveSubordinates rs
    JOIN Employees e ON rs.EmployeeID = e.ManagerID
    GROUP BY rs.EmployeeID, rs.Name, rs.ManagerID, rs.DepartmentID, rs.RoleID, rs.TotalSubordinates
)

SELECT
    ms.EmployeeID,
    ms.Name AS EmployeeName,
    ms.ManagerID,
    d.DepartmentName,
    r.RoleName,
    STRING_AGG(DISTINCT p.ProjectName, ', ') AS ProjectNames,
    STRING_AGG(DISTINCT t.TaskName, ', ') AS TaskNames,
    MAX(ms.TotalSubordinates) AS TotalSubordinates
FROM
    RecursiveSubordinates ms
LEFT JOIN Departments d ON ms.DepartmentID = d.DepartmentID
LEFT JOIN Roles r ON ms.RoleID = r.RoleID
LEFT JOIN Projects p ON ms.DepartmentID = p.DepartmentID
LEFT JOIN Tasks t ON ms.EmployeeID = t.AssignedTo
GROUP BY
    ms.EmployeeID, ms.Name, ms.ManagerID, d.DepartmentName, r.RoleName
ORDER BY
    ms.Name;