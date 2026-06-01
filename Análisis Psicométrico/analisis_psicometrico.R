# ==============================================================================
# SCRIPT DE ANÁLISIS PSICOMÉTRICO BAJO TEORÍA DE RESPUESTA AL ÍTEM (TRI)
# Proyecto: Diseño y Simulación Psicométrica de una Escala Multidimensional 
#           de Conocimiento Teórico Vial para Licencia Tipo A en la CDMX
# Curso: Taller de Investigación II - Facultad de Psicología, UNAM
# Hito: Hito 3 - Estimación de Modelos, Comparación y Curvas de Información
# ==============================================================================

# --- 1. Preparación del Entorno y Carga de Librerías ---
message("=== Paso 1: Preparación del Entorno ===")

# Instalar y cargar librerías necesarias
required_packages <- c("mirt", "mvtnorm", "ggplot2")
for (pkg in required_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    message("Instalando el paquete '", pkg, "' requerido...")
    install.packages(pkg, repos = "https://cloud.r-project.org")
  }
}
library(mirt)
library(mvtnorm)
library(ggplot2)

# Definir la ruta raíz absoluta del espacio de trabajo para evitar problemas de codificación de Windows
workspace_root <- "c:/Users/josha/OneDrive/Documentos/Antigravity tareas/Revisión documental Examen de Manejo-20260416T024141Z-3-001/Revisión documental Examen de Manejo"

# Crear directorios para salida de gráficos y tablas usando rutas absolutas
output_dir <- file.path(workspace_root, "Analisis psicometrico")
graficos_dir <- file.path(output_dir, "Graficos")
cci_dir <- file.path(graficos_dir, "CCI")

dir.create(cci_dir, recursive = TRUE, showWarnings = FALSE)
message("Directorios creados exitosamente en: ", output_dir)

# --- 2. Carga de Datos ---
message("\n=== Paso 2: Carga de Datos de la Simulación ===")

data_path <- file.path(workspace_root, "Simulación", "datos_simulados.csv")
thetas_path <- file.path(workspace_root, "Simulación", "thetas_simuladas.csv")
banco_path <- file.path(workspace_root, "parametros_banco.csv")

if (!file.exists(data_path) || !file.exists(thetas_path) || !file.exists(banco_path)) {
  stop("Error: No se encontraron los archivos simulados o el banco de parámetros. Verifique las rutas absolutas.")
}

# check.names = FALSE evita que R convierta guiones medios (-) en puntos (.)
data_responses <- read.csv(data_path, check.names = FALSE)
data_thetas <- read.csv(thetas_path, check.names = FALSE)
items_banco <- read.csv(banco_path, check.names = FALSE)

message("Base de datos de respuestas cargada: ", nrow(data_responses), " personas, ", ncol(data_responses), " reactivos.")
message("Base de habilidades latentes (theta) cargada: ", nrow(data_thetas), " casos.")

# --- 3. Análisis Descriptivo (Enfoque Exclusivo TRI) ---
message("\n=== Paso 3: Análisis Descriptivo de los Datos ===")

# A. Descriptivos de Dificultad Empírica (Proporción de Aciertos)
p_values <- colMeans(data_responses)
descriptivos_df <- data.frame(
  Item = colnames(data_responses),
  Dimension = items_banco$dimension,
  Subtema = items_banco$subtema,
  Nivel_Cognitivo = items_banco$nivel_cognitivo,
  Dificultad_Empirica = p_values
)

write.csv(descriptivos_df, file.path(output_dir, "descriptivos_reactivos_CDMX.csv"), row.names = FALSE)
message("Estadísticos descriptivos de los reactivos guardados en descriptivos_reactivos_CDMX.csv")

# B. Graficación de la Dificultad Empírica
png(file.path(graficos_dir, "dificultad_empirica.png"), width = 800, height = 600, res = 120)
p1 <- ggplot(descriptivos_df, aes(x = Dificultad_Empirica, fill = Dimension)) +
  geom_histogram(binwidth = 0.05, color = "black", alpha = 0.7, position = "dodge") +
  theme_minimal() +
  scale_fill_brewer(palette = "Set2") +
  labs(
    title = "Distribución de la Dificultad Empírica por Dimensión",
    subtitle = "Proporción de aciertos por reactivo (N = 4000)",
    x = "Proporción de Aciertos (p-value)",
    y = "Frecuencia de Reactivos",
    fill = "Dimensión"
  ) +
  theme(plot.title = element_text(face = "bold", size = 14))
