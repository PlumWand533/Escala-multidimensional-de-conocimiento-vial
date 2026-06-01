# ==============================================================================
# SCRIPT DE SIMULACIÓN DE DATOS BAJO TEORÍA DE RESPUESTA AL ÍTEM (TRI)
# Proyecto: Diseño y Simulación Psicométrica de una Escala Multidimensional 
#           de Conocimiento Teórico Vial para Licencia Tipo A en la CDMX
# Curso: Taller de Investigación II - Facultad de Psicología, UNAM
# Hito: Hito 2 - Simulación Poblacional y Generación de Matriz de Respuestas
# ==============================================================================

# --- 1. Preparación del Entorno ---
# Instalar y cargar paquete para la generación de distribución normal multivariada
if (!requireNamespace("mvtnorm", quietly = TRUE)) {
  message("Instalando el paquete 'mvtnorm' requerido para la simulación...")
  install.packages("mvtnorm", repos = "https://cloud.r-project.org")
}
library(mvtnorm)

# Fijar semilla para garantizar la reproducibilidad exacta de la simulación
set.seed(2026)

# --- 2. Carga de Parámetros de los Reactivos ---
# Buscar el archivo de parámetros en el directorio de trabajo
csv_path <- "parametros_banco.csv"
if (!file.exists(csv_path)) {
  # Si el script se ejecuta dentro de la carpeta 'Simulación', subir un nivel
  csv_path <- "../parametros_banco.csv"
}

if (!file.exists(csv_path)) {
  stop("Error: No se encontró el archivo 'parametros_banco.csv'. Verifique la ruta del archivo.")
}

message("Cargando parámetros de reactivos desde: ", csv_path)
items_df <- read.csv(csv_path, header = TRUE, stringsAsFactors = FALSE)

# Mostrar resumen del banco de reactivos
message("Reactivos cargados por dimensión:")
print(table(items_df$dimension))

# --- 3. Especificación de Parámetros Poblacionales ---
N <- 4000 # Tamaño muestral propuesto

# Definir matriz de correlaciones latentes (Sigma) entre las tres dimensiones (TRI)
# D1: Normativa | D2: Señalización | D3: Seguridad y Razonamiento Situacional
Sigma <- matrix(c(
  1.00, 0.55, 0.50, # D1
  0.55, 1.00, 0.45, # D2
  0.50, 0.45, 1.00  # D3
), nrow = 3, ncol = 3)

colnames(Sigma) <- rownames(Sigma) <- c("D1", "D2", "D3")
mu <- c(0, 0, 0) # Medias poblacionales de las habilidades latentes (theta)

message("\nMatriz de correlaciones latentes propuesta (TRI):")
print(Sigma)

# --- 4. Simulación de Habilidades Latentes (Thetas) ---
message("\nGenerando habilidades latentes (thetas) para N = 4000 personas...")
thetas <- rmvnorm(N, mean = mu, sigma = Sigma)
colnames(thetas) <- c("theta_D1", "theta_D2", "theta_D3")

# --- 5. Generación de Respuestas bajo el Modelo TRI 3PL Multidimensional ---
# Estructura del modelo: Between-Item (Multi-Unidimensional de Estructura Simple)
# Cada ítem carga en una sola dimensión teórica:
# D1 (ítems 1-18), D2 (ítems 19-36), D3 (ítems 37-54)

n_items <- nrow(items_df)
respuestas_matrix <- matrix(NA, nrow = N, ncol = n_items)
colnames(respuestas_matrix) <- items_df$item

message("Simulando respuestas binarias bajo el modelo 3PL Between-Item...")
for (i in 1:n_items) {
  # Obtener los parámetros del ítem i
  dim_name <- items_df$dimension[i]
  a <- items_df$a[i]
  b <- items_df$b[i]
  c <- items_df$c[i]
  
  # Asignar la habilidad latente correspondiente de la persona según la dimensión del ítem
  if (dim_name == "D1") {
    theta_col <- 1
  } else if (dim_name == "D2") {
    theta_col <- 2
  } else if (dim_name == "D3") {
    theta_col <- 3
  } else {
    stop("Error: Dimensión desconocida '", dim_name, "' en el ítem ", items_df$item[i])
  }
  
  # Habilidad de las N personas para esta dimensión
  theta_i <- thetas[, theta_col]
  
  # Ecuación formal del modelo de 3 parámetros (3PL) en la métrica estándar logística (D = 1)
  # P(X = 1 | theta) = c + (1 - c) / (1 + exp(-a * (theta - b)))
  prob_correcto <- c + (1 - c) / (1 + exp(-a * (theta_i - b)))
  
  # Simulación de respuesta dicotómica mediante comparación con número pseudoaleatorio uniforme [0, 1]
  u <- runif(N)
  respuestas_matrix[, i] <- as.integer(u < prob_correcto)
}

