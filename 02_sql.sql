-- ============================================================
-- FASE 2 - MODELO RELACIONAL Y SQL
-- MetroBus Analytics
-- PostgreSQL
-- ============================================================


-- ============================================================
-- 1. TABLAS DE DIMENSIONES INDEPENDIENTES
-- ============================================================

-- ------------------------------------------------------------
-- dim_depot
-- ------------------------------------------------------------
CREATE TABLE dim_depot (
    depot_id INTEGER PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    barrio VARCHAR(100) NOT NULL,
    latitud NUMERIC(9,6) NOT NULL,
    longitud NUMERIC(9,6) NOT NULL,
    capacidad_vehiculos INTEGER NOT NULL
);


-- ------------------------------------------------------------
-- dim_linea
-- ------------------------------------------------------------
CREATE TABLE dim_linea (
    linea_id INTEGER PRIMARY KEY,
    codigo VARCHAR(20) NOT NULL UNIQUE,
    nombre VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    km_recorrido NUMERIC(10,2) NOT NULL,
    n_paradas INTEGER NOT NULL,
    frecuencia_min INTEGER NOT NULL
);


-- ------------------------------------------------------------
-- dim_parada
-- ------------------------------------------------------------
CREATE TABLE dim_parada (
    parada_id INTEGER PRIMARY KEY,
    nombre_parada VARCHAR(100) NOT NULL,
    barrio VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
    latitud NUMERIC(9,6) NOT NULL,
    longitud NUMERIC(9,6) NOT NULL,
    accesible_silla BOOLEAN NOT NULL,
    marquesina BOOLEAN NOT NULL,
    panel_informacion BOOLEAN NOT NULL,
    activa BOOLEAN NOT NULL
);


-- ------------------------------------------------------------
-- dim_tarifa
-- ------------------------------------------------------------
CREATE TABLE dim_tarifa (
    tarifa_id INTEGER PRIMARY KEY,
    tipo_titulo VARCHAR(50) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    precio_eur NUMERIC(8,2) NOT NULL,
    es_abono BOOLEAN NOT NULL,
    bonificado BOOLEAN NOT NULL
);


-- ============================================================
-- 2. DIMENSIONES DEPENDIENTES
-- ============================================================

-- ------------------------------------------------------------
-- dim_vehiculo
-- ------------------------------------------------------------
CREATE TABLE dim_vehiculo (
    vehiculo_id INTEGER PRIMARY KEY,
    matricula VARCHAR(20) NOT NULL UNIQUE,
    modelo VARCHAR(100) NOT NULL,
    combustible VARCHAR(30) NOT NULL,
    capacidad_sentados INTEGER NOT NULL,
    capacidad_total INTEGER NOT NULL,
    anno_fabricacion INTEGER NOT NULL,
    anno_incorporacion INTEGER NOT NULL,
    km_totales INTEGER NOT NULL,
    depot_id INTEGER NOT NULL,
    emisiones_co2_gkm INTEGER NOT NULL,
    en_servicio BOOLEAN NOT NULL,

    CONSTRAINT fk_vehiculo_depot
        FOREIGN KEY (depot_id)
        REFERENCES dim_depot(depot_id)
);


-- ------------------------------------------------------------
-- dim_conductores
-- ------------------------------------------------------------
CREATE TABLE dim_conductor (
    conductor_id INTEGER PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    anno_incorporacion INTEGER NOT NULL,
    antiguedad_anos NUMERIC(5,2) NOT NULL,
    turno_habitual VARCHAR(30) NOT NULL,
    depot_id INTEGER NOT NULL,
    formacion VARCHAR(100) NOT NULL,
    licencia_tipo VARCHAR(30) NOT NULL,
    activo BOOLEAN NOT NULL,
    ausencias_2024 INTEGER NOT NULL,

    CONSTRAINT fk_conductor_depot
        FOREIGN KEY (depot_id)
        REFERENCES dim_depot(depot_id)
);


-- ============================================================
-- 3. TABLAS DE HECHOS
-- ============================================================

