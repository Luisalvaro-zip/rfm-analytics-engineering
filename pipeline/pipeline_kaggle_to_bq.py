import pandas as pd
from google.cloud import bigquery
from kaggle.api.kaggle_api_extended import KaggleApi
import os
import zipfile

def extraer_kaggle_y_cargar_bq():
    # 1. AUTENTICACIÓN Y DESCARGA
    print("1. Conectando a Kaggle...")
    try:
        api = KaggleApi()
        api.authenticate()
    except Exception as e:
        print(f"Error de autenticación: {e}")
        return

    dataset_kaggle = "mathchi/online-retail-ii-data-set-from-ml-repository"
    nombre_archivo = "online_retail_II.xlsx" 
    
    print(f"Descargando {nombre_archivo} de Kaggle...")
    api.dataset_download_file(dataset_kaggle, nombre_archivo, path='.')

    # 2. LECTURA Y PREPARACIÓN (PANDAS)
    print("2. Procesando archivo descargado...")
    archivo_zip = f"{nombre_archivo}.zip"
    
    if os.path.exists(archivo_zip):
        with zipfile.ZipFile(archivo_zip, 'r') as zip_ref:
            zip_ref.extractall('.')
            print(f"Archivo {archivo_zip} descomprimido.")

    print(f"Leyendo {nombre_archivo} en Pandas (esto puede tardar)...")
    df = pd.read_excel(nombre_archivo, engine='openpyxl')
    
    # Normalizamos nombres de columnas
    df.columns = [c.replace(' ', '_').replace('/', '_').lower() for c in df.columns]

    # BLINDAJE DE TIPOS (Evita el error de PyArrow)
    print("Corrigiendo tipos de datos y nulos para BigQuery...")
    columnas_a_asegurar = ['invoice', 'stockcode', 'description', 'customer_id', 'country']
    
    for col in columnas_a_asegurar:
        if col in df.columns:
            df[col] = df[col].astype(str).replace('nan', '').replace('None', '')
    
    print("Columnas de texto blindadas.")

    # 3. CARGA A GOOGLE BIGQUERY
    print("3. Subiendo datos a BigQuery...")
    client = bigquery.Client(project='ga4-project-496021') 
    table_id = 'ga4-project-496021.ga4_data.retail_online_raw' 
    
    job_config = bigquery.LoadJobConfig(
        write_disposition="WRITE_TRUNCATE", 
        autodetect=True, 
    )

    job = client.load_table_from_dataframe(df, table_id, job_config=job_config)
    job.result() 
    
    print(f"¡Éxito TOTAL! Se cargaron {job.output_rows} filas en {table_id}.")

    # 4. LIMPIEZA
    for ext in ['', '.zip']:
        path_to_remove = f"{nombre_archivo}{ext}"
        if os.path.exists(path_to_remove):
            os.remove(path_to_remove)
            print(f"Temporal {path_to_remove} eliminado.")

# --- ESTO DEBE ESTAR AL FINAL Y SIN ESPACIOS A LA IZQUIERDA ---
if __name__ == "__main__":
    extraer_kaggle_y_cargar_bq()