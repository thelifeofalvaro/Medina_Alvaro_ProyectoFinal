# MetroBus Analytics — Gobierno del dato
### Fecha revisión: Septiembre-2026 (Si se modifica cambiar el pie del documento también)

## 01. Objetivo

Este documento recoge las principales decisiones adoptadas durante el proceso de análisis y preparación de los datos de MetroBus.

Su objetivo es garantizar la trazabilidad del tratamiento realizado sobre los datos, facilitar su auditoría y establecer una definición común de las métricas que se utilizarán posteriormente en el cuadro de mando.

El modelo está compuesto por **9 tablas: 3 tablas de hechos y 6 dimensiones**. Durante la fase de exploración se identificaron problemas puntuales de calidad relacionados principalmente con valores nulos, inconsistencias de formato y algunos valores anómalos. Los problemas detectados fueron tratados individualmente utilizando información disponible en el propio dataset y, cuando no fue posible reconstruir un valor de forma suficientemente fiable, se aplicaron criterios de imputación documentados. Estas decisiones (nulos, calidad, etc...) se han ido comentando tanto a medida que se han detectado durante el EDA, en las conclusiones finales y en este documento de manera más extensa

# 02. Diccionario de datos

## 02.01. `fact_viajes`

| Nombre de campo | Tipo de dato | Descripción | Valores válidos / rango esperado | Observaciones de calidad |
|---|---|---|---|---|
| `viaje_id` | INTEGER | Identificador único del viaje | Enteros positivos y únicos | PK. Sin duplicados detectados |
| `linea_id` | INTEGER | Identificador de la línea realizada | IDs existentes en `dim_linea` | FK. Sin inconsistencias |
| `vehiculo_id` | INTEGER | Vehículo que realiza el viaje | IDs existentes en `dim_vehiculo` | FK. Sin inconsistencias |
| `conductor_id` | INTEGER | Conductor asignado al viaje | IDs existentes en `dim_conductor` | FK. Sin inconsistencias |
| `parada_origen_id` | INTEGER | Parada de origen | IDs existentes en `dim_parada` | FK. Sin inconsistencias |
| `parada_destino_id` | INTEGER | Parada de destino | IDs existentes en `dim_parada` | FK. Sin inconsistencias |
| `fecha` | DATE | Fecha del viaje | Fechas del periodo analizado | Convertida desde texto a fecha |
| `anno` | INTEGER | Año del viaje | Año correspondiente a `fecha` | Sin problemas detectados |
| `mes` | INTEGER | Mes del viaje | 1–12 | Sin problemas detectados |
| `dia_semana` | VARCHAR | Día de la semana | Lunes–Domingo | Se normalizaron mayúsculas, minúsculas e idioma |
| `es_festivo` | BOOLEAN | Indica si el día es festivo | TRUE/FALSE | Sin problemas detectados |
| `franja_horaria` | VARCHAR | Franja temporal del servicio | Madrugada, Mañana punta, Valle mañana, Tarde, Tarde punta, Noche | Se normalizaron variantes sin tilde |
| `hora_salida_prog` | TIME | Hora programada de salida | Hora válida | Como object en el EDA, y como TIME para SQL |
| `hora_salida_real` | TIME | Hora real de salida | Hora válida | Se mantiene como hora en el modelo SQL |
| `hora_llegada_real` | TIME | Hora real de llegada | Hora válida | Se mantiene como hora en el modelo SQL|
| `retraso_salida_min` | INTEGER | Diferencia entre salida real y programada, en minutos | Valores enteros, incluyendo retrasos negativos si existen | 80 valores `-99` fueron reconstruidos |
| `duracion_real_min` | INTEGER | Duración real del viaje en minutos | Valores enteros no negativos | Sin problemas específicos detectados |
| `pasajeros_subidos` | INTEGER | Número de pasajeros que suben al viaje | Enteros no negativos | 40 nulos imputados mediante la mediana |
| `ocupacion_pct` | NUMERIC | Porcentaje de ocupación del vehículo | Porcentaje entre 0 y 100 | Sin problemas específicos detectados |
| `km_programados` | NUMERIC | Kilómetros previstos para el viaje | Valores positivos | Sin problemas específicos detectados |
| `km_recorridos` | NUMERIC | Kilómetros realmente recorridos | Valores positivos o cero | Sin problemas específicos detectados |
| `viaje_completado` | BOOLEAN | Indica si el viaje fue completado | TRUE/FALSE | Sin problemas detectados |
| `consumo` | NUMERIC | Consumo registrado durante el viaje | Valores positivos | 1.065 nulos imputados mediante la mediana |
| `tarifa_predominante_id` | INTEGER | Tarifa predominante asociada al viaje | IDs existentes en `dim_tarifa` | FK. Sin inconsistencias |