-- ------------------------------------------------------------
-- fact_viajes
-- ------------------------------------------------------------
CREATE TABLE fact_viajes (
    viaje_id INTEGER PRIMARY KEY,

    linea_id INTEGER NOT NULL,
    vehiculo_id INTEGER NOT NULL,
    conductor_id INTEGER NOT NULL,

    parada_origen_id INTEGER NOT NULL,
    parada_destino_id INTEGER NOT NULL,

    fecha DATE NOT NULL,
    anno INTEGER NOT NULL,
    mes INTEGER NOT NULL,
    dia_semana VARCHAR(20) NOT NULL,
    es_festivo BOOLEAN NOT NULL,

    franja_horaria VARCHAR(30) NOT NULL,

    hora_salida_prog TIME NOT NULL,
    hora_salida_real TIME NOT NULL,
    hora_llegada_real TIME NOT NULL,

    retraso_salida_min INTEGER NOT NULL,
    duracion_real_min INTEGER NOT NULL,

    pasajeros_subidos INTEGER NOT NULL,
    ocupacion_pct NUMERIC(5,2) NOT NULL,

    km_programados NUMERIC(10,2) NOT NULL,
    km_recorridos NUMERIC(10,2) NOT NULL,

    viaje_completado BOOLEAN NOT NULL,

    consumo NUMERIC(10,2) NOT NULL,

    tarifa_predominante_id INTEGER NOT NULL,

    CONSTRAINT fk_viaje_linea
        FOREIGN KEY (linea_id)
        REFERENCES dim_linea(linea_id),

    CONSTRAINT fk_viaje_vehiculo
        FOREIGN KEY (vehiculo_id)
        REFERENCES dim_vehiculo(vehiculo_id),

    CONSTRAINT fk_viaje_conductor
        FOREIGN KEY (conductor_id)
        REFERENCES dim_conductor(conductor_id),

    CONSTRAINT fk_viaje_parada_origen
        FOREIGN KEY (parada_origen_id)
        REFERENCES dim_parada(parada_id),

    CONSTRAINT fk_viaje_parada_destino
        FOREIGN KEY (parada_destino_id)
        REFERENCES dim_parada(parada_id),

    CONSTRAINT fk_viaje_tarifa
        FOREIGN KEY (tarifa_predominante_id)
        REFERENCES dim_tarifa(tarifa_id)
);


-- ------------------------------------------------------------
-- fact_incidencias
-- ------------------------------------------------------------
CREATE TABLE fact_incidencias (
    incidencia_id INTEGER PRIMARY KEY,

    viaje_id INTEGER NOT NULL,
    vehiculo_id INTEGER NOT NULL,
    conductor_id INTEGER NOT NULL,
    linea_id INTEGER NOT NULL,

    fecha DATE NOT NULL,
    anno INTEGER NOT NULL,
    mes INTEGER NOT NULL,

    hora_incidencia TIME NOT NULL,

    tipo_incidencia VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,
    severidad VARCHAR(30) NOT NULL,

    requiere_retirada BOOLEAN NOT NULL,
    duracion_resolucion_min INTEGER NOT NULL,
    vehiculo_sustituto BOOLEAN NOT NULL,

    coste_estimado_eur NUMERIC(10,2) NOT NULL,

    CONSTRAINT fk_incidencia_viaje
        FOREIGN KEY (viaje_id)
        REFERENCES fact_viajes(viaje_id),

    CONSTRAINT fk_incidencia_vehiculo
        FOREIGN KEY (vehiculo_id)
        REFERENCES dim_vehiculo(vehiculo_id),

    CONSTRAINT fk_incidencia_conductor
        FOREIGN KEY (conductor_id)
        REFERENCES dim_conductor(conductor_id),

    CONSTRAINT fk_incidencia_linea
        FOREIGN KEY (linea_id)
        REFERENCES dim_linea(linea_id)
);


