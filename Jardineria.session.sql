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
    p.nombre AS "Nombre "
    p.gama
    










    


