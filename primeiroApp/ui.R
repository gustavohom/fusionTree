




#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/



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


# Define UI for application that draws a histogram


#shiny::runApp(display.mode="showcase")







shinyUI(fluidPage(
  # Application title
  
  titlePanel("Testando APP"),
  
  "testando",
  strong("Transectos"),
  
  sidebarLayout(
    sidebarPanel(
      # Diretorio
      
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
      
      
      # Selecionar transectos
      
      uiOutput("transectoOutput"),
      
      
      
      textInput(
        "diretorioSHP",
        "Diretorio shp",
        value = "/qgis/finalizados/",
        width = NULL,
        placeholder = NULL
      ),
      
      textInput(
        "arquivoSHP",
        "Arquivo shp",
        value = "planilha",
        width = NULL,
        placeholder = NULL
      ),
      
      # Percentil
      
      numericInput("percentil", "Filtro de Arvores (em decimais)", 0.95, width = "50%"),
      
      # numero de simulacoes
      
      numericInput("n", "Simulacoes", 3),
      
      # Executar processo
      
      actionButton("go", "Go!"),
      
      #  Maximo e minimo X do grafico
      
      sliderInput(
        "xInput",
        "Eixo Horizontal",
        min = 0,
        max = 100,
        value = c(0, 100)
      ),
      
      # inserir valores de limites superiores e inferiores
      
      numericInput("infX", "Inferior", 0, width = "50%"),
      numericInput("supX", "Superior", 100, width = "50%"),
      actionButton("redLimites", "Redefinir")
      
    ),
    
    mainPanel(plotOutput("KdeRipley"))
  )
))
# dsad
# 
# asd

