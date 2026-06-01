# ==============================================================================
# SCRIPT DE GENERACIÓN DE CURVAS CARACTERÍSTICAS DE LOS ÍTEMS (CCI) SUPERPUESTAS
# Proyecto: Escala Multidimensional de Conocimiento Teórico Vial - CDMX
# Hito: Hito 4 - Gráficos Integrados de CCI por Dimensión
# ==============================================================================

message("=== Generando Gráficos de CCI Superpuestas ===")

# Cargar librerías
library(ggplot2)

# Definir la ruta raíz absoluta
workspace_root <- "c:/Users/josha/OneDrive/Documentos/Antigravity tareas/Revisión documental Examen de Manejo-20260416T024141Z-3-001/Revisión documental Examen de Manejo"
output_dir <- file.path(workspace_root, "Analisis psicometrico")
graficos_dir <- file.path(output_dir, "Graficos")
csv_path <- file.path(output_dir, "parametros_estimados_mirt.csv")

if (!file.exists(csv_path)) {
  stop("Error: No se encontró el archivo de parámetros estimados en: ", csv_path)
}

# Leer parámetros
params <- read.csv(csv_path, check.names = FALSE)

# Rango de habilidad latente (Theta)
theta_seq <- seq(-4, 4, 0.05)
K <- length(theta_seq)

# Función matemática 3PL
prob_3pl <- function(theta, a, b, c) {
  c + (1 - c) / (1 + exp(-a * (theta - b)))
}

# Crear carpeta de gráficos si no existe
dir.create(graficos_dir, recursive = TRUE, showWarnings = FALSE)

# Paletas de colores curadas y elegantes para cada dimensión
# Dimensión 1: Azul-Púrpura
# Dimensión 2: Esmeralda-Bosque
# Dimensión 3: Terracota-Naranja

dimensiones <- c("D1", "D2", "D3")
nombres_dims <- c(
  "Dimensión 1: Conocimiento Normativo-Reglamentario",
  "Dimensión 2: Señalización y Jerarquía de Movilidad",
  "Dimensión 3: Seguridad Vial y Razonamiento Situacional"
)
colores_bases <- c("Blues", "Greens", "Oranges")
paletas_manuales <- list(
  D1 = colorRampPalette(c("#1c3d5a", "#3490dc", "#6cb2eb", "#a0aec0"))(18),
  D2 = colorRampPalette(c("#145214", "#248f24", "#5cd65c", "#b3f0b3"))(18),
  D3 = colorRampPalette(c("#7f1d1d", "#dc2626", "#f87171", "#fca5a5"))(18)
)

for (d_idx in 1:3) {
  dim_code <- dimensiones[d_idx]
  dim_name <- nombres_dims[d_idx]
  
  # Filtrar parámetros de la dimensión actual
  dim_params <- params[params$Dimension == dim_code, ]
  
  if (nrow(dim_params) == 0) {
    message("Advertencia: No se encontraron reactivos para la dimensión ", dim_code)
    next
  }
  
  # Construir data frame largo para ggplot
  plot_list <- list()
  for (i in 1:nrow(dim_params)) {
    item <- dim_params$Item[i]
    a <- dim_params$a_estimada[i]
    b <- dim_params$b_estimada[i]
    c <- dim_params$c_estimada[i]
    
    probs <- prob_3pl(theta_seq, a, b, c)
    plot_list[[i]] <- data.frame(
      Theta = theta_seq,
      Probabilidad = probs,
      Item = rep(item, K)
    )
  }
  df_dim <- do.call(rbind, plot_list)
  
  # Crear gráfico
  p <- ggplot(df_dim, aes(x = Theta, y = Probabilidad, color = Item)) +
    geom_line(linewidth = 0.9, alpha = 0.8) +
    theme_minimal(base_family = "sans") +
    scale_color_manual(values = paletas_manuales[[dim_code]]) +
    ylim(0, 1) +
    xlim(-4, 4) +
    labs(
      title = dim_name,
      subtitle = paste0("Modelo 3PL Multidimensional (Between-Item) - Calibración N = 4000\nSuperposición de las ", nrow(dim_params), " Curvas Características de los Ítems (CCI)"),
      x = expression(paste("Habilidad Latente (", theta, ")")),
      y = "Probabilidad de Acierto P(θ)",
      color = "Reactivo"
    ) +
    theme(
      plot.title = element_text(face = "bold", size = 13, color = "#2d3748", hjust = 0.5),
      plot.subtitle = element_text(size = 10, color = "#718096", hjust = 0.5, face = "italic"),
      axis.title = element_text(face = "bold", size = 10, color = "#2d3748"),
      axis.text = element_text(size = 9, color = "#4a5568"),
      legend.title = element_text(face = "bold", size = 9, color = "#2d3748"),
      legend.text = element_text(size = 8, color = "#4a5568"),
      legend.position = "right",
      panel.grid.major = element_line(linewidth = 0.2, color = "#e2e8f0"),
      panel.grid.minor = element_blank()
    ) +
    annotate("segment", x = -4, xend = 4, y = 0.5, yend = 0.5, linetype = "dashed", color = "#cbd5e0", linewidth = 0.5)
  
  # Guardar en alta definición
  file_name <- paste0("cci_superpuestas_", dim_code, ".png")
  file_path <- file.path(graficos_dir, file_name)
  ggsave(file_path, p, width = 8, height = 5.5, dpi = 300)
  message("Gráfico guardado en: ", file_path)
}

message("=== Proceso de Generación Completado ===")
