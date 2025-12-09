
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
    JOIN JerarquiaEmpleados j ON e.codigo_empleado = j.codigo_jefe    -- HEMOS HECHO ESTE CAMBIO
    WHERE j.codigo_jefe IS NOT NULL -- HEMOS HECHO ESTE CAMBIO
)


SELECT j.*
FROM JerarquiaEmpleados j
ORDER BY j.nivel, j.codigo_empleado;





--3. Contar empleados por nivel jerárquico específico
WITH RECURSIVE JerarquiaNiveles AS (
    -- Miembro ancla: empleados sin jefe
    SELECT 
        codigo_empleado,
        nombre,
        apellido1 AS "Primer apellido",
        codigo_jefe,
        1 AS nivel
    FROM empleado
    WHERE codigo_jefe IS NULL

    UNION ALL

    -- Miembro recursivo
    SELECT
        e.codigo_empleado,
        e.nombre,
        e.apellido1 AS "Primer apellido",
        e.codigo_jefe,
        j.nivel + 1 AS nivel
    FROM empleado e 
    JOIN JerarquiaNiveles j 
        ON e.codigo_jefe = j.codigo_empleado
)
SELECT 
    nivel, 
    COUNT(*) AS "Cantidad de empleados",
    GROUP_CONCAT(
        CONCAT(nombre, ' ', "Primer apellido")
        ORDER BY nombre 
        SEPARATOR ', '
    ) AS "Empleados en el Nombre"
FROM JerarquiaNiveles
GROUP BY nivel
ORDER BY nivel;


--4. Mapa jerarquico visual con Jerarquización
--5. Análisis de ventas por Jerarquías con Path completo



