
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

-- 4. Mapa jerarquico visual con indentacion

WITH RECURSIVE ArbolJerarquico AS (
    SELECT
        codigo_empleado,
        nombre,
        apellido1,
        codigo_jefe,
        puesto,
        1 AS nivel,
        CAST(CONCAT(SPACE(0), nombre, ' ', apellido1) AS CHAR(100)) AS estructura,
        CAST(codigo_empleado AS CHAR(100)) as ruta_jerarquica
    FROM empleado
    WHERE codigo_jefe IS NULL

    UNION ALL

    SELECT
        e.codigo_empleado,
        e.nombre,
        e.apellido1,
        e.codigo_jefe,
        e.puesto,
        (aj.nivel + 1) AS nivel,
        CAST(
            CONCAT(SPACE((aj.nivel) * 8), "┣", e.nombre, ' ', e.apellido1, ' (', e.puesto, ')') 
        AS CHAR(500)
        ) AS estructura,
        CONCAT(aj.ruta_jerarquica, '-', e.codigo_empleado) AS ruta_jerarquica
    FROM empleado e
    INNER JOIN ArbolJerarquico aj ON e.codigo_jefe = aj.codigo_empleado
)
SELECT
    aj.nivel,
    aj.estructura AS "Estructura Organizacional",
    aj.puesto,
    aj.ruta_jerarquica AS "Ruta Jerarquica"
FROM ArbolJerarquico aj
ORDER BY aj.estructura DESC;

--5. Analisis de ventas por jerarquia con path completo

WITH RECURSIVE JerarquiaVentas AS (
    SELECT e.codigo_empleado, e.nombre, e.apellido1, e.puesto, e.codigo_jefe,
        CAST(
            CONCAT(e.nombre, ' ', e.apellido1) AS CHAR(500)
        ) AS nombre_completo,
        1 AS nivel
    FROM empleado e
    WHERE EXISTS (
        SELECT 1
        FROM cliente c
        WHERE c.codigo_empleado_rep_ventas = e.codigo_empleado
    )

    UNION ALL

    SELECT e.codigo_empleado, e.nombre, e.apellido1, e.puesto, e.codigo_jefe,
        CAST(
            CONCAT(e.nombre, ' ', e.apellido1, ' <- ', j.nombre_completo)
        AS CHAR(500)),
        j.nivel + 1
    FROM empleado e
    JOIN JerarquiaVentas j ON e.codigo_empleado = j.codigo_jefe
),
ClientesPorEmpleado AS (
    SELECT codigo_empleado_rep_ventas, COUNT(*) AS total_clientes
    FROM cliente
    GROUP BY codigo_empleado_rep_ventas
)
SELECT j.nivel, j.nombre_completo AS "Cadena de Responsabilidad",
    COALESCE(c.total_clientes, 0) AS "Clientes Atendidos",

    CASE
        WHEN j.nivel = 1 THEN 'Representante'
        WHEN j.puesto LIKE '%Director%' THEN 'Supervisor'
        ELSE 'Gerencia'
    END AS "Nivel de Gestión"
FROM JerarquiaVentas j
LEFT JOIN ClientesPorEmpleado c ON j.codigo_empleado = c.codigo_empleado_rep_ventas
ORDER BY j.nivel, j.nombre_completo;




--6

WITH RECURSIVE CategoriasProductos AS (
    -- MIEMBRO ANCLA
    SELECT 
        p.codigo_producto, 
        p.nombre, 
        p.gama, 
        p.precio_venta,
        CAST(
            CONCAT(UPPER(p.gama), " -- ", p.nombre) AS CHAR(200)
        ) AS ruta_categoria,
        1 AS nivel,
        p.cantidad_en_stock
    FROM producto p

    UNION ALL

    -- Miembro recursivo
    SELECT
        c.codigo_producto,
        c.nombre,
        c.gama,
        c.precio_venta,
        CAST(
            CONCAT(
                c.ruta_categoria, " | ", 
                CASE
                    WHEN c.precio_venta < 50 THEN "Economico"
                    WHEN c.precio_venta BETWEEN 50 AND 200 THEN "Estandar"
                    WHEN c.precio_venta BETWEEN 201 AND 500 THEN "Premium"
                    ELSE "Lujo"
                END,
                " (stock ", c.cantidad_en_stock, ")"
            ) AS CHAR(500)
        ) AS ruta_categoria,
        c.nivel + 1,
        c.cantidad_en_stock
    FROM CategoriasProductos c
    WHERE c.nivel = 1
),

ResumenVentas AS (
    SELECT 
        dp.codigo_producto, 
        SUM(dp.cantidad) AS cantidad_vendida, 
        SUM(dp.cantidad * dp.precio_unidad) AS Valor_total_generado
    FROM detalle_pedido dp
    GROUP BY dp.codigo_producto
)

SELECT
    cp.nivel,
    cp.ruta_categoria AS ruta_completa,
    cp.gama,
    cp.precio_venta AS "Precio unitario",
    cp.cantidad_en_stock AS "Stock disponible",
    COALESCE(rv.cantidad_vendida, 0) AS "UNIDADES VENDIDAS TOTALES",
    COALESCE(rv.Valor_total_generado, 0) AS "VALOR TOTAL EN VENTA",
    CASE
        WHEN cp.cantidad_en_stock < 10 THEN "Stock bajo"
        WHEN cp.cantidad_en_stock BETWEEN 10 AND 50 THEN "Stock medio"
        ELSE "Stock alto"
    END AS "ESTADO DEL INVENTARIO"
FROM CategoriasProductos cp
LEFT JOIN ResumenVentas rv ON rv.codigo_producto = cp.codigo_producto
WHERE cp.nivel = 2
ORDER BY cp.gama, cp.precio_venta DESC, cp.nombre;
    