## 02.02. `fact_incidencias`

| Nombre de campo | Tipo de dato | Descripción | Valores válidos / rango esperado | Observaciones de calidad |
|---|---|---|---|---|
| `incidencia_id` | INTEGER | Identificador único de la incidencia | Enteros positivos y únicos | PK. Sin duplicados |
| `viaje_id` | INTEGER | Viaje en el que se produce la incidencia | IDs existentes en `fact_viajes` | FK. Sin inconsistencias |
| `vehiculo_id` | INTEGER | Vehículo afectado | IDs existentes en `dim_vehiculo` | FK. Sin inconsistencias |
| `conductor_id` | INTEGER | Conductor asociado | IDs existentes en `dim_conductor` | FK. Sin inconsistencias |
| `linea_id` | INTEGER | Línea afectada | IDs existentes en `dim_linea` | FK. Sin inconsistencias |
| `fecha` | DATE | Fecha de la incidencia | Fechas del periodo analizado | Convertida desde texto a fecha |
| `anno` | INTEGER | Año de la incidencia | Año correspondiente a `fecha` | Sin problemas detectados |
| `mes` | INTEGER | Mes de la incidencia | 1–12 | Sin problemas detectados |
| `hora_incidencia` | TIME | Hora en que se registra la incidencia | Hora válida | Sin problemas específicos |
| `tipo_incidencia` | VARCHAR | Tipo concreto de incidencia | Categorías existentes en el dataset | Sin nulos |
| `categoria` | VARCHAR | Categoría general de la incidencia | Categorías existentes | Sin nulos |
| `severidad` | VARCHAR | Gravedad de la incidencia | Categorías de severidad existentes | Sin problemas detectados |
| `requiere_retirada` | BOOLEAN | Indica si requiere retirar el vehículo | TRUE/FALSE | Sin problemas detectados |
| `duracion_resolucion_min` | INTEGER | Tiempo necesario para resolver la incidencia | Minutos no negativos | Valores elevados se conservaron por corresponder a incidencias graves |
| `vehiculo_sustituto` | BOOLEAN | Indica si fue necesario sustituir el vehículo | TRUE/FALSE | Sin problemas detectados |
| `coste_estimado_eur` | NUMERIC | Coste estimado asociado a la incidencia | EUR, valor no negativo esperado | Valores elevados se conservaron por su relación con incidencias graves |

## 02.03. `fact_mantenimiento`

| Nombre de campo | Tipo de dato | Descripción | Valores válidos / rango esperado | Observaciones de calidad |
|---|---|---|---|---|
| `mantenimiento_id` | INTEGER | Identificador único del mantenimiento | Enteros positivos y únicos | PK. Sin duplicados |
| `vehiculo_id` | INTEGER | Vehículo sometido a mantenimiento | IDs existentes en `dim_vehiculo` | FK. Sin inconsistencias |
| `depot_id` | INTEGER | Cochera/depot donde se realiza | IDs existentes en `dim_depot` | FK. Sin inconsistencias |
| `fecha_entrada` | DATE | Fecha de entrada al mantenimiento | Fecha válida | Convertida desde texto |
| `fecha_salida` | DATE | Fecha de salida del mantenimiento | Fecha igual o posterior a entrada | Convertida desde texto |
| `anno` | INTEGER | Año del mantenimiento | Año correspondiente a `fecha_entrada` | Sin problemas detectados |
| `mes` | INTEGER | Mes del mantenimiento | 1–12 | Sin problemas detectados |
| `tipo_mantenimiento` | VARCHAR | Tipo de intervención | Categorías existentes | Sin problemas detectados |
| `categoria` | VARCHAR | Categoría del mantenimiento | Categorías existentes | 15 nulos reconstruidos mediante `tipo_mantenimiento` |
| `es_correctivo` | BOOLEAN | Indica si el mantenimiento es correctivo | TRUE/FALSE | Sin problemas detectados |
| `dias_fuera_servicio` | INTEGER | Días que el vehículo permanece fuera de servicio | Enteros no negativos | Sin problemas detectados |
| `km_en_revision` | INTEGER | Kilometraje del vehículo en la revisión | Kilómetros no negativos | Historial inconsistente detectado para vehículo 16, utilizado para evaluar su dato de kilometraje |
| `coste_eur` | NUMERIC | Coste de la intervención | EUR, valor no negativo esperado | 25 valores negativos tratados como errores de registro |
| `proveedor` | VARCHAR | Proveedor que realiza el mantenimiento | Categorías existentes | Sin problemas detectados |
| `garantia_meses` | INTEGER | Duración de la garantía | Enteros no negativos | Sin problemas detectados |

