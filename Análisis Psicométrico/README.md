# Análisis Psicométrico (Modelos TRI)

Esta carpeta contiene los scripts en R y los productos resultantes del análisis psicométrico avanzado bajo el enfoque de la **Teoría de Respuesta al Ítem (TRI)**. El plan analítico calibra y contrasta un Modelo 3PL Unidimensional y un Modelo 3PL Multidimensional *Between-Item* con estructura tridimensional simple correlacionada.

## 📋 Requisitos del Entorno

Para ejecutar los scripts, asegúrese de contar con:
- **R (versión 4.5.1 o superior)**
- **Librerías de R:** `mirt`, `mvtnorm`, `ggplot2` (los scripts verifican y cargan estas dependencias automáticamente, instalándolas si es necesario).

---

## 🚀 Instrucciones de Uso

Los scripts deben ser ejecutados en la consola de comandos (PowerShell, Terminal o CMD) desde el directorio raíz del proyecto:

1. **Ejecutar el script principal de análisis y calibración**:
   ```bash
   & "C:\Program Files\R\R-4.5.1\bin\Rscript.exe" "Analisis psicometrico/analisis_psicometrico.R"
   ```
   *Este script calibrará los modelos 3PL, contrastará su ajuste comparativo y absoluto global, estimará las habilidades latentes (MAP) y los parámetros de los reactivos (QMCEM), y guardará los resultados en tablas CSV y archivos de reporte de texto.*

2. **Ejecutar el script de gráficos de CCI superpuestas**:
   ```bash
   & "C:\Program Files\R\R-4.5.1\bin\Rscript.exe" "Analisis psicometrico/generar_cci_superpuestas.R"
   ```
   *Este script secundario agrupa las 18 Curvas Características de los Ítems (CCI) por dimensión y las grafica de forma superpuesta en un solo panel para análisis clínico y comparativo.*

---

## 📦 Productos del Script (Qué Produce)

El script principal y el de graficación de CCIs guardan automáticamente los siguientes entregables en esta carpeta:

### Reportes de Texto (Ajuste del Modelo)
- **`comparacion_modelos.txt`**: Resultados detallados del contraste ANOVA de modelos anidados (Modelo A: Unidimensional vs. Modelo B: Multidimensional correlacionado). Incluye índices AIC, BIC, logLik y la prueba de Razón de Verosimilitud ($\chi^2$ LRT).
- **`ajuste_absoluto.txt`**: Estadísticos de ajuste absoluto global del modelo multidimensional mediante el estadístico $M_2^*$ (tipo C2 con integración Quasi-Monte Carlo), incluyendo el error cuadrático medio de aproximación (RMSEA), el residuo estándar cuadrático (SRMSR) y los índices CFI y TLI.

### Archivos de Datos (Tablas CSV)
- **`descriptivos_reactivos_CDMX.csv`**: Tabla descriptiva con la proporción observada de respuestas correctas (dificultad empírica o $p$-value) por reactivo, dimensión y subtema.
- **`parametros_estimados_mirt.csv`**: Resultados de la calibración que contiene los parámetros teóricos (poblacionales) comparados con los estimados de discriminación ($\hat{a}_j$), dificultad ($\hat{b}_j$) y pseudo-adivinación ($\hat{c}_j$) de cada reactivo.
- **`covarianza_latente_estimada_mirt.csv`**: Matriz de varianzas y covarianzas (correlaciones latentes) estimadas empíricamente entre los tres factores de la escala.
- **`informacion_test_mirt.csv`**: Vectores calculados del continuo de habilidad ($\theta$), información del test [$I(\theta)$] y error estándar de medida [$SE(\theta)$] para graficar el perfil de precisión por subescala.

### Gráficos Generados (`Graficos/`)
Se almacenan en la subcarpeta `Graficos/`:
- **`dificultad_empirica.png`**: Histograma comparativo de la proporción empírica de aciertos ($p$-values) agrupada por dimensión.
- **`distribucion_thetas.png`**: Gráfico de densidad que muestra la distribución empírica de las habilidades latentes estimadas en cada factor.
- **`funcion_informacion_test.png`**: Curva de la Función de Información del Test (FIT) agregada por dimensión.
- **`error_estandar_medida.png`**: Curva de Error Estándar de Medida (SEM) por dimensión con línea indicadora del umbral psicométrico de alta precisión (SEM = 0.50).
- **`cci_superpuestas_D1.png`**: Panel con las 18 curvas características de respuesta (CCI) superpuestas correspondientes a D1: Normativa.
- **`cci_superpuestas_D2.png`**: Panel con las 18 curvas características de respuesta (CCI) superpuestas correspondientes a D2: Señalización.
- **`cci_superpuestas_D3.png`**: Panel con las 18 curvas características de respuesta (CCI) superpuestas correspondientes a D3: Seguridad.

### Curvas Características Individuales (`Graficos/CCI/`)
- Dentro del directorio `Graficos/CCI/` se almacenan **54 imágenes individuales** (`cci_D1-S1-01.png` a `cci_D3-18.png`), cada una representando la CCI individual del reactivo con sus respectivos coeficientes de calibración, utilizadas para la interpretación psicométrica detallada en el manuscrito final.