print(p1)
dev.off()
message("Gráfico de dificultad empírica guardado.")

# C. Graficación de la Distribución de las Habilidades Latentes (Theta)
png(file.path(graficos_dir, "distribucion_thetas.png"), width = 1000, height = 600, res = 120)
thetas_long <- data.frame(
  Persona = rep(1:nrow(data_thetas), 3),
  Dimension = rep(c("D1: Normativa", "D2: Señalización", "D3: Seguridad"), each = nrow(data_thetas)),
  Theta = c(data_thetas$theta_D1, data_thetas$theta_D2, data_thetas$theta_D3)
)

p2 <- ggplot(thetas_long, aes(x = Theta, fill = Dimension)) +
  geom_density(alpha = 0.5, color = "black") +
  theme_minimal() +
  scale_fill_brewer(palette = "Set1") +
  labs(
    title = "Distribución Empírica de las Habilidades Latentes (Theta)",
    subtitle = "Rasgos latentes simulados multivariados (N = 4000)",
    x = expression(paste("Habilidad Latente (", theta, ")")),
    y = "Densidad",
    fill = "Dimensión"
  ) +
  theme(plot.title = element_text(face = "bold", size = 14))
print(p2)
dev.off()
message("Gráfico de distribución de thetas guardado.")

# --- 4. Calibración y Estimación de Modelos TRI ---
message("\n=== Paso 4: Ajuste de Modelos de TRI ===")

# A. Modelo A: 3PL Unidimensional
message("\nAjustando Modelo A: 3PL Unidimensional (F = 1 - 54)...")
fit_uni <- mirt(
  data = data_responses, 
  model = 1, 
  itemtype = "3PL", 
  technical = list(NCYCLES = 2000), 
  verbose = TRUE
)

