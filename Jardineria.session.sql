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
WITH subordinados_por_jefe AS (
    SELECT 
        e.codigo_jefe,
        COUNT(e.codigo_empleado) AS num_subordinados
    FROM empleado e
    WHERE e.codigo_jefe IS NOT NULL
    GROUP BY e.codigo_jefe
)
SELECT 
    e.codigo_empleado AS "Codigo del jefe",
    e.nombre AS "Nombre del jefe",
    e.apellido1 AS "Primer apellido",
    (SELECT spj.num_subordinados 
     FROM subordinados_por_jefe spj 
     WHERE spj.codigo_jefe = e.codigo_empleado) AS "Numero de subordinados",
    (SELECT o.ciudad 
     FROM oficina o 
     WHERE o.codigo_oficina = e.codigo_oficina) AS "Ciudad de su oficina"
FROM empleado e
WHERE e.codigo_empleado IN (
    SELECT DISTINCT codigo_jefe 
    FROM empleado 
    WHERE codigo_jefe IS NOT NULL
)
ORDER BY "Numero de subordinados" DESC, e.apellido1;


--Consulta 7 – Totales de pedidos y pagos por cliente:Enunciado: Para cada cliente, calcular el total monetario de 
--sus pedidos (sumando el valor de cada detalle de pedido) y el total de pagos realizados, mostrando además la diferencia entre ambos totales. Se deben emplear un CTE y un  JOIN.

WITH totales_pedidos AS (
    SELECT 
        p.codigo_cliente,
        SUM(dp.cantidad * dp.precio_unidad) AS total_pedidos
    FROM pedido p
    INNER JOIN detalle_pedido dp ON p.codigo_pedido = dp.codigo_pedido
    GROUP BY p.codigo_cliente
),
totales_pagos AS (
    SELECT 
        pg.codigo_cliente,
        SUM(pg.total) AS total_pagos
    FROM pago pg
    GROUP BY pg.codigo_cliente
)
SELECT 
    c.codigo_cliente AS "Codigo del cliente",
    c.nombre_cliente AS "Nombre del cliente",
    tp.total_pedidos AS "Total pedidos",
    tpg.total_pagos AS "Total pagos",
    (tp.total_pedidos - tpg.total_pagos) AS "Diferencia"
FROM cliente c
INNER JOIN totales_pedidos tp ON c.codigo_cliente = tp.codigo_cliente
INNER JOIN totales_pagos tpg ON c.codigo_cliente = tpg.codigo_cliente
ORDER BY c.nombre_cliente;

--Consulta 8 – Productos más pedidos y total de ventas:Enunciado: Listar los productos que han sido pedidos en cantidad superior a 10 unidades (suma de las cantidades de la tabla detalle_pedido) y mostrar, además de su gama, el total de ventas (calculado como precio_unidad multiplicado por cantidad). Se debe utilizar un CTE.

WITH ventas_productos AS (
    SELECT 
        dp.codigo_producto,
        SUM(dp.cantidad) AS cantidad_total,
        SUM(dp.cantidad * dp.precio_unidad) AS total_ventas
    FROM detalle_pedido dp
    GROUP BY dp.codigo_producto
    HAVING SUM(dp.cantidad) > 10
)
SELECT 
    p.codigo_producto AS "Codigo del producto",
    p.nombre AS "Nombre del producto",
    p.gama AS "Gama",
    (SELECT vp.cantidad_total 
     FROM ventas_productos vp 
     WHERE vp.codigo_producto = p.codigo_producto) AS "Cantidad total pedida",
    (SELECT vp.total_ventas 
     FROM ventas_productos vp 
     WHERE vp.codigo_producto = p.codigo_producto) AS "Total ventas"
FROM producto p
WHERE p.codigo_producto IN (
    SELECT codigo_producto 
    FROM ventas_productos
)
ORDER BY "Total ventas" DESC, p.nombre;