## 02.04. `dim_linea`

| Nombre de campo | Tipo de dato | Descripción | Valores válidos / rango esperado | Observaciones de calidad |
|---|---|---|---|---|
| `linea_id` | INTEGER | Identificador de la línea | Enteros positivos y únicos | PK. 10 líneas |
| `codigo` | VARCHAR | Código comercial de la línea | Códigos únicos | UNIQUE. Sin duplicados |
| `nombre` | VARCHAR | Nombre descriptivo de la línea | Texto | Sin problemas detectados |
| `tipo` | VARCHAR | Tipo de línea | Categorías existentes | Sin nulos |
| `km_recorrido` | NUMERIC | Longitud del recorrido | Kilómetros positivos | Sin problemas detectados |
| `n_paradas` | INTEGER | Número de paradas | Entero positivo | Sin problemas detectados |
| `frecuencia_min` | INTEGER | Frecuencia prevista del servicio | Minutos positivos | Sin problemas detectados |

## 02.05. `dim_vehiculo`

| Nombre de campo | Tipo de dato | Descripción | Valores válidos / rango esperado | Observaciones de calidad |
|---|---|---|---|---|
| `vehiculo_id` | INTEGER | Identificador del vehículo | Enteros positivos y únicos | PK. 45 vehículos |
| `matricula` | VARCHAR | Matrícula del vehículo | Identificador único de matrícula | UNIQUE. Sin duplicados |
| `modelo` | VARCHAR | Modelo del vehículo | Modelos existentes | Sin problemas detectados |
| `combustible` | VARCHAR | Tipo de motorización/combustible | Diésel, Eléctrico, Híbrido | Se normalizaron variantes y se imputó 1 nulo |
| `capacidad_sentados` | INTEGER | Número de plazas sentadas | Entero no negativo | Sin problemas detectados |
| `capacidad_total` | INTEGER | Capacidad total del vehículo | Entero positivo | Sin problemas detectados |
| `anno_fabricacion` | INTEGER | Año de fabricación | Año razonable y anterior o igual a incorporación | El vehículo 8 tenía 2099; se corrigió a 2021 |
| `anno_incorporacion` | INTEGER | Año de incorporación a MetroBus | Año razonable | El vehículo 8 tenía 2024; se corrigió a 2022 |
| `km_totales` | INTEGER | Kilometraje acumulado del vehículo | Kilómetros no negativos | Vehículo 16 tenía -500; se corrigió a 500.000 |
| `depot_id` | INTEGER | Cochera asignada | IDs existentes en `dim_depot` | FK. Sin inconsistencias |
| `emisiones_co2_gkm` | INTEGER | Emisiones estimadas de CO₂ por km | g/km no negativos | Sin problemas específicos |
| `en_servicio` | BOOLEAN | Indica si el vehículo está operativo | TRUE/FALSE | Sin problemas detectados |

## 02.06. `dim_conductor`