-- ------------------------------------------------------------
-- fact_mantenimiento
-- ------------------------------------------------------------
CREATE TABLE fact_mantenimiento (
    mantenimiento_id INTEGER PRIMARY KEY,

    vehiculo_id INTEGER NOT NULL,
    depot_id INTEGER NOT NULL,

    fecha_entrada DATE NOT NULL,
    fecha_salida DATE NOT NULL,

    anno INTEGER NOT NULL,
    mes INTEGER NOT NULL,

    tipo_mantenimiento VARCHAR(100) NOT NULL,
    categoria VARCHAR(50) NOT NULL,

    es_correctivo BOOLEAN NOT NULL,

    dias_fuera_servicio INTEGER NOT NULL,
    km_en_revision INTEGER NOT NULL,

    coste_eur NUMERIC(10,2) NOT NULL,

    proveedor VARCHAR(100) NOT NULL,
    garantia_meses INTEGER NOT NULL,

    CONSTRAINT fk_mantenimiento_vehiculo
        FOREIGN KEY (vehiculo_id)
        REFERENCES dim_vehiculo(vehiculo_id),

    CONSTRAINT fk_mantenimiento_depot
        FOREIGN KEY (depot_id)
        REFERENCES dim_depot(depot_id)
);

-- ============================================================
-- 3. COMPROBACIÓN DE LA CREACIÓN DE TABLAS
-- ============================================================

SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
ORDER BY table_name;

-- ============================================================
-- 4. COMPROBACIÓN DE LAS RELACIONES ENTRE TABLAS
-- ============================================================

SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
    AND ccu.table_schema = tc.table_schema
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
ORDER BY tc.table_name, kcu.column_name;

-- ============================================================
-- 5. COMPROBACIÓN TIPOS DE DATOS DE LOS CAMPOS
-- ============================================================

SELECT
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public'
ORDER BY table_name, ordinal_position;

-- ============================================================
-- 6. CONSULTAS DE NEGOCIO
-- ============================================================
-- ------------------------------------------------------------
-- Consulta 1: ¿Qué lineas tienen más retrasos?
-- ------------------------------------------------------------

SELECT
    l.linea_id,
    l.codigo,
    l.nombre,
    COUNT(v.viaje_id) AS total_viajes,
    ROUND(AVG(v.retraso_salida_min), 2) AS retraso_medio_min
FROM fact_viajes AS v
JOIN dim_linea AS l
    ON v.linea_id = l.linea_id
GROUP BY
    l.linea_id,
    l.codigo,
    l.nombre
ORDER BY retraso_medio_min DESC;

-- ------------------------------------------------------------
-- Consulta 2: ¿Qué franjas horarias concentran mayor demanda?
-- ------------------------------------------------------------

SELECT
    v.franja_horaria,
    COUNT(v.viaje_id) AS total_viajes,
    SUM(v.pasajeros_subidos) AS total_pasajeros,
    ROUND(AVG(v.pasajeros_subidos), 2) AS pasajeros_medios_por_viaje,
    CASE
        WHEN SUM(v.pasajeros_subidos) >= (
            SELECT AVG(total_pasajeros)
            FROM (
                SELECT
                    SUM(pasajeros_subidos) AS total_pasajeros
                FROM fact_viajes
                GROUP BY franja_horaria
            ) AS demanda_franjas
        )
        THEN 'Alta demanda'
        ELSE 'Demanda inferior a la media'
    END AS nivel_demanda
FROM fact_viajes AS v
GROUP BY v.franja_horaria
ORDER BY total_pasajeros DESC;

-- ------------------------------------------------------------
-- Consulta 3: ¿Qué líneas tienen peor tasa de viajes completados?
-- ------------------------------------------------------------

SELECT
    l.linea_id,
    l.codigo,
    l.nombre,
    COUNT(v.viaje_id) AS total_viajes,
    SUM(
        CASE
            WHEN v.viaje_completado THEN 1
            ELSE 0
        END
    ) AS viajes_completados,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN v.viaje_completado THEN 1
                ELSE 0
            END
        ) / COUNT(v.viaje_id),
        2
    ) AS porcentaje_completados
FROM fact_viajes AS v
JOIN dim_linea AS l
    ON v.linea_id = l.linea_id
GROUP BY
    l.linea_id,
    l.codigo,
    l.nombre
HAVING COUNT(v.viaje_id) >= 1000
ORDER BY porcentaje_completados DESC;

-- ------------------------------------------------------------
-- Consulta 4: ¿Qué líneas presentan mayor ocupación media?
-- ------------------------------------------------------------

SELECT
    l.linea_id,
    l.codigo,
    l.nombre,
    COUNT(v.viaje_id) AS total_viajes,
    ROUND(AVG(v.ocupacion_pct), 2) AS ocupacion_media_pct,
    ROUND(MAX(v.ocupacion_pct), 2) AS ocupacion_maxima_pct