--Consulta 9 – Tiempo promedio de entrega por proveedor:Enunciado: Crear una vista final que combine información de pedidos, clientes y empleados (usando el representante de ventas de cada cliente) para calcular el tiempo promedio (en días) entre fecha_pedido y fecha_entrega para cada proveedor, considerando solo los pedidos que ya fueron entregados.
WITH pedidos_entregados AS (
    SELECT 
        p.codigo_pedido,
        p.codigo_cliente,
        p.fecha_pedido,
        p.fecha_entrega,
        DATEDIFF(p.fecha_entrega, p.fecha_pedido) AS dias_entrega
    FROM pedido p
    WHERE p.fecha_entrega IS NOT NULL
),
productos_pedidos AS (
    SELECT 
        dp.codigo_pedido,
        dp.codigo_producto
    FROM detalle_pedido dp
),
tiempo_por_proveedor AS (
    SELECT 
        prod.proveedor,
        AVG(pe.dias_entrega) AS tiempo_promedio_entrega,
        COUNT(DISTINCT pe.codigo_pedido) AS total_pedidos
    FROM producto prod
    INNER JOIN productos_pedidos pp ON prod.codigo_producto = pp.codigo_producto
    INNER JOIN pedidos_entregados pe ON pp.codigo_pedido = pe.codigo_pedido
    WHERE prod.proveedor IS NOT NULL
    GROUP BY prod.proveedor
)
SELECT 
    tpp.proveedor AS "Proveedor",
    tpp.tiempo_promedio_entrega AS "Tiempo promedio de entrega (dias)",
    tpp.total_pedidos AS "Total de pedidos entregados",
    (SELECT COUNT(DISTINCT prod.codigo_producto)
     FROM producto prod
     WHERE prod.proveedor = tpp.proveedor) AS "Productos del proveedor"
FROM tiempo_por_proveedor tpp
ORDER BY "Tiempo promedio de entrega (dias)" ASC;


--Consulta 10 – Clientes con límite de crédito bajo:
--Enunciado: Listar la información de los clientes cuyo límite de crédito es menor que el promedio del límite de crédito de todos los clientes en su mismo país. Se debe utilizar una subconsulta correlacionada.

SELECT 
    c.codigo_cliente AS "Codigo del cliente",
    c.nombre_cliente AS "Nombre del cliente",
    c.pais AS "Pais",
    c.limite_credito AS "Limite de credito",
    (SELECT AVG(c2.limite_credito)
     FROM cliente c2
     WHERE c2.pais = c.pais
       AND c2.limite_credito IS NOT NULL) AS "Promedio del pais"
FROM cliente c
WHERE c.limite_credito IS NOT NULL
  AND c.limite_credito < (
      SELECT AVG(c3.limite_credito)
      FROM cliente c3
      WHERE c3.pais = c.pais
        AND c3.limite_credito IS NOT NULL
  )
ORDER BY c.pais, c.limite_credito;

--Consulta 11 – Reporte por oficina de ventas a tiempo:

--Enunciado: Generar un reporte que para cada oficina muestre el total de ventas, el total de pedidos y el promedio de ventas por pedido. Las ventas se calculan como la suma de (precio_unidad multiplicado por cantidad) de los detalles de pedido, considerando solo aquellos pedidos que fueron entregados a tiempo (donde fecha_entrega es menor o igual que fecha_esperada). Se deben usar múltiples CTE’s.

