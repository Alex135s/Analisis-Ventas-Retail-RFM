import pandas as pd
import os

# --- CONFIGURACIÓN ---
ruta_entrada = 'input/datos_crudos.csv'
ruta_salida = 'output/datos_limpios.csv'

print("1. Cargando los datos (esto puede tardar unos segundos)...")
# Cargamos el CSV. 'encoding' ayuda a leer caracteres especiales.
df = pd.read_csv(ruta_entrada, encoding='ISO-8859-1')

print(f"   -> Datos cargados. Filas originales: {df.shape[0]}")

# --- LIMPIEZA (TRANSFORMACIÓN) ---
print("2. Iniciando limpieza...")

# A. Eliminar nulos
# Si no tiene Customer ID, no nos sirve para el análisis de clientes.
df = df.dropna(subset=['Customer ID'])

# B. Eliminar duplicados
df = df.drop_duplicates()

# C. Filtrar devoluciones y errores
# Queremos solo ventas reales (Cantidad > 0) y precios positivos
df = df[(df['Quantity'] > 0) & (df['Price'] > 0)]

# --- INGENIERÍA DE VARIABLES (CREAR NUEVOS DATOS) ---
print("3. Creando nuevas columnas...")

# Calculamos el Total de la venta (Cantidad * Precio)
df['TotalVenta'] = df['Quantity'] * df['Price']

# Convertimos la columna de fecha a formato fecha real de Python
df['InvoiceDate'] = pd.to_datetime(df['InvoiceDate'])

print(f"   -> Limpieza terminada. Filas finales: {df.shape[0]}")

# --- EXPORTACIÓN (LOAD) ---
print("4. Guardando archivo limpio...")
df.to_csv(ruta_salida, index=False)

print(f"¡ÉXITO! Tu archivo limpio está en: {ruta_salida}")