| Nombre de campo | Tipo de dato | Descripción | Valores válidos / rango esperado | Observaciones de calidad |
|---|---|---|---|---|
| `conductor_id` | INTEGER | Identificador del conductor | Enteros positivos y únicos | PK. 30 conductores |
| `nombre` | VARCHAR | Nombre del conductor | Texto | Sin problemas detectados |
| `anno_incorporacion` | INTEGER | Año de incorporación | Año válido | Sin problemas detectados |
| `antiguedad_anos` | NUMERIC | Antigüedad calculada del conductor | Años no negativos | 1 nulo calculado mediante año de incorporación |
| `turno_habitual` | VARCHAR | Turno habitual del conductor | Mañana, Tarde, Noche, Partido | Se normalizaron variantes |
| `depot_id` | INTEGER | Cochera asignada | IDs existentes en `dim_depot` | FK. Sin inconsistencias |
| `formacion` | VARCHAR | Formación del conductor | Categorías existentes | Sin problemas detectados |
| `licencia_tipo` | VARCHAR | Tipo de licencia | Categorías existentes | Sin problemas detectados |
| `activo` | BOOLEAN | Indica si el conductor está activo | TRUE/FALSE | Sin problemas detectados |
| `ausencias_2024` | INTEGER | Número de ausencias registradas en 2024 | Enteros no negativos | Sin problemas detectados |

## 02.07. `dim_parada`

| Nombre de campo | Tipo de dato | Descripción | Valores válidos / rango esperado | Observaciones de calidad |
|---|---|---|---|---|
| `parada_id` | INTEGER | Identificador de la parada | Enteros positivos y únicos | PK. 120 paradas |
| `nombre_parada` | VARCHAR | Nombre de la parada | Texto | Sin problemas detectados |
| `barrio` | VARCHAR | Barrio o zona donde se encuentra | Categorías normalizadas | Se unificaron diferencias de mayúsculas/minúsculas |
| `tipo` | VARCHAR | Tipo de parada | Categorías existentes | Sin problemas detectados |
| `latitud` | NUMERIC | Coordenada geográfica de latitud | Coordenada geográfica válida | Un valor nulo y un `999` fueron tratados mediante imputación |
| `longitud` | NUMERIC | Coordenada geográfica de longitud | Coordenada geográfica válida | Sin problemas detectados |
| `accesible_silla` | BOOLEAN | Indica si la parada es accesible para silla de ruedas | TRUE/FALSE | 1 nulo imputado según la proporción observada |
| `marquesina` | BOOLEAN | Indica si dispone de marquesina | TRUE/FALSE | Sin problemas detectados |
| `panel_informacion` | BOOLEAN | Indica si dispone de panel informativo | TRUE/FALSE | Sin problemas detectados |
| `activa` | BOOLEAN | Indica si la parada está activa | TRUE/FALSE | Sin problemas detectados |

## 02.08. `dim_tarifa`

| Nombre de campo | Tipo de dato | Descripción | Valores válidos / rango esperado | Observaciones de calidad |
|---|---|---|---|---|
| `tarifa_id` | INTEGER | Identificador de la tarifa | Enteros positivos y únicos | PK. 9 tarifas |
| `tipo_titulo` | VARCHAR | Tipo de título de transporte | Categorías existentes | Sin problemas detectados |
| `categoria` | VARCHAR | Categoría de usuario/tarifa | Categorías existentes | Sin problemas detectados |
| `precio_eur` | NUMERIC | Precio del título | EUR, valor no negativo | Sin problemas detectados |
| `es_abono` | BOOLEAN | Indica si es un abono | TRUE/FALSE | Sin problemas detectados |
| `bonificado` | BOOLEAN | Indica si tiene bonificación | TRUE/FALSE | Sin problemas detectados |

## 02.09. `dim_depot`

| Nombre de campo | Tipo de dato | Descripción | Valores válidos / rango esperado | Observaciones de calidad |
|---|---|---|---|---|
| `depot_id` | INTEGER | Identificador de la cochera | Enteros positivos y únicos | PK. 3 depots |
| `nombre` | VARCHAR | Nombre de la cochera | Texto | Sin problemas detectados |
| `barrio` | VARCHAR | Barrio donde se ubica | Texto/categorías existentes | Sin problemas detectados |
| `latitud` | NUMERIC | Latitud de la cochera | Coordenada geográfica válida | Sin problemas detectados |
| `longitud` | NUMERIC | Longitud de la cochera | Coordenada geográfica válida | Sin problemas detectados |
| `capacidad_vehiculos` | INTEGER | Capacidad máxima de vehículos | Entero positivo | Sin problemas detectados |

# 03. Data Quality Log - Decisiones de limpieza

Durante la EDA se detectaron problemas puntuales de calidad. Las relaciones entre las tablas fueron comprobadas previamente y no se detectaron claves foráneas sin correspondencia.