# --- 6. Verificación Descriptiva de los Datos Simulados (Pura TRI) ---
message("\n--- Verificación Psicométrica de los Datos Simulados (TRI) ---")

# A. Correlación empírica de las habilidades latentes simuladas (Thetas)
cor_thetas_empirica <- cor(thetas)
message("Correlación empírica entre las habilidades latentes (theta) generadas:")
print(round(cor_thetas_empirica, 3))

# B. Análisis de Dificultad Empírica (Proporción de Aciertos / p-value) por dimensión
# En TRI, la proporción de respuestas correctas correlaciona inversamente con b_i
p_valores <- colMeans(respuestas_matrix)

message("\nPromedio de dificultad empírica (proporción de aciertos) por dimensión:")
for (dim in c("D1", "D2", "D3")) {
  items_dim <- which(items_df$dimension == dim)
  mean_p <- mean(p_valores[items_dim])
  min_p <- min(p_valores[items_dim])
  max_p <- max(p_valores[items_dim])
  message(sprintf("  Dimensión %s: Promedio = %.3f (Rango: %.3f - %.3f)", dim, mean_p, min_p, max_p))
}

# C. Asociación empírica entre el parámetro de dificultad b y la proporción de aciertos
cor_b_p <- cor(items_df$b, p_valores)
message(sprintf("\nCorrelación entre el parámetro de dificultad teórica 'b' y la proporción de aciertos: %.3f", cor_b_p))
message("(Nota: Una correlación negativa fuerte confirma que a mayor 'b' [dificultad], menor probabilidad de acierto).")

# D. Asociación empírica entre el parámetro de discriminación 'a' y la relación ítem-dimensión
# (Se evalúa mediante la correlación biserial puntual del ítem con la puntuación de su dimensión)
# Nota: La correlación biserial puntual es un descriptivo directo de los datos que en TRI
# se asocia positivamente con la magnitud de a_i.
item_total_cors <- numeric(n_items)
for (i in 1:n_items) {
  dim_name <- items_df$dimension[i]
  items_dim <- which(items_df$dimension == dim_name)
  # Puntuación observada en la dimensión (sin el ítem bajo análisis para evitar inflación)
  sum_score_dim <- rowSums(respuestas_matrix[, items_dim, drop = FALSE]) - respuestas_matrix[, i]
  item_total_cors[i] <- cor(respuestas_matrix[, i], sum_score_dim)
}
cor_a_itc <- cor(items_df$a, item_total_cors)
message(sprintf("Correlación entre el parámetro de discriminación teórica 'a' y la discriminación empírica: %.3f", cor_a_itc))

# --- 7. Exportación de Resultados ---
# Asegurar la existencia de la carpeta 'Simulación'
dir_simulacion <- "Simulación"
if (!dir.exists(dir_simulacion)) {
  dir.create(dir_simulacion, recursive = TRUE)
}

# Guardar matriz de respuestas simuladas
out_data_path <- file.path(dir_simulacion, "datos_simulados.csv")
write.csv(respuestas_matrix, out_data_path, row.names = FALSE)
message("\nMatriz de respuestas de 4000x54 guardada exitosamente en: ", out_data_path)

# Guardar las habilidades latentes simuladas (Thetas) para auditorías de la simulación
out_thetas_path <- file.path(dir_simulacion, "thetas_simuladas.csv")
write.csv(thetas, out_thetas_path, row.names = FALSE)
message("Habilidades latentes (thetas) guardadas exitosamente en: ", out_thetas_path)

message("\n==============================================================================")
message("SIMULACIÓN COMPLETADA Y REPRODUCIBLE")
message("==============================================================================")
