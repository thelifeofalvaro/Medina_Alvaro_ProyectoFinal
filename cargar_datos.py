import os
import pandas as pd
import psycopg2
from psycopg2.extras import execute_values
from dotenv import load_dotenv

load_dotenv()

# ============================================================
# CONFIGURACIÓN BBDD
# ============================================================

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "dbname": "MetroBus",
    "user": os.getenv("DB_USER"),
    "password": os.getenv("DB_PASSWORD")
}

BASE_DATA = "data/data_limpios"

# ============================================================
# CONEXIÓN BBDD
# ============================================================

def conectar_bd():
    try:
        conexion = psycopg2.connect(**DB_CONFIG)
        print("Conexión establecida con PostgreSQL")
        return conexion

    except psycopg2.Error as e:
        print("Error al conectar con PostgreSQL")
        print(e)
        return None


# ============================================================
# CARGA DE UNA TABLA
# ============================================================

def cargar_tabla(conexion, nombre_tabla, nombre_csv):
    ruta = os.path.join(BASE_DATA, nombre_csv)

    try:
        df = pd.read_csv(ruta)

        columnas = list(df.columns)
        columnas_sql = ", ".join(columnas)

        valores = [
            tuple(fila)
            for fila in df.itertuples(index=False, name=None)
        ]

        consulta = f"""
            INSERT INTO {nombre_tabla} ({columnas_sql})
            VALUES %s
        """

        with conexion.cursor() as cursor:
            execute_values(
                cursor,
                consulta,
                valores,
                page_size=1000
            )

        conexion.commit()

        print(
            f"{nombre_tabla}: "
            f"{len(df):,} registros cargados"
        )

    except Exception as e:
        conexion.rollback()
        print(f"Error cargando {nombre_tabla}")
        print(e)
        raise


# ============================================================
# CARGA PRINCIPAL
# ============================================================

def main():

    conexion = conectar_bd()

    if conexion is None:
        return

    try:

        # ----------------------------------------------------
        # 1. DIMENSIONES INDEPENDIENTES
        # ----------------------------------------------------

        cargar_tabla(
            conexion,
            "dim_depot",
            "dim_depot.csv"
        )

        cargar_tabla(
            conexion,
            "dim_linea",
            "dim_linea.csv"
        )

        cargar_tabla(
            conexion,
            "dim_parada",
            "dim_parada.csv"
        )

        cargar_tabla(
            conexion,
            "dim_tarifa",
            "dim_tarifa.csv"
        )

        # ----------------------------------------------------
        # 2. DIMENSIONES CON FK
        # ----------------------------------------------------

        cargar_tabla(
            conexion,
            "dim_vehiculo",
            "dim_vehiculo.csv"
        )

        cargar_tabla(
            conexion,
            "dim_conductor",
            "dim_conductor.csv"
        )

        # ----------------------------------------------------
        # 3. TABLAS DE HECHOS
        # ----------------------------------------------------

        cargar_tabla(
            conexion,
            "fact_viajes",
            "fact_viajes.csv"
        )

        cargar_tabla(
            conexion,
            "fact_incidencias",
            "fact_incidencias.csv"
        )

        cargar_tabla(
            conexion,
            "fact_mantenimiento",
            "fact_mantenimiento.csv"
        )

        print("\nCarga completa finalizada correctamente")

    except Exception:
        print("\nLa carga se ha detenido debido a un error")

    finally:
        conexion.close()
        print("Conexión cerrada")


# ============================================================
# EJECUCIÓN
# ============================================================

if __name__ == "__main__":
    main()