| # | Tabla | Campo | Tipo de problema | Frecuencia | Decisión tomada | Justificación |
|---|---|---|---:|---:|---|---|
| 1 | `dim_vehiculo` | `km_totales` | Valor negativo/anómalo | 1 | Sustituir `-500` por `500000` | El vehículo 16 presentaba un valor incompatible con un kilometraje real. El histórico de odómetro de mantenimiento no era suficientemente consistente para reconstruir el valor exacto. Se confirmó como error de introducción y se mantuvo la base numérica transformándola a un valor coherente. |
| 2 | `dim_vehiculo` | `anno_fabricacion` / `anno_incorporacion` | Inconsistencia temporal | 1 vehículo | Cambiar a 2021 / 2022 | El vehículo 8 tenía fabricación en 2099 e incorporación en 2024, pero registraba viajes desde 2022. Se estableció 2022 como incorporación y 2021 como fabricación. |
| 3 | `fact_viajes` | `franja_horaria` | Inconsistencia de formato | 22.625 | Normalizar categorías | Se unificaron variantes como `Valle manana` y `Manana punta` con las categorías normalizadas con el caracter correcto (ñ). |
| 4 | `fact_viajes` | `retraso_salida_min` | Código/valor anómalo | 80 | Reconstruir mediante horas programada y real | El valor `-99` aparecía en 80 registros. Al disponer de hora programada y real se pudo calcular directamente la diferencia y preservar la información. |
| 5 | `fact_mantenimiento` | `coste_eur` | Valores negativos | 25 | Convertir a valor absoluto | Los valores negativos se interpretaron como errores de introducción del coste y se transformaron a valores positivos coherentes con la naturaleza de la variable. |
| 6 | `dim_parada` | `latitud` | Valor nulo | 1 | Imputar con la media de latitud del barrio correspondiente | No se encontró información suficientemente fiable para reconstruir la coordenada exacta, por lo que se utilizó la media de latitud del barrio excluyendo valores erróneos. |
| 7 | `dim_parada` | `latitud` | Valor inválido (`999`) | 1 | Imputar con la media de latitud de Estación | No se encontró un patrón suficientemente fiable entre identificador, latitud y longitud que permitiera reconstruir la coordenada exacta. |
| 8 | `dim_parada` | `accesible_silla` | Valor nulo | 1 | Imputar `TRUE` | No se encontró un patrón suficientemente fiable con otras variables de la parada. Se utilizó la proporción de accesibilidad observada en el conjunto. |
| 9 | `dim_vehiculo` | `combustible` | Valor nulo | 1 | Imputar `Diésel` | El vehículo correspondía al modelo Mercedes-Benz Citaro y las otras unidades del mismo modelo registradas eran Diésel. |
| 10 | `dim_conductor` | `antiguedad_anos` | Valor nulo | 1 | Calcular mediante `2024 - anno_incorporacion` | La antigüedad deriva directamente del año de incorporación, por lo que no fue necesaria una imputación estadística. |
| 11 | `fact_viajes` | `pasajeros_subidos` | Valores nulos | 40 | Imputar mediante la mediana | La distribución presenta asimetría positiva y la mediana es más robusta frente a valores extremos. |
| 12 | `fact_viajes` | `consumo` | Valores nulos | 1065 | Imputar mediante la mediana | Los nulos suponían el 2,13 %. La relación con `km_recorridos` era moderada (0,44), insuficiente para una reconstrucción fiable, por lo que se utilizó la mediana de 5,34. |
| 13 | `fact_mantenimiento` | `categoria` | Valores nulos | 15 | Reconstruir mediante `tipo_mantenimiento` | Se comprobó una correspondencia unívoca entre tipo de mantenimiento y categoría, permitiendo recuperar los 15 valores. |
| 14 | `fact_viajes` | `dia_semana` | Inconsistencia de formato/idioma | 30 de capitalización  50.000 traducidos | Normalizar a castellano y capitalización homogénea | Se unificaron variantes como `MONDAY` y `Monday` en `Lunes`, y el resto de días siguiendo el mismo criterio. |
| 15 | `dim_conductor` | `turno_habitual` | Inconsistencia de formato | 8 | Normalizar categorías | Se unificaron variantes como `manana` y `Manana (06-14h)` bajo `Mañana (06-14h)`, junto con los turnos de tarde, noche y partido. |
| 16 | `dim_parada` | `barrio` | Inconsistencia de formato | 13 | Normalizar capitalización y acentos | Se unificaron valores como `BARRIO NORTE` / `Barrio Norte`, `ESTACION` / `Estación` y `centro` / `Centro`. |

