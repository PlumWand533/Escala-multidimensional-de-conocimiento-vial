# Escala Multidimensional de Conocimiento Teórico Vial - CDMX 🚗 🇲🇽

[![R Version](https://img.shields.io/badge/R-4.5.1+-blue.svg)](https://www.r-project.org/)
[![Python Version](https://img.shields.io/badge/Python-3.10+-green.svg)](https://www.python.org/)
[![APA Style](https://img.shields.io/badge/APA-7th%20Edition-red.svg)](https://apastyle.apa.org/)
[![Status](https://img.shields.io/badge/Status-Completed-success.svg)](#)

Este repositorio alberga el ecosistema completo de investigación y desarrollo técnico correspondiente al proyecto: **"Diseño y Simulación Psicométrica de una Escala Multidimensional de Conocimiento Teórico Vial para Aspirantes a Licencia de Conducir Tipo A en la Ciudad de México"**. 

El proyecto adopta un enfoque híbrido de vanguardia que combina:
1. **Auditoría y Revisión Documental Exhaustiva:** Análisis crítico del marco legal, plataforma tecnológica de la ADIP y SEMOVI, procesos legislativos del Congreso de la CDMX, y brechas de transparencia respecto al examen de licencia.
2. **Modelamiento Psicométrico Avanzado (TRI):** Diseño, simulación por método Monte Carlo ($N = 4000$) y calibración empírica mediante la **Teoría de Respuesta al Ítem (TRI) Multidimensional *Between-Item*** de una escala teórica de 54 reactivos estructurada en 3 dimensiones de competencia vial.

---

## 📂 Estructura del Repositorio

El repositorio está organizado sistemáticamente de la siguiente manera:

```bash
├── 📄 Manuscrito_final.Rmd         # Manuscrito académico en RMarkdown
├── 📄 Manuscrito_final0.pdf        # PDF compilado con el manuscrito académico
├── 📄 README.md                    # Documento principal del repositorio
│
├── 📁 Simulación/                   # Módulo de generación de datos por simulación Monte Carlo
│   ├── 📄 generar_datos.py         # Script Python para la simulación Monte Carlo (N=4000)
│   ├── 📄 simulacion_irt.R         # Script R complementario para diagnósticos iniciales
│   └── 📄 README.md                # Documentación del modelo de simulación
│
└── 📁 Análisis Psicométrico/       # Módulo de calibración psicométrica con mirt en R
    ├── 📄 analisis_psicometrico.R  # Script R principal de calibración (QMCEM) y ajuste
    ├── 📄 generar_cci_superpuestas.R # Script R de curvas características superpuestas
    ├── 📄 ajuste_absoluto.txt      # Estadístico global M2* y reporte de ajuste absoluto
    ├── 📄 comparacion_modelos.txt  # Comparación de modelos LRT (Uni vs Multidimensional)
    ├── 📄 parametros_estimados_mirt.csv  # Parámetros 3PL y proporciones empíricas calibradas
    ├── 📄 covarianza_latente_estimada_mirt.csv # Matriz de covarianza latente estimada
    ├── 📄 informacion_test_mirt.csv # Información total y errores estándar calculados
    ├── 📄 README.md                # Instrucciones y guía del análisis psicométrico
    └── 📁 Graficos/                # Curvas CCI y visualizaciones de calibración (PNG)
```

---

## 🚘 Fase 1: Auditoría Documental y de Políticas Públicas

La primera sección del repositorio detalla la revisión crítica de la implementación del examen teórico para la obtención de la licencia de conducir en la CDMX. Los hallazgos revelan brechas cruciales:
* **Conflicto Normativo:** La Ciudad de México solo evalúa el componente **teórico**, omitiendo las evaluaciones **práctica** e **integral** que son obligatorias y de carácter vinculante de acuerdo con la **Ley General de Movilidad y Seguridad Vial (LGMSV)** federal de 2022.
* **Opacidad Psicométrica:** No existen datos, informes o metodologías de acceso público sobre la validez, confiabilidad, libre de sesgo o nivel de discriminación del banco de reactivos operado por la SEMOVI y la ADIP.
* **Exclusión Legislativa:** El proceso legislativo para revivir la licencia permanente en la CDMX se centró prioritariamente en la recaudación fiscal (reforma al Artículo 229 del Código Fiscal local), marginando a la Comisión de Movilidad Sustentable del dictamen y desoyendo las demandas ciudadanas de un examen práctico presencial.

---

## 📊 Fase 2: Modelamiento Psicométrico y Simulación

Para responder a estos vacíos, este proyecto propone una **Escala Multidimensional de 54 Reactivos** de opción múltiple estructurada en 3 dimensiones correlacionadas bajo el **Modelo de 3 Parámetros (3PL) Multidimensional *Between-Item***:

1. **Dimensión 1 (D1): Conocimiento Normativo-Reglamentario (18 ítems):** Reglas de tránsito, velocidades y prioridades de paso.
2. **Dimensión 2 (D2): Señalización y Jerarquía de Movilidad (18 ítems):** Identificación visual de señales y aplicación de la Pirámide de Movilidad en cruces.
3. **Dimensión 3 (D3): Seguridad Vial y Razonamiento Situacional (18 ítems):** Manejo defensivo, conducción en condiciones adversas y predicción de peligros.

### Resultados Clave de la Calibración:
* **Superioridad Multidimensional:** El modelo tridimensional correlacionado superó categóricamente al modelo unidimensional tradicional:
  * Reducción significativa de criterios de información: $\Delta\text{AIC} = 2,409.9$, $\Delta\text{BIC} = 2,390.9$.
  * Prueba de Razón de Verosimilitud (LRT): $\chi^2(3) = 2415.8, p < 0.0001$.
* **Excelente Ajuste Absoluto Global:** El modelo multidimensional demostró un ajuste absoluto perfecto:
  * $M_2^* = 1383.137, \text{gl} = 1320, p = 0.111$ (donde $p > 0.05$ indica que el modelo describe de forma exacta la matriz de datos observados).
  * $\text{RMSEA} = 0.003$ [IC 90%: 0.000, 0.005].
  * $\text{SRMSR} = 0.015$; $\text{TLI} = 0.998$; $\text{CFI} = 0.998$.
* **Recuperación Altamente Precisa:** Correlación entre los parámetros poblacionales (reales) y los estimados mediante el algoritmo QMCEM:
  * Dificultad ($b_j$): $r = 0.982$
  * Discriminación ($a_j$): $r = 0.925$
  * Adivinación ($c_j$): $r = 0.897$

---

## 🚀 Guía de Ejecución y Replicación

Para replicar el estudio completo (generación de datos, calibración psicométrica y compilación del reporte), sigue estos pasos:

### 1. Prerrequisitos
Asegúrate de contar con R y Python en tu sistema. Instala los paquetes requeridos:

**En Python:**
```bash
pip install numpy pandas scipy
```

**En R:**
```R
install.packages(c("mirt", "tidyverse", "rmarkdown", "knitr", "ggplot2", "reshape2"))
```

### 2. Ejecutar la Simulación Monte Carlo (Fase Generativa)
Genera la base de respuestas binarias de $N = 4000$ participantes virtuales con base en la estructura latente multivariada:
```bash
python Simulación/generar_datos.py
```
*Esto producirá los archivos `datos_simulados.csv` y `thetas_simuladas.csv` en el directorio `Simulación/`.*

### 3. Calibrar el Modelo Psicométrico y Exportar Gráficos
Ejecuta el script principal en R para calibrar el modelo 3PL Multidimensional con el algoritmo QMCEM, calcular estadísticas de ajuste y exportar los parámetros estimados:
```bash
Rscript "Análisis Psicométrico/analisis_psicometrico.R"
```
Seguido de esto, genera las curvas características superpuestas por dimensión:
```bash
Rscript "Análisis Psicométrico/generar_cci_superpuestas.R"
```
*Los resultados y gráficos se guardarán en `Análisis Psicométrico/` y `Análisis Psicométrico/Graficos/`.*

### 4. Compilar el Manuscrito Final (PDF / HTML / Word)
Compila el documento final de investigación redactado con formato riguroso de la APA 7.ª edición (incluye de forma automatizada las tablas de resultados, los gráficos de las CCI clave generados y el banco de reactivos formateado):
```bash
Rscript -e "rmarkdown::render('Manuscrito_final.Rmd', output_format=c('pdf_document', 'html_document'))"
```
*(Nota: Para la salida en PDF, se requiere contar con una distribución de LaTeX instalada en el sistema como TinyTeX, MiKTeX o TeX Live).*

---

## 🛠️ Tecnologías Utilizadas

* **Lenguajes:** R (v4.5.1+) y Python (v3.10+).
* **Motor Psicométrico:** Paquete `mirt` (Multidimensional Item Response Theory) en R, utilizando algoritmos Quasi-Monte Carlo EM (QMCEM).
* **Generación Sintética:** `numpy` y `scipy` para simulación de vectores normales multivariados correlacionados y funciones logísticas de tres parámetros.
* **Edición Académica:** RMarkdown, XeLaTeX (para soporte tipográfico avanzado, tablas profesionales y renderizado de fórmulas matemáticas complejas), y Pandoc.

---

## 📄 Citación

Si utilizas el código, los reactivos de la escala o los resultados de la auditoría legal de este repositorio para fines académicos o profesionales, por favor cítalo como:

```bibtex
@article{examen_manejo_cdmx_2026,
  author = {Flores-Malvaez, Aldrich Iván and Martínez-Serrano, Axel Joel},
  title = {Diseño y Simulación Psicométrica de una Escala Multidimensional de Conocimiento Teórico Vial para Aspirantes a Licencia de Conducir Tipo A en la Ciudad de México},
  year = {2026},
  journal = {Proyecto Integrador - Modelos Psicométricos Avanzados},
  address = {Ciudad de México}
}
```

---
*Desarrollado por **Axel Joel Martínez Serrano** y **Aldrich Iván Flores Malvaez** para el curso de **Modelos Psicométricos: Tópicos Selectos (Taller de Investigación II)** bajo la asesoría del Dr. Ramsés Vázquez-Lira y el Lic. Yemil Caleano Becerril. Ciudad de México, 2026.*
