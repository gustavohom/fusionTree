library(shiny)

library(shiny)

require(sp)
require(rgdal)
require(rgeos)
require(grDevices)
require(maptools)

require(magrittr)
require(dplyr)
require(spatstat)
require(tools)
require(stringr)


#shiny::runApp(display.mode="showcase")



shinyUI(
  fluidPage(
    
    # Titulo da Aplicacao
    
    titlePanel("Fusion Emergent"),
    
    "Realizando tarefas para identificar arvores emergentes e ",
    strong("padrao de distribuicao espacial"),
    
    # Layout da pagina
    
    sidebarLayout(
      
      # Paineis
      
      
      sidebarPanel(
        
        # Difinir se o processo é automatico ou nao 
        
        strong("O processo foi automatizado?"),
        
        checkboxInput("autoProcess", "Sim"),
        
        # Box para definiri o Diretorio
        
        textInput(
          "diretorioInput",
          "Diretorio raiz",
          value = "",
          width = NULL,
          placeholder = NULL
        ),
        
        "Selecionar do diretorio raiz, como em C:/*/CSV",
        br(),
        br(),
        "* = dieretorio",
        
        
        # Selecionar transectos com identificacao automatica de nome
        
        uiOutput("transectoOutput"),
        
        
        # Selecionar diretorio do shp
        
        textInput(
          "diretorioSHP",
          "Diretorio shp",
          value = "/shp/",
          width = NULL,
          placeholder = NULL
        ),
        
        # Inserir o nome do arquivo shp
        
        
        textInput(
          "arquivoSHP",
          "Arquivo shp",
          value = "planilha",
          width = NULL,
          placeholder = NULL
        ),
        
        
        # Dfinir qual percentil das arvores serao filtrados
        
        numericInput("percentil", "Filtro de Arvores (em decimais)", 0.95, width = "50%"),
        
        # numero de simulacoes para funcao k de Ripley
        
        numericInput("n", "Simulacoes", 3),
        
        # Botao para Executar processo
        
        actionButton("go", "Go!"),
        
        #  Limites superiores e inferiores horizontal do grafico com uma barra
        
        sliderInput(
          "xInput",
          "Eixo Horizontal",
          min = 0,
          max = 100,
          value = c(0, 100)
        ),
        
        # inserir valores de limites superiores e inferiores manualmente
        
        numericInput("infX", "Inferior", 0, width = "50%"),
        numericInput("supX", "Superior", 100, width = "50%"),
        actionButton("redLimites", "Redefinir")
        
      ),
      
      
      
      # Inicio do painel
      
      mainPanel(# Plotando o grafico para K de Ripley
        
        plotOutput("KdeRipley"))
    )
  )
)
# dsad
#
# asd
