# MetroBus Analytics — Álvaro Medina

Proyecto de análisis de datos para una empresa ficticia de transporte urbano. El proyecto cubre el ciclo completo de trabajo: exploración y limpieza de datos, modelado relacional, consultas SQL, gobierno del dato y construcción de un dashboard en Power BI.

## Stack tecnológico

- **Python 3.14.0:** Análisis y preparación de datos.
- **Pandas:** Carga, transformación, limpieza y análisis de los datasets.
- **NumPy:** Operaciones y tratamiento numérico.
- **Matplotlib / Seaborn:** Visualización exploratoria.
- **python-dotenv:** Gestión de credenciales mediante variables de entorno.
- **PostgreSQL:** Base de datos relacional.
- **pgAdmin 4:** Sdministración y ejecución de consultas SQL.
- **psycopg2:** Conexión entre Python y PostgreSQL.
- **Jupyter Notebook:** Desarrollo del EDA.
- **Power BI:** Modelado analítico, KPIs y dashboard

## Estructura del proyecto

```text
├── 00_enunciado.ipynb 
├── 01_eda.ipynb
├── 02_sql.sql
├── 03_gobierno.md
├── 04_dashboard.pbix 
├── 05_presentacion.pdf 
├── cargar_datos.py
└── data/
    ├── *.csv
    └── data_limpios/
        ├── *_limpio.csv (se crean al ejecutar 01_eda.ipynb, aunque se han dejado en el repositorio a modo de muestra)
        └── ...
```

Los CSV originales se conservan separados de los datasets limpios para mantener la trazabilidad del proceso de transformación.

## Ejecución

### 1. Preparar el entorno

Instalar Python y las dependencias necesarias:

```bash
pip install pandas numpy matplotlib seaborn psycopg2-binary jupyter
```

Abrir `01_eda.ipynb` y ejecutar las celdas desde el principio. El notebook carga los nueve datasets originales desde `data/`, realiza la exploración, limpieza y validación, y genera los CSV depurados en `data/data_limpios/`.

### 2. Creación de la BBDD en PostgreSQL

Crear una base de datos llamada `MetroBus` en PostgreSQL mediante pgAdmin.

Ejecutar `02_sql.sql` para crear las nueve tablas del modelo relacional, incluyendo claves primarias y foráneas.

El archivo también contiene las comprobaciones del modelo y las consultas de negocio de la fase SQL, por eso hay que ejecutarlo por partes.

### 3. Carga de datos

Modificar el ```.env.example```, para configurar las credenciales locales de PostgreSQL enlazadas en `cargar_datos.py` y ejecutar:

```bash
python cargar_datos.py
```

El script carga los nueve CSV limpios respetando el orden necesario para mantener la integridad referencial.

### 4. Power BI

Abrir ```04_dashboard.pbix``` con Power BI Desktop. El dashboard contiene páginas de portada, resumen ejecutivo, operaciones, demanda, flota y conductores, con KPIs y filtros para explorar el comportamiento de MetroBus durante el periodo analizado.

## Decisión técnica no obvia

Los valores `-99` encontrados en `retraso_salida_min` no se trataron simplemente como valores perdidos o un código de error interno de la empresa. Al disponer de la hora de salida programada y real, se reconstruyó el retraso mediante la diferencia entre ambas, conservando así información operativa en lugar de eliminar esos registros.

## Hallazgo principal

La demanda de MetroBus se mantiene relativamente estable durante el periodo analizado, aunque la línea 10 (N1) presenta un comportamiento claramente diferente al resto de la red, con un volumen de pasajeros notablemente inferior (-40,7%), dado que es la única nocturna. Además, el análisis muestra que un mayor número de incidencias no implica necesariamente mayores retrasos por línea, mientras que las intervenciones relacionadas con el motor destacan por su coste medio de mantenimiento.

## Gobierno y calidad del dato

Durante la preparación se documentaron los problemas de calidad detectados, sus frecuencias y las decisiones adoptadas. Se priorizó la reconstrucción determinista cuando existía información suficiente y se recurrió a imputaciones estadísticas cuando no era posible recuperar el valor de forma fiable.

El modelo final está compuesto por 9 tablas: 3 de hechos y 6 dimensiones. Durante la validación temporal del modelo analítico se identificaron además 47 registros de mantenimiento con fecha de entrada en 2025, fuera del periodo de análisis 2022–2024, que fueron excluidos del conjunto analítico.

### Documentación adicional
- **03_gobierno.md:** Diccionario de datos, Data Quality Log, definiciones de KPIs, reglas de gobierno y limitaciones.
- **05_PresentacionMetroBus.pdf:** Presentación final con los principales insights y conclusiones del proyecto.

## Uso de IA

<<<<<<< HEAD
Se ha utilizado IA a modo de apoyo para redactar la documentación (incluido este documento) así como revisar y auditar los documentos, para cumplir con todos los requisitos del proyecto. La selección, validación e interpretación de los datos, así como las decisiones finales del proyecto, han sido realizadas por el autor.
=======
Se ha utilizado IA a modo de apoyo para redactar la documentación (incluido este documento) así como revisar y auditar los documentos, para cumplir con todos los requisitos del proyecto. La selección, validación e interpretación de los datos, así como las decisiones finales del proyecto, han sido realizadas por el autor.
>>>>>>> 174c896e41ccb278452355c0c9edfd099eb7010a