# B. Modelo B: 3PL Multidimensional (Between-Item, 3 factores correlacionados)
message("\nAjustando Modelo B: 3PL Multidimensional Between-Item (Estructura Simple)...")
spec_multi <- mirt.model("
  D1 = 1-18
  D2 = 19-36
  D3 = 37-54
  COV = D1*D2, D1*D3, D2*D3
")

fit_multi <- mirt(
  data = data_responses, 
  model = spec_multi, 
  itemtype = "3PL", 
  method = "QMCEM",
  technical = list(NCYCLES = 2000), 
  verbose = TRUE
)

# --- 5. Comparación Estadística de Modelos ---
message("\n=== Paso 5: Comparación Estadística de Modelos ===")

comp <- anova(fit_uni, fit_multi)
print(comp)

# Capturar y guardar la salida de la comparación en archivo de texto
sink(file.path(output_dir, "comparacion_modelos.txt"))
cat("========================================================================\n")
cat("COMPARACIÓN DE MODELOS DE MEDICIÓN - HITO 3\n")
cat("========================================================================\n\n")
print(comp)
cat("\nInterpretación:\n")
cat("AIC y BIC menores favorecen al mejor modelo en términos de parsimonia y ajuste.\n")
cat("La prueba de Razón de Verosimilitud (LRT) evalúa si la mejora es estadísticamente significativa.\n")
sink()
message("Tabla de comparación de modelos guardada.")

# --- 6. Reporte de Parámetros Estimados del Modelo Seleccionado ---
message("\n=== Paso 6: Extracción de Parámetros del Modelo Seleccionado (Modelo B) ===")

# Extraer parámetros en métrica de TRI tradicional (IRTpars = TRUE)
params_multi <- coef(fit_multi, IRTpars = TRUE, simplify = TRUE)
items_estimated <- as.data.frame(params_multi$items)

# mirt multidimensional simplificado retorna: a1, a2, a3, b, g, u (6 columnas)
colnames(items_estimated) <- c("a1", "a2", "a3", "b_est", "c_est", "u_est")

# Mapear la discriminación estimada (a_estimada) al factor correspondiente para cada ítem
a_estimada <- numeric(nrow(items_estimated))
for (i in 1:nrow(items_estimated)) {
  dim <- items_banco$dimension[i]
  if (dim == "D1") {
    a_estimada[i] <- items_estimated$a1[i]
  } else if (dim == "D2") {
    a_estimada[i] <- items_estimated$a2[i]
  } else if (dim == "D3") {
    a_estimada[i] <- items_estimated$a3[i]
  }
}

clean_est <- data.frame(
  Item = rownames(items_estimated),
  a_estimada = a_estimada,
  b_estimada = items_estimated$b_est,
  c_estimada = items_estimated$c_est
)

# Fusionar con los parámetros teóricos para evaluar la calidad de recuperación
params_comparacion <- merge(
  descriptivos_df, 
  items_banco[, c("item", "a", "b", "c")], 
  by.x = "Item", 
  by.y = "item"
)
params_comparacion <- merge(params_comparacion, clean_est, by = "Item")

# Reordenar columnas para legibilidad
params_comparacion <- params_comparacion[, c(
  "Item", "Dimension", "Subtema", "Nivel_Cognitivo", "Dificultad_Empirica",
  "a", "a_estimada", "b", "b_estimada", "c", "c_estimada"
)]

write.csv(params_comparacion, file.path(output_dir, "parametros_estimados_mirt.csv"), row.names = FALSE)
message("Parámetros estimados guardados en parametros_estimados_mirt.csv")

# Extraer matriz de covarianza y correlación latente del modelo
cov_latente <- params_multi$cov
write.csv(cov_latente, file.path(output_dir, "covarianza_latente_estimada_mirt.csv"))
message("Matriz de covarianza latente estimada guardada.")
print(cov_latente)

# --- 7. Generación de Curvas Características de los Ítems (CCI) ---
message("\n=== Paso 7: Generación de Curvas Características de los Ítems (CCI) ===")

# Para evitar los conflictos de gráficos 3D en itemplot para modelos multidimensionales
# graficamos las curvas características de forma directa y limpia usando ggplot2 
# con los parámetros de discriminación (a), dificultad (b) y adivinación (c) estimados.
theta_seq <- seq(-4, 4, 0.01)

for (i in 1:nrow(params_comparacion)) {
  item_code <- params_comparacion$Item[i]
  a <- params_comparacion$a_estimada[i]
  b <- params_comparacion$b_estimada[i]
  c <- params_comparacion$c_estimada[i]
  dim <- params_comparacion$Dimension[i]
  subtema <- params_comparacion$Subtema[i]
  
  # Probabilidad de respuesta correcta bajo la fórmula del modelo 3PL
  p_theta <- c + (1 - c) / (1 + exp(-a * (theta_seq - b)))
  
  df_cci <- data.frame(Theta = theta_seq, Probabilidad = p_theta)
  
  # Determinar color según dimensión
  dim_color <- "#1f77b4" # Azul para D1
  if (dim == "D2") dim_color <- "#2ca02c" # Verde para D2
  if (dim == "D3") dim_color <- "#d62728" # Rojo para D3
  
  png(file.path(cci_dir, paste0("cci_", item_code, ".png")), width = 800, height = 600, res = 120)
  
  p_item <- ggplot(df_cci, aes(x = Theta, y = Probabilidad)) +
    geom_line(color = dim_color, linewidth = 1.3) +
    geom_hline(yintercept = c, linetype = "dashed", color = "darkgray") +
    geom_vline(xintercept = b, linetype = "dotted", color = "darkgray") +
    theme_minimal() +
    ylim(0, 1) +
    labs(
      title = paste("Curva Característica del Ítem (3PL) -", item_code),
      subtitle = paste0("Dimensión: ", dim, " (", subtema, ") | a = ", round(a, 2), ", b = ", round(b, 2), ", c = ", round(c, 2)),
      x = expression(paste("Habilidad Latente (", theta, ")")),
      y = "Probabilidad de Respuesta Correcta (P)"
    ) +
    theme(
      plot.title = element_text(face = "bold", size = 12, hjust = 0.5),
      plot.subtitle = element_text(size = 9, hjust = 0.5)
    )
  print(p_item)
  dev.off()
}

message("Se generaron las 54 Curvas Características de los Ítems exitosamente usando ggplot2.")

# --- 8. Análisis e Información del Test por Dimensión ---
message("\n=== Paso 8: Generación de la Función de Información del Test (FIT) ===")

# Definir rango de habilidad para evaluar la información del test
theta_seq <- seq(-4, 4, 0.01)
K <- length(theta_seq)

# Función matemática para calcular información de un ítem 3PL de forma exacta
calc_3pl_info <- function(theta, a, b, c) {
  p_star <- 1 / (1 + exp(-a * (theta - b)))
  p <- c + (1 - c) * p_star
  # Evitar divisiones por cero o valores indeterminados
  p[p <= 0] <- 1e-5
  p[p >= 1] <- 1 - 1e-5
  info <- (a^2) * ((1 - c) / (1 - p)) * (p_star^2 / p)
  info[is.nan(info) | is.infinite(info)] <- 0
  return(info)
}

# Calcular la información agregada para cada dimensión (FIT) sumando la información matemática de sus ítems
info_D1 <- numeric(K)
info_D2 <- numeric(K)
info_D3 <- numeric(K)

for (i in 1:nrow(params_comparacion)) {
  dim <- params_comparacion$Dimension[i]
  a <- params_comparacion$a_estimada[i]
  b <- params_comparacion$b_estimada[i]
  c <- params_comparacion$c_estimada[i]
  
  info_item <- calc_3pl_info(theta_seq, a, b, c)
  
  if (dim == "D1") {
    info_D1 <- info_D1 + info_item
  } else if (dim == "D2") {
    info_D2 <- info_D2 + info_item
  } else if (dim == "D3") {
    info_D3 <- info_D3 + info_item
  }
}

# Crear data frame para graficar las FITs conjuntamente
info_df <- data.frame(
  Theta = rep(theta_seq, 3),
  Dimension = rep(c("D1: Conocimiento Normativo", "D2: Señalización y Jerarquía", "D3: Seguridad Vial"), each = K),
  Informacion = c(info_D1, info_D2, info_D3),
  Error_Estandar = 1 / sqrt(c(info_D1, info_D2, info_D3))
)

write.csv(info_df, file.path(output_dir, "informacion_test_mirt.csv"), row.names = FALSE)

# Graficar la Función de Información del Test (FIT) por Dimensión
png(file.path(graficos_dir, "funcion_informacion_test.png"), width = 900, height = 600, res = 120)
p3 <- ggplot(info_df, aes(x = Theta, y = Informacion, color = Dimension)) +
  geom_line(linewidth = 1.2) +
  theme_minimal() +
  scale_color_brewer(palette = "Set1") +
  labs(
    title = "Función de Información del Test (FIT) por Dimensión",
    subtitle = "Precisión de la prueba a lo largo del continuo de habilidad (3PL)",
    x = expression(paste("Habilidad Latente (", theta, ")")),
    y = "Información del Test [I(theta)]",
    color = "Subescala"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )
print(p3)
dev.off()
message("Gráfico de Función de Información del Test guardado.")

# Graficar el Error Estándar de Medida (SEM) por Dimensión
png(file.path(graficos_dir, "error_estandar_medida.png"), width = 900, height = 600, res = 120)
p4 <- ggplot(info_df, aes(x = Theta, y = Error_Estandar, color = Dimension)) +
  geom_line(linewidth = 1.2) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "darkgray") + # Umbral de SEM = 0.5
  theme_minimal() +
  scale_color_brewer(palette = "Set1") +
  ylim(0, 2) +
  labs(
    title = "Error Estándar de Medida (SEM) por Dimensión",
    subtitle = "Incertidumbre en la estimación de la habilidad (Línea discontinua: SEM = 0.50)",
    x = expression(paste("Habilidad Latente (", theta, ")")),
    y = "Error Estándar [SE(theta)]",
    color = "Subescala"
  ) +
  theme(
    plot.title = element_text(face = "bold", size = 14),
    legend.position = "bottom"
  )
print(p4)
dev.off()
message("Gráfico de Error Estándar de Medida guardado.")

# --- 9. Evaluación del Ajuste Absoluto del Modelo (M2*) ---
message("\n=== Paso 9: Evaluación del Ajuste Absoluto del Modelo ===")
ajuste_abs <- M2(fit_multi, type = "C2", QMC = TRUE, verbose = TRUE)
print(ajuste_abs)

sink(file.path(output_dir, "ajuste_absoluto.txt"))
cat("========================================================================\n")
cat("AJUSTE ABSOLUTO DEL MODELO MULTIDIMENSIONAL (M2*) - HITO 3\n")
cat("========================================================================\n\n")
print(ajuste_abs)
sink()
message("Ajuste absoluto M2* guardado.")

message("\n==============================================================================")
message("ANÁLISIS PSICOMÉTRICO COMPLETADO CON ÉXITO")
message("==============================================================================")