WITH pedidos_a_tiempo AS (
    SELECT 
        p.codigo_pedido,
        p.codigo_cliente
    FROM pedido p
    WHERE p.fecha_entrega IS NOT NULL
      AND p.fecha_entrega <= p.fecha_esperada
),
ventas_por_pedido AS (
    SELECT 
        pat.codigo_pedido,
        pat.codigo_cliente,
        SUM(dp.cantidad * dp.precio_unidad) AS total_venta_pedido
    FROM pedidos_a_tiempo pat
    INNER JOIN detalle_pedido dp ON pat.codigo_pedido = dp.codigo_pedido
    GROUP BY pat.codigo_pedido, pat.codigo_cliente
),
ventas_por_cliente AS (
    SELECT 
        vpp.codigo_cliente,
        SUM(vpp.total_venta_pedido) AS total_ventas,
        COUNT(vpp.codigo_pedido) AS total_pedidos,
        AVG(vpp.total_venta_pedido) AS promedio_venta_pedido
    FROM ventas_por_pedido vpp
    GROUP BY vpp.codigo_cliente
),
ventas_por_oficina AS (
    SELECT 
        e.codigo_oficina,
        SUM(vpc.total_ventas) AS total_ventas_oficina,
        SUM(vpc.total_pedidos) AS total_pedidos_oficina,
        AVG(vpc.promedio_venta_pedido) AS promedio_venta_pedido_oficina
    FROM ventas_por_cliente vpc
    INNER JOIN cliente c ON vpc.codigo_cliente = c.codigo_cliente
    INNER JOIN empleado e ON c.codigo_empleado_rep_ventas = e.codigo_empleado
    GROUP BY e.codigo_oficina
)
SELECT 
    o.codigo_oficina AS "Codigo de oficina",
    o.ciudad AS "Ciudad",
    o.pais AS "Pais",
    (SELECT vpo.total_ventas_oficina 
     FROM ventas_por_oficina vpo 
     WHERE vpo.codigo_oficina = o.codigo_oficina) AS "Total ventas",
    (SELECT vpo.total_pedidos_oficina 
     FROM ventas_por_oficina vpo 
     WHERE vpo.codigo_oficina = o.codigo_oficina) AS "Total pedidos",
    ROUND((SELECT vpo.promedio_venta_pedido_oficina 
           FROM ventas_por_oficina vpo 
           WHERE vpo.codigo_oficina = o.codigo_oficina), 2) AS "Promedio venta por pedido"
FROM oficina o
WHERE o.codigo_oficina IN (SELECT codigo_oficina FROM ventas_por_oficina)
ORDER BY "Total ventas" DESC, o.ciudad;

--Consulta 12 – Ranking de productos por margen en cada gama:

--Enunciado: Listar, para cada gama de producto, los 5 productos con mayor margen de ganancia promedio (calculado como la diferencia entre precio_venta y precio_proveedor). Se debe utilizar un CTE.
WITH productos_con_margen AS (
    SELECT 
        p.codigo_producto,
        p.nombre,
        p.gama,
        (p.precio_venta - p.precio_proveedor) AS margen_ganancia
    FROM producto p
    WHERE p.precio_proveedor IS NOT NULL
),
ranking_por_gama AS (
    SELECT 
        pcm.codigo_producto,
        pcm.nombre,
        pcm.gama,
        pcm.margen_ganancia,
        (SELECT COUNT(*) + 1
         FROM productos_con_margen pcm2
         WHERE pcm2.gama = pcm.gama
           AND pcm2.margen_ganancia > pcm.margen_ganancia) AS ranking
    FROM productos_con_margen pcm
)
SELECT 
    rpg.gama AS "Gama",
    rpg.codigo_producto AS "Codigo del producto",
    rpg.nombre AS "Nombre del producto",
    rpg.margen_ganancia AS "Margen de ganancia",
    rpg.ranking AS "Posicion"
FROM ranking_por_gama rpg
WHERE rpg.ranking <= 5
ORDER BY rpg.gama, rpg.ranking;


--Consulta 13 – Ranking de clientes por índice de actividad:

--Enunciado: Generar un ranking de clientes basado en su actividad, donde se sume el total de pedidos y el total de pagos (aplicando una ponderación, por ejemplo, 0.6 para pedidos y 0.4 para pagos) para calcular un “índice de actividad”. Mostrar solo aquellos clientes cuyo índice supere un valor específico (por ejemplo, 5). Se deben emplear subconsultas y JOIN’s.



