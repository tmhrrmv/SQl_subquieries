
-- 1.Jerarquía simple de un empleado específico
WITH RECURSIVE JerarquiaEmpleados AS (
    -- Miembro ancla
    SELECT 
        codigo_empleado,
        nombre,
        apellido1 AS "Primer apellido",
        codigo_jefe,
        1 AS nivel, CAST(codigo_empleado AS CHAR(100)) AS ruta
    FROM empleado
    WHERE codigo_empleado = 3

    UNION ALL

    -- Miembro recursivo
    SELECT
        e.codigo_empleado,
        e.nombre,
        e.apellido1 AS "Primer apellido",
        e.codigo_jefe,
        j.nivel + 1,
        CONCAT(
            j.nivel, 
            "->", 
            e.codigo_empleado
        )



    FROM empleado e 
    JOIN JerarquiaEmpleados j ON e.codigo_jefe = j.codigo_empleado


)

SELECT j.*
FROM JerarquiaEmpleados j
ORDER BY j.nivel, j.codigo_empleado;





--2. Encontrar la cadena de mando ascendente a partir de un empleado específico
--3. Contar empleados por nivel jerárquico específico
--4. Mapa jerarquico visual con Jerarquización
--5. Análisis de ventas por Jerarquías con Path completo




