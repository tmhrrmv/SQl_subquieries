--Tema 2: SQL

--Consultas con subconsultas anidadas, JOIN's y CTE'S con operadores.

--Consulta 1 – Empleados y sus oficinas  Enunciado: Listar el código, nombre, y primer apellido de cada empleado junto con la ciudad y país de su oficina. Ordenar el resultado por ciudad y nombre.
SELECT
    e.codigo_empleado AS "codigo_del_empleado",
    e.nombre AS "Nombre_del_empleado",
    e.apellido1 AS "Primer apellido",
    (SELECT o.ciudad 
     FROM oficina o 
     WHERE o.codigo_oficina = e.codigo_oficina) AS Ciudad_de_su_oficina,
    (SELECT o.pais 
     FROM oficina o 
     WHERE o.codigo_oficina = e.codigo_oficina) AS "Pais_de_su_oficina"
FROM
    empleado e
ORDER BY
    e.nombre, Ciudad_de_su_oficina;




--Consulta 2 – Pedidos por cliente:
--Enunciado: Obtener para cada cliente (mostrando su código y nombre) la cantidad total de pedidos realizados. Se debe utilizar una subconsulta.
SELECT 
    c.codigo_cliente AS "Codigo del cliente",
    c.nombre_cliente AS "Nombre del cliente",
    (SELECT 
        COUNT(p.codigo_pedido)
    FROM pedido p
    WHERE p.codigo_cliente = c.codigo_cliente) AS "Cantidad total de pedidos"

FROM cliente c;

--Consulta 3 – Productos con margen de ganancia:

--Enunciado: Listar los productos (mostrando código, nombre y gama) junto con el cálculo del margen de ganancia (diferencia entre precio_venta y precio_proveedor).
-- Incluir solo aquellos productos con un margen mayor a 50.
     
SELECT  
    p.codigo_producto AS "Codigo del producto",
    p.nombre AS "Nombre",
    p.gama,
    (p.precio_venta - p.precio_proveedor) AS margen_ganancia
FROM producto p
WHERE (p.precio_venta - p.precio_proveedor) > 50;


    
--Consulta 4 – Pedidos entregados tarde:Enunciado: Mostrar la lista de pedidos que se entregaron con retraso (donde fecha_entrega es mayor que fecha_esperada), incluyendo el número de días de retraso y el nombre del cliente que realizó el pedido. Se debe usar un CTE.
WITH pedidos_retrasados AS (
    SELECT 
        p.codigo_pedido,
        p.fecha_entrega,
        p.fecha_esperada,
        p.codigo_cliente,
        DATEDIFF(p.fecha_entrega, p.fecha_esperada) AS dias_retraso
    FROM pedido p
    WHERE p.fecha_entrega > p.fecha_esperada
)
SELECT 
    pr.codigo_pedido,
    pr.fecha_entrega,
    pr.fecha_esperada,
    pr.dias_retraso,
    (SELECT nombre_cliente FROM cliente c WHERE c.codigo_cliente = pr.codigo_cliente) AS nombre_cliente
FROM pedidos_retrasados pr;


--Consulta 5 – Empleados por oficina: Enunciado: Listar cada oficina (mostrando su código y ciudad) junto con el total de empleados que trabajan en ella. Se debe utilizar un CTE.

WITH empleados_por_oficina AS (
    SELECT
        e.codigo_oficina,
        COUNT(e.codigo_empleado) AS total_empleados
    FROM empleado e
    WHERE e.codigo_oficina IS NOT NULL
    GROUP BY e.codigo_oficina 
)
SELECT
    o.codigo_oficina,
    o.ciudad,                                   
    (SELECT
        epo.total_empleados
     FROM empleados_por_oficina epo
     WHERE epo.codigo_oficina = o.codigo_oficina) AS total_empleados
FROM oficina o;

--Consulta 6 – Jefes y número de subordinados:Enunciado: Obtener la lista de empleados que actúan como jefes (tienen empleados a su cargo) junto con el número de subordinados que tienen y la ciudad de su oficina. Se debe usar un JOIN y un CTE.