FROM fact_viajes AS v
JOIN dim_linea AS l
    ON v.linea_id = l.linea_id
GROUP BY
    l.linea_id,
    l.codigo,
    l.nombre
ORDER BY ocupacion_media_pct DESC;

-- ------------------------------------------------------------
-- Consulta 5: ¿Qué tarifas son las más utilizadas?
-- ------------------------------------------------------------

SELECT
    t.tarifa_id,
    t.tipo_titulo,
    t.categoria,
    t.precio_eur,
    COUNT(v.viaje_id) AS viajes_con_tarifa,
    ROUND(
        100.0 * COUNT(v.viaje_id)
        / SUM(COUNT(v.viaje_id)) OVER (),
        2
    ) AS porcentaje_uso
FROM fact_viajes AS v
JOIN dim_tarifa AS t
    ON v.tarifa_predominante_id = t.tarifa_id
GROUP BY
    t.tarifa_id,
    t.tipo_titulo,
    t.categoria,
    t.precio_eur
ORDER BY viajes_con_tarifa DESC;

-- ------------------------------------------------------------
-- Consulta 6: ¿Qué tipo de combustible presenta menor consumo medio?
-- ------------------------------------------------------------

SELECT
    ve.combustible,
    COUNT(v.viaje_id) AS total_viajes,
    ROUND(AVG(v.consumo), 2) AS consumo_medio,
    ROUND(AVG(v.km_recorridos), 2) AS km_medios_recorridos
FROM fact_viajes AS v
JOIN dim_vehiculo AS ve
    ON v.vehiculo_id = ve.vehiculo_id
GROUP BY ve.combustible
ORDER BY consumo_medio ASC;


-- ------------------------------------------------------------
-- Consulta 7: ¿Qué vehículos acumulan mayor coste de mantenimiento e incidencias?
-- ------------------------------------------------------------

WITH costes_mantenimiento AS (
    SELECT
        vehiculo_id,
        SUM(coste_eur) AS coste_mantenimiento
    FROM fact_mantenimiento
    GROUP BY vehiculo_id
),

costes_incidencias AS (
    SELECT
        vehiculo_id,
        SUM(coste_estimado_eur) AS coste_incidencias
    FROM fact_incidencias
    GROUP BY vehiculo_id
)

SELECT
    ve.vehiculo_id,
    ve.matricula,
    ve.modelo,
    ve.combustible,
    COALESCE(cm.coste_mantenimiento, 0) AS coste_mantenimiento,
    COALESCE(ci.coste_incidencias, 0) AS coste_incidencias,
    COALESCE(cm.coste_mantenimiento, 0)
        + COALESCE(ci.coste_incidencias, 0) AS coste_total
FROM dim_vehiculo AS ve
LEFT JOIN costes_mantenimiento AS cm
    ON ve.vehiculo_id = cm.vehiculo_id
LEFT JOIN costes_incidencias AS ci
    ON ve.vehiculo_id = ci.vehiculo_id
ORDER BY coste_total DESC;

-- ------------------------------------------------------------
-- Consulta 8: ¿Cómo varía el rendimiento de los conductores según su turno?
-- ------------------------------------------------------------

WITH rendimiento_turnos AS (
    SELECT
        c.turno_habitual,
        COUNT(v.viaje_id) AS total_viajes,
        ROUND(AVG(v.retraso_salida_min), 2) AS retraso_medio_min,
        ROUND(AVG(v.ocupacion_pct), 2) AS ocupacion_media_pct,
        ROUND(
            100.0 * SUM(
                CASE
                    WHEN v.viaje_completado THEN 1
                    ELSE 0
                END
            ) / COUNT(v.viaje_id),
            2
        ) AS porcentaje_completados
    FROM fact_viajes AS v
    JOIN dim_conductor AS c
        ON v.conductor_id = c.conductor_id
    GROUP BY c.turno_habitual
)

SELECT
    turno_habitual,
    total_viajes,
    retraso_medio_min,
    ocupacion_media_pct,
    porcentaje_completados,
    ROUND(
        retraso_medio_min
        - AVG(retraso_medio_min) OVER (),
        2
    ) AS diferencia_retraso_media_global
FROM rendimiento_turnos
ORDER BY retraso_medio_min ASC;