# Módulo de Simulación Psicométrica Monte Carlo (TRI)

Esta carpeta contiene los scripts en Python y R encargados de la generación de datos sintéticos bajo el paradigma de la **Teoría de Respuesta al Ítem (TRI)** multidimensional. El objetivo principal es simular una muestra representativa de evaluados ($N = 4000$) para validar y calibrar la estructura interna de la prueba vial.

---

## 🧮 Metodología de Simulación

El proceso de simulación genera respuestas dicotómicas basadas en el **Modelo Logístico de Tres Parámetros (3PL)** adaptado a un enfoque multidimensional *Between-Item*. 

### 1. Habilidades Latentes ($\theta$)
Las habilidades latentes de los sujetos se modelan a partir de una distribución normal multivariada:
$$\boldsymbol{\theta} \sim \text{MVN}(\boldsymbol{\mu}, \boldsymbol{\Sigma})$$

Donde $\boldsymbol{\mu} = [0, 0, 0]'$ y la matriz de covarianza latente es:
$$\boldsymbol{\Sigma} = \begin{pmatrix} 1.00 & 0.55 & 0.50 \\ 0.55 & 1.00 & 0.45 \\ 0.50 & 0.45 & 1.00 \end{pmatrix}$$

Para simular estas correlaciones, el script en Python implementa una **descomposición de Cholesky** de $\boldsymbol{\Sigma}$ sobre variables normales estándar independientes extraídas mediante el generador de números pseudoaleatorios `random.gauss` de Python, garantizando reproducibilidad exacta usando la semilla `2026`.

### 2. Generación de Respuestas Dicotómicas
Para cada sustentante $i$ en el reactivo $j$, la probabilidad de acierto ($P(Y_{ij} = 1)$) se calcula con la ecuación 3PL:
$$P(Y_{ij} = 1 | \theta_{id}) = c_j + \frac{1 - c_j}{1 + \exp[-a_j(\theta_{id} - b_j)]}$$

Donde $\theta_{id}$ es el rasgo latente en el factor en el que carga el reactivo ($D1$, $D2$ o $D3$) y los parámetros $a_j$, $b_j$ y $c_j$ corresponden al banco de reactivos real definido en `parametros_banco.csv`. Si un número uniforme aleatorio $U(0,1) < P(Y_{ij} = 1)$, se registra un acierto (1), de lo contrario un error (0).

---

## 📂 Estructura de la Carpeta y Catálogo de Scripts

### Scripts
- **`generar_datos.py`**: Script de producción principal escrito en Python. Lee los parámetros 3PL reales de `parametros_banco.csv` en el directorio raíz, simula los $N = 4000$ casos utilizando descomposición de Cholesky para los rasgos correlacionados, y guarda las bases resultantes.
- **`simulacion_irt.R`**: Script secundario escrito en R, utilizado para análisis diagnósticos rápidos, validación inicial del ajuste de la simulación y comprobación de la recuperación del rasgo latente.

### Archivos de Salida Producidos
- **`datos_simulados.csv`**: Base de datos de $4000 \times 54$ que contiene las respuestas binarias dicotómicas ($Y_{ij} \in \{0, 1\}$) de los 4000 participantes ficticios en los 54 reactivos.
- **`thetas_simuladas.csv`**: Tabla de habilidades reales que contiene las tres habilidades latentes ($\theta_{D1}$, $\theta_{D2}$, $\theta_{D3}$) de los 4000 sustentantes ficticios, utilizada como criterio de validación para la calibración posterior.

---

## 🚀 Instrucciones de Ejecución

Para regenerar de forma idéntica los datos simulados de la prueba vial:

1. Abra una terminal de comandos en el directorio raíz del proyecto.
2. Ejecute el comando:
   ```bash
   python Simulación/generar_datos.py
   ```
3. El script leerá el archivo `parametros_banco.csv` y reescribirá en esta carpeta los archivos `datos_simulados.csv` y `thetas_simuladas.csv`.