WITH total_pedidos_cliente AS (
    SELECT 
        p.codigo_cliente,
        COUNT(p.codigo_pedido) AS total_pedidos
    FROM pedido p
    GROUP BY p.codigo_cliente
),
total_pagos_cliente AS (
    SELECT 
        pg.codigo_cliente,
        COUNT(pg.id_transaccion) AS total_pagos
    FROM pago pg
    GROUP BY pg.codigo_cliente
),
calculo_indice AS (
    SELECT 
        c.codigo_cliente,
        c.nombre_cliente,
        c.ciudad,
        c.pais,
        (tpc.total_pedidos * 0.6) AS ponderacion_pedidos,
        (tpgc.total_pagos * 0.4) AS ponderacion_pagos,
        ((tpc.total_pedidos * 0.6) + (tpgc.total_pagos * 0.4)) AS indice_actividad
    FROM cliente c
    LEFT JOIN total_pedidos_cliente tpc ON c.codigo_cliente = tpc.codigo_cliente
    LEFT JOIN total_pagos_cliente tpgc ON c.codigo_cliente = tpgc.codigo_cliente
    WHERE tpc.total_pedidos IS NOT NULL OR tpgc.total_pagos IS NOT NULL
)
SELECT 
    ci.codigo_cliente AS "Codigo del cliente",
    ci.nombre_cliente AS "Nombre del cliente",
    ci.ciudad AS "Ciudad",
    ci.pais AS "Pais",
    (SELECT tpc.total_pedidos 
     FROM total_pedidos_cliente tpc 
     WHERE tpc.codigo_cliente = ci.codigo_cliente) AS "Total pedidos",
    (SELECT tpgc.total_pagos 
     FROM total_pagos_cliente tpgc 
     WHERE tpgc.codigo_cliente = ci.codigo_cliente) AS "Total pagos",
    ci.indice_actividad AS "Indice de actividad"
FROM calculo_indice ci
WHERE ci.indice_actividad > 5
ORDER BY "Indice de actividad" DESC;


--Consulta 14 – Diferencia entre primer y último pedido por empleado:

--Enunciado: Identificar los empleados que, como representantes de ventas, tienen una diferencia mayor a 5 días entre el primer pedido asignado y el último pedido asignado. Se debe utilizar un CTE y funciones de agregación en varias etapas.

WITH pedidos_por_empleado AS (
    SELECT 
        c.codigo_empleado_rep_ventas,
        MIN(p.fecha_pedido) AS primer_pedido,
        MAX(p.fecha_pedido) AS ultimo_pedido,
        DATEDIFF(MAX(p.fecha_pedido), MIN(p.fecha_pedido)) AS dias_diferencia
    FROM pedido p
    INNER JOIN cliente c ON p.codigo_cliente = c.codigo_cliente
    WHERE c.codigo_empleado_rep_ventas IS NOT NULL
    GROUP BY c.codigo_empleado_rep_ventas
    HAVING DATEDIFF(MAX(p.fecha_pedido), MIN(p.fecha_pedido)) > 5
)
SELECT 
    e.codigo_empleado AS "Codigo del empleado",
    e.nombre AS "Nombre",
    e.apellido1 AS "Primer apellido",
    e.puesto AS "Puesto",
    ppe.primer_pedido AS "Primer pedido",
    ppe.ultimo_pedido AS "Ultimo pedido",
    ppe.dias_diferencia AS "Dias de diferencia"
FROM empleado e
INNER JOIN pedidos_por_empleado ppe ON e.codigo_empleado = ppe.codigo_empleado_rep_ventas
ORDER BY ppe.dias_diferencia DESC;



--Consulta 15 – Vista consolidada de la base de datos:

--Enunciado: Diseñar una consulta compleja que genere una vista final consolidada con la información de todas las tablas: oficina, empleado, cliente, pedido, producto, detalle_pedido y pago. La vista deberá incluir cálculos de márgenes, diferencias en fechas (por ejemplo, días de entrega) y totales por categorías (como ventas totales por pedido). Se deben emplear múltiples CTE’s, subconsultas, JOIN’s y operaciones de tratamiento de datos.

