# MetroBus Analytics — Álvaro Medina

Proyecto de análisis de datos para una empresa ficticia de transporte urbano, desarrollado a través de un flujo completo de análisis, modelado relacional, gobierno del dato y posterior visualización.

## Stack tecnológico

- **Python 3.14.0** — análisis y preparación de datos.
- **Pandas** — carga, transformación, limpieza y análisis de los datasets.
- **NumPy** — operaciones y tratamiento numérico.
- **Matplotlib / Seaborn** — visualización exploratoria.
- **PostgreSQL** — base de datos relacional.
- **pgAdmin 4** — administración y ejecución de consultas SQL.
- **psycopg2** — conexión entre Python y PostgreSQL.
- **Jupyter Notebook** — desarrollo del EDA.
- **Power BI** — herramienta BI prevista.

## Estructura del proyecto

```text
├── 01_eda.ipynb
├── 02_sql.sql
├── 03_gobierno.md
├── cargar_datos.py
└── data/
    ├── *.csv
    └── data_limpios/
        ├── *_limpio.csv
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

### 2. Preparar PostgreSQL

Crear una base de datos llamada `MetroBus` en PostgreSQL mediante pgAdmin.

Ejecutar `02_sql.sql` para crear las nueve tablas del modelo relacional, incluyendo claves primarias y foráneas.

Hacerlo por partes, ya que también se encuentran en el archivo consultas de negocio.

### 3. Cargar los datos

Configurar las credenciales locales de PostgreSQL en `cargar_datos.py` y ejecutar:

```bash
python cargar_datos.py
```

El script carga los nueve CSV limpios respetando el orden necesario para mantener la integridad referencial.

## Decisión técnica no obvia

Los valores `-99` encontrados en `retraso_salida_min` no se trataron simplemente como valores perdidos o un código de error interno de la empresa. Al disponer de la hora de salida programada y real, se reconstruyó el retraso mediante la diferencia entre ambas, conservando así información operativa en lugar de eliminar esos registros.

## Hallazgo principal

La demanda de MetroBus se mantiene relativamente estable durante el periodo analizado, aunque la línea 10 presenta un comportamiento claramente diferente al resto de la red, con un volumen de pasajeros notablemente inferior, dado que es la única nocturna. Además, el análisis muestra que un mayor número de incidencias no implica necesariamente mayores retrasos por línea, mientras que las intervenciones relacionadas con el motor destacan por su coste medio de mantenimiento.

## Uso de IA

Se ha utilizado IA a modo de apoyo para redactar la documentación (incluido este documento), manteniendo la autoría del código y las decisiones del proyecto.