### Criterio general

La estrategia aplicada fue **corregir los errores identificables, reconstruir los valores cuando existía información suficiente y utilizar imputación estadística únicamente cuando no existía una alternativa determinista suficientemente fiable**. En `fact_incidencias`, por ejemplo, se conservaron valores elevados de duración de resolución y coste estimado porque correspondían a incidencias graves y podían representar información operacional relevante. En resumen, no se eliminaron automáticamente los valores extremos sin más. 

# 4. Definición formal de KPIs

Los siguientes indicadores constituyen una primera definición de las métricas que podrán utilizarse posteriormente en el cuadro de mando. La definición exacta es importante para garantizar que una misma métrica no se interprete de forma diferente según la visualización.

## KPI 1 — Retraso medio de salida

**Nombre:** Retraso medio de salida (min)

**Fórmula:**

SUM(retraso_salida_min) / COUNT(viaje_id) ó AVG(retraso_salida_min)

**Fuente:**
- Tabla: `fact_viajes`
- Campo: `retraso_salida_min`
- Identificador: `viaje_id`

**Criterios de exclusión:**
- Excluir registros sin `viaje_id`.
- Los valores `-99` no se excluyen porque fueron previamente reconstruidos durante la limpieza.

**Interpretación:**
Minutos medios de retraso respecto a la hora de salida programada.

**Responsable de negocio que debería validarlo:**
Responsable de Operaciones / Explotación.

## KPI 2 — Tasa de viajes completados

**Nombre:** Porcentaje de viajes completados

**Fórmula:**

SUM(CASE WHEN viaje_completado = TRUE THEN 1 ELSE 0 END)
/
COUNT(viaje_id)
× 100

**Fuente:**
- Tabla: `fact_viajes`
- Campo: `viaje_completado`
- Identificador: `viaje_id`

**Criterios de exclusión:**
- Excluir únicamente registros sin identificador de viaje.

**Interpretación:**
Porcentaje de viajes registrados que finalizaron correctamente.

**Responsable:**
Responsable de Operaciones / Explotación.

## KPI 3 — Ocupación media

**Nombre:** Ocupación media del servicio (%)

**Fórmula:**

AVG(ocupacion_pct)

**Fuente:**
- Tabla: `fact_viajes`
- Campo: `ocupacion_pct`

**Criterios de exclusión:**
- Excluir valores nulos.
- No excluir valores altos si permanecen dentro del rango válido de ocupación.

**Interpretación:**
Nivel medio de utilización de la capacidad disponible del servicio.

**Responsable:**
Responsable de Planificación / Demanda.

## KPI 4 — Pasajeros transportados

**Nombre:** Pasajeros transportados

**Fórmula:**

SUM(pasajeros_subidos)

**Fuente:**
- Tabla: `fact_viajes`
- Campo: `pasajeros_subidos`

**Criterios de exclusión:**
- No existen nulos tras la limpieza.
- No se excluyen viajes completados o no completados salvo que la definición de negocio futura establezca lo contrario.

**Interpretación:**
Número total de pasajeros registrados durante el periodo seleccionado.

**Responsable:**
Responsable de Planificación / Demanda.

## KPI 5 — Consumo medio

**Nombre:** Consumo medio por viaje

**Fórmula:**

AVG(consumo)

**Fuente:**
- Tabla: `fact_viajes`
- Campo: `consumo`

**Criterios de exclusión:**
- Excluir únicamente valores nulos, aunque actualmente los valores nulos fueron imputados durante la limpieza.
- Los valores extremos se mantienen salvo que posteriormente se establezca una regla operacional específica.

**Interpretación:**
Consumo medio registrado por viaje en las unidades utilizadas por el dataset.

**Responsable:**
Responsable de Flota / Sostenibilidad.

## KPI 6 — Número de incidencias

**Nombre:** Incidencias registradas

**Fórmula:**

COUNT(incidencia_id)

**Fuente:**
- Tabla: `fact_incidencias`
- Campo: `incidencia_id`