WITH totales_por_pedido AS (
    SELECT 
        dp.codigo_pedido,
        SUM(dp.cantidad * dp.precio_unidad) AS total_venta_pedido,
        SUM(dp.cantidad) AS cantidad_total_productos,
        COUNT(DISTINCT dp.codigo_producto) AS variedad_productos
    FROM detalle_pedido dp
    GROUP BY dp.codigo_pedido
),
margenes_por_pedido AS (
    SELECT 
        dp.codigo_pedido,
        SUM(dp.cantidad * (dp.precio_unidad - (SELECT prod.precio_proveedor 
                                                 FROM producto prod 
                                                 WHERE prod.codigo_producto = dp.codigo_producto))) AS margen_total_pedido       --
    FROM detalle_pedido dp
    GROUP BY dp.codigo_pedido
),
pagos_por_cliente AS (
    SELECT 
        pg.codigo_cliente,
        SUM(pg.total) AS total_pagado,
        COUNT(pg.id_transaccion) AS numero_pagos                   
    FROM pago pg
    GROUP BY pg.codigo_cliente                                           
),
metricas_pedido AS (
    SELECT 
        p.codigo_pedido,
        p.codigo_cliente,
        p.fecha_pedido,
        p.fecha_esperada,
        p.fecha_entrega,
        p.estado,
        CASE 
            WHEN p.fecha_entrega IS NOT NULL 
            THEN DATEDIFF(p.fecha_entrega, p.fecha_pedido)
            ELSE NULL
        END AS dias_procesamiento,
        CASE 
            WHEN p.fecha_entrega IS NOT NULL AND p.fecha_esperada IS NOT NULL
            THEN DATEDIFF(p.fecha_entrega, p.fecha_esperada)
            ELSE NULL
        END AS dias_retraso_adelanto
    FROM pedido p                                                           --
)
SELECT 
    o.codigo_oficina AS "Codigo oficina",
    o.ciudad AS "Ciudad oficina",
    o.pais AS "Pais oficina",
    e.codigo_empleado AS "Codigo empleado",
    CONCAT(e.nombre, ' ', e.apellido1) AS "Nombre empleado",
    e.puesto AS "Puesto",
    c.codigo_cliente AS "Codigo cliente",
    c.nombre_cliente AS "Nombre cliente",
    c.ciudad AS "Ciudad cliente",
    c.pais AS "Pais cliente",
    c.limite_credito AS "Limite credito",
    mp.codigo_pedido AS "Codigo pedido",
    mp.fecha_pedido AS "Fecha pedido",
    mp.fecha_esperada AS "Fecha esperada",
    mp.fecha_entrega AS "Fecha entrega",
    mp.estado AS "Estado pedido",
    mp.dias_procesamiento AS "Dias procesamiento",
    mp.dias_retraso_adelanto AS "Dias retraso/adelanto",
    tpp.total_venta_pedido AS "Total venta pedido",
    tpp.cantidad_total_productos AS "Cantidad productos",
    tpp.variedad_productos AS "Variedad productos",
    mpp.margen_total_pedido AS "Margen total pedido",
    (SELECT ppc.total_pagado 
     FROM pagos_por_cliente ppc 
     WHERE ppc.codigo_cliente = c.codigo_cliente) AS "Total pagado cliente",
    (SELECT ppc.numero_pagos 
     FROM pagos_por_cliente ppc 
     WHERE ppc.codigo_cliente = c.codigo_cliente) AS "Numero pagos cliente",
    (tpp.total_venta_pedido - (SELECT ppc.total_pagado 
                                FROM pagos_por_cliente ppc 
                                WHERE ppc.codigo_cliente = c.codigo_cliente)) AS "Saldo pendiente"     --
FROM metricas_pedido mp
INNER JOIN totales_por_pedido tpp ON mp.codigo_pedido = tpp.codigo_pedido
INNER JOIN margenes_por_pedido mpp ON mp.codigo_pedido = mpp.codigo_pedido
INNER JOIN cliente c ON mp.codigo_cliente = c.codigo_cliente
INNER JOIN empleado e ON c.codigo_empleado_rep_ventas = e.codigo_empleado
INNER JOIN oficina o ON e.codigo_oficina = o.codigo_oficina
ORDER BY o.pais, o.ciudad, e.apellido1, c.nombre_cliente, mp.fecha_pedido;                   -