library(shiny)

parametros_locales <- data.frame(
  codigo_iccat = c("BUM", "SFA", "WHM", "SKJ"),
  nombre       = c("Aguja Azul", "Pez Vela", "Aguja Blanca", "Atún Listado"),
  n            = c(297, 2553, 191, 1033),
  peso_medio   = c(66.5, 16.7, 23.2, 6.37),
  se_peso      = c(2.11, 0.0554, 0.633, 0.200),
  p10          = c(32.9, 13.4, 17.0, 3.0),
  p50          = c(57.2, 16.0, 22.0, 5.3),
  p90          = c(114.0, 20.0, 30.0, 10.0)
)

ui <- fluidPage(
  titlePanel("Calculadora de Remoción: Zona Central"),
  sidebarLayout(
    sidebarPanel(
      h4("1. Selección de Recurso"),
      selectInput("especie", "Especie Capturada:",
                  choices = c("Aguja Azul (BUM)"   = "BUM",
                              "Aguja Blanca (WHM)" = "WHM",
                              "Pez Vela (SFA)"     = "SFA",
                              "Atún Listado (SKJ)" = "SKJ")),
      
      numericInput("kilos_totales", "Masa Total Desembarcada (kg):", 
                   value = 1000, min = 1),
      hr(),
      
      h4("2. Estado de Presentación Comercial"),
      radioButtons("estado", "Seleccione cómo se registró el peso en muelle:",
                   choices = c("Individuo Completo (Peso Vivo / RWT)"     = "RWT",
                               "Eviscerado con agallas/cabeza (GWT)"      = "GWT",
                               "Sin cabeza y sin vísceras (Tronco / DWT)" = "DWT")),
      hr(),
      actionButton("calcular", "Ejecutar Estimación", class = "btn-primary")
    ),
    
    mainPanel(
      h3("Dictamen Técnico Oficial"),
      verbatimTextOutput("resultados"),
      hr(),
      h4("Diagnóstico de Incertidumbre y Calibración Regional"),
      verbatimTextOutput("diagnostico_local")
    )
  )
)

server <- function(input, output) {
  
  calculo <- eventReactive(input$calcular, {
    sp <- parametros_locales[parametros_locales$codigo_iccat == input$especie, ]
    
    if (input$especie == "SKJ") {
      factor_conv <- switch(input$estado, "RWT" = 1.00, "GWT" = 1.13, "DWT" = 1.25)
    } else {
      factor_conv <- switch(input$estado, "RWT" = 1.00, "GWT" = 1.12, "DWT" = 1.20)
    }
    
    biomasa_viva <- input$kilos_totales * factor_conv
    
    n_estimado <- biomasa_viva / sp$peso_medio
    n_min_cardumen <- biomasa_viva / sp$p90 
    n_max_cardumen <- biomasa_viva / sp$p10 
    
    ic_inf_pob <- sp$peso_medio - (1.96 * sp$se_peso)
    ic_sup_pob <- sp$peso_medio + (1.96 * sp$se_peso)
    n_pob_min  <- biomasa_viva / ic_sup_pob
    n_pob_max  <- biomasa_viva / ic_inf_pob
    
    list(
      n         = round(n_estimado),
      n_min_c   = floor(n_min_cardumen),
      n_max_c   = ceiling(n_max_cardumen),
      n_pob_min = floor(n_pob_min),
      n_pob_max = ceiling(n_pob_max),
      p_medio   = sp$peso_medio,
      p10       = sp$p10,
      p50       = sp$p50,  
      p90       = sp$p90,
      se        = sp$se_peso,
      ic_inf    = ic_inf_pob,
      ic_sup    = ic_sup_pob,
      factor    = factor_conv,
      biomasa   = biomasa_viva,
      muestras  = sp$n
    )
  })
  
  output$resultados <- renderPrint({
    req(calculo())
    res <- calculo()
    cat(sprintf("Biomasa Expandida a Vivo (RWT):      %.2f kg\n", res$biomasa))
    cat("=========================================================\n")
    cat(sprintf("  NÚMERO ESTIMADO DE INDIVIDUOS:       %d peces\n", res$n))
    cat("=========================================================\n")
    cat("Rango Biológico del Cardumen (Intervalo P10 - P90):\n")
    cat(sprintf("Entre %d y %d individuos (según predominio de tallas)\n", 
                res$n_min_c, res$n_max_c))
  })
  
  output$diagnostico_local <- renderPrint({
    req(calculo())
    res <- calculo()
    cat(sprintf("Muestra local calibrada:              %d individuos medidos\n", res$muestras))
    cat(sprintf("Peso medio aplicado:                  %.2f kg (P50 Mediana: %.2f kg)\n", 
                res$p_medio, res$p50))
    cat(sprintf("Factor de conversión comercial:       %.2f (%s)\n", res$factor, input$estado))
    cat("---------------------------------------------------------\n")
    cat("Precisión del Estimador Poblacional Nacional:\n")
    cat(sprintf("Error Estándar (SE):                  ±%.3f kg\n", res$se))
    cat(sprintf("IC 95%% de la Media Poblacional:       [%.2f kg - %.2f kg]\n", res$ic_inf, res$ic_sup))
    cat(sprintf("Remoción esperada bajo IC 95%%:        %d a %d peces\n", res$n_pob_min, res$n_pob_max))
  })
}

shinyApp(ui, server)