**Criterios de exclusión:**
- No existen registros duplicados.
- No se excluyen incidencias por severidad.

**Interpretación:**
Número de incidencias registradas durante el periodo o contexto seleccionado.

**Responsable:**
Responsable de Operaciones / Mantenimiento.

## KPI 7 — Coste de mantenimiento

**Nombre:** Coste total de mantenimiento (€)

**Fórmula:**

SUM(coste_eur)

**Fuente:**
- Tabla: `fact_mantenimiento`
- Campo: `coste_eur`

**Criterios de exclusión:**
- Los 25 valores negativos identificados fueron corregidos durante la limpieza.
- No se excluyen intervenciones correctivas ni preventivas.

**Interpretación:**
Coste económico acumulado de las intervenciones de mantenimiento.

**Responsable:**
Responsable de Mantenimiento / Flota.

## KPI 8 — Coste asociado a incidencias

**Nombre:** Coste estimado de incidencias (€)

**Fórmula:**

SUM(coste_estimado_eur)

**Fuente:**
- Tabla: `fact_incidencias`
- Campo: `coste_estimado_eur`

**Criterios de exclusión:**
- No se excluyen incidencias por severidad.
- Los valores elevados se conservan cuando corresponden a incidencias graves.

**Interpretación:**
Coste estimado acumulado de las incidencias registradas.

**Responsable:**
Responsable de Operaciones / Mantenimiento.

## KPI 9 — Coste de mantenimiento e incidencias

**Nombre:** Coste asociado a mantenimiento e incidencias (€)

**Fórmula:**

SUM(fact_mantenimiento.coste_eur)
+
SUM(fact_incidencias.coste_estimado_eur)


**Fuente:**
- `fact_mantenimiento.coste_eur`
- `fact_incidencias.coste_estimado_eur`

**Criterios de exclusión:**
- Se utilizan los datos previamente depurados.
- No se deben realizar joins directos entre ambas tablas de hechos para sumar costes, ya que podría producirse una multiplicación de registros.

**Interpretación:**
Coste económico acumulado asociado a mantenimiento e incidencias de la flota.

**Responsable:**
Responsable de Flota / Dirección de Operaciones.


# 05. Reglas generales de gobierno

A partir de las decisiones tomadas durante la preparación del dataset se establecen las siguientes reglas para seguir desde que se implemente este proyecto:

1. **No modificar los datasets originales.** Las transformaciones se realizan sobre copias de trabajo.
2. **Toda corrección debe ser trazable**, indicando campo, número de registros afectados y motivo.
3. **Los valores extremos no se eliminarán automáticamente.** Deben analizarse en su contexto operacional.
4. **Se priorizará la reconstrucción determinista** cuando exista información suficiente en otras columnas.
5. **La imputación estadística se utilizará cuando no exista una reconstrucción fiable**, justificando el método utilizado.
6. **Las categorías deberán mantenerse normalizadas**, evitando variantes de capitalización, idioma o acentuación.
7. **Las claves foráneas deben mantener correspondencia con sus dimensiones de referencia.**
8. **Los KPIs deben utilizar las definiciones establecidas en este documento** para evitar interpretaciones diferentes en el cuadro de mando.
9. Las modificaciones realizadas sobre los datos deben quedar reflejadas en el Data Quality Log.
10. Los responsables de negocio indicados deberán validar las definiciones de los KPIs antes de considerarlas métricas oficiales de producción.


# 06. Limitaciones

Las definiciones anteriores se basan exclusivamente en la información disponible en el dataset de MetroBus.

En particular:

- `consumo` se utiliza según la unidad proporcionada por el dataset, sin disponer de un diccionario adicional que documente formalmente su unidad física.
- `coste_estimado_eur` representa una estimación y no necesariamente un coste contable definitivo.
- La imputación de algunos valores permite mantener la integridad analítica del dataset, pero introduce cierto grado de incertidumbre.
- La ausencia de información adicional sobre determinadas reglas internas de MetroBus limita la posibilidad de reconstruir algunos valores de forma exacta.
- Los responsables indicados son roles de negocio propuestos para la validación de las métricas, no personas concretas.

Este documento deberá actualizarse si durante la construcción del cuadro de mando se introducen nuevos indicadores, reglas de negocio o fuentes de información.

Última fecha: Septiembre-2026.