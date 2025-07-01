WITH RECURSIVE EmployeeHierarchy AS (
    -- Базовый случай: Иван Иванов (EmployeeID = 1)
    SELECT EmployeeID, Name, ManagerID, DepartmentID, RoleID
    FROM Employees
    WHERE EmployeeID = 1

    UNION ALL

    -- Рекурсивный случай: все подчиненные
    SELECT e.EmployeeID, e.Name, e.ManagerID, e.DepartmentID, e.RoleID
    FROM Employees e
    JOIN EmployeeHierarchy eh ON e.ManagerID = eh.EmployeeID
),

TaskCounts AS (
    SELECT
        AssignedTo,
        COUNT(*) AS TotalTasks
    FROM Tasks
    GROUP BY AssignedTo
),

SubordinateCounts AS (
    SELECT
        ManagerID,
        COUNT(*) AS TotalSubordinates
    FROM Employees
    GROUP BY ManagerID
)

SELECT
    eh.EmployeeID,
    eh.Name AS EmployeeName,
    eh.ManagerID,
    d.DepartmentName,
    r.RoleName,
    STRING_AGG(DISTINCT p.ProjectName, ', ') AS ProjectNames,
    STRING_AGG(DISTINCT t.TaskName, ', ') AS TaskNames,
    COALESCE(tc.TotalTasks, 0) AS TotalTasks,
    COALESCE(sc.TotalSubordinates, 0) AS TotalSubordinates
FROM
    EmployeeHierarchy eh
LEFT JOIN Departments d ON eh.DepartmentID = d.DepartmentID
LEFT JOIN Roles r ON eh.RoleID = r.RoleID
LEFT JOIN Projects p ON eh.DepartmentID = p.DepartmentID
LEFT JOIN Tasks t ON eh.EmployeeID = t.AssignedTo
LEFT JOIN TaskCounts tc ON eh.EmployeeID = tc.AssignedTo
LEFT JOIN SubordinateCounts sc ON eh.EmployeeID = sc.ManagerID
WHERE eh.EmployeeID != 1  -- Исключаем самого Ивана Иванова
GROUP BY
    eh.EmployeeID, eh.Name, eh.ManagerID, d.DepartmentName, r.RoleName, tc.TotalTasks, sc.TotalSubordinates
ORDER BY
    eh.Name;