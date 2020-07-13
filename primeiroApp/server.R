#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

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

# Define server logic required to draw a histogram



shinyServer(function(input, output, session) {
  
  
  output$transectoOutput <- renderUI({
    
    diretorio = input$diretorioInput
    
    inpD <- file_path_sans_ext(dir(paste0(diretorio,"\\las\\"),pattern='.las'))  # Arquivos na pasta las
    inpE <- " "
    inpD <- c(inpD, inpE)
    
    selectizeInput("transectoInput", "Transecto", choices = inpD,  selected = " ")
    
  })
  
  # botao para iniciar o processo   
  
  observeEvent(input$n, {
    label <- paste0("Simular ", input$n, " vezes")
    updateActionButton(session, "go", label = label)
  })
  
  # Atualizando o nome do shp
  
  observeEvent(input$transectoInput, {
    
    updateTextInput(session, "arquivoSHP", value = input$transectoInput )
    
  })
  
  observeEvent(input$arquivoSHP, {
    
    updateTextInput(session, "arquivoSHP", value = input$arquivoSHP )
    
  })
  
  # Calculo da funcao 
  
  
  KdeRipley_ <- eventReactive(input$go, {
    
    
    diretorio <- input$diretorioInput
    
    inputT <- input$transectoInput
    
    transectoI <- input$arquivoSHP
    
    diretorioSHP <- input$diretorioSHP
    
    percentil <- input$percentil
    
    # Carreganfo dados
    
    # treeList1 <- read.table(paste0(diretorio,"\\csv\\",inputT,"tree_tile_0001_0001_treelist.csv"), header = T, sep = ",", dec = ".")
    # treeList2 <- read.table(paste0(diretorio,"\\csv\\",inputT,"tree_tile_0001_0002_treelist.csv"), header = T, sep = ",", dec = ".")
    treeList3 <- read.table(paste0(diretorio,"\\csv\\",inputT,"tree_tile_0002_0001_treelist.csv"), header = T, sep = ",", dec = ".")
    # treeList4 <- read.table(paste0(diretorio,"\\csv\\",inputT,"tree_tile_0002_0002_treelist.csv"), header = T, sep = ",", dec = ".")
    # 
    # emergentTree <- rbind(treeList1, treeList2, treeList3, treeList4)
    
    emergentTree <- treeList3
    
    PPP <- emergentTree
    
    # Filtrando percentil 95
    
    PPP %<>% filter(Height > quantile(PPP$Height,percentil))
    
    # Criando poligono com extenções
    
    coordinates(PPP) = ~X+Y
    
    # criando windows apartir de shp
    
    S <- readShapePoly(paste0(diretorio,diretorioSHP,transectoI,".shp" ))
    
    SP <- as(S, "SpatialPolygons")
    
    W <- as(SP, "owin")
    
    # criando pontos a partir de dados shp
    
    # criando ppp
    
    p <- ppp(PPP$X, PPP$Y, window = W)
    
    plot(p)
    
    # K test e K test envelopado
    
    ke <- envelope(p,Kest, nsim = input$n)
    
    ke
    
    # plot(ke, xlim = c(1400,1460), main=" ")
    
    
  })
  
  output$KdeRipley <- renderPlot({
    
    plo <- plot(KdeRipley_(), main = "Testando", xlim = c(input$xInput[1],input$xInput[2]))
    
    plo })
  
  
  # atualizando maximo e minimo X do grafico
  
  observeEvent(input$go, {
    
    updateSliderInput(session,"xInput", "Eixo Horizontal", min = 0, max = as.integer((max(KdeRipley_()$r))),
                      value = c(0,as.integer((max(KdeRipley_()$r)))))
    
  })
  
  observeEvent(input$infX, {
    nInfX = input$infX
    nSupX = input$supX
    
    updateSliderInput(session,"xInput", value = c(nInfX,nSupX))
    
  })
  
  observeEvent(input$supX, {
    
    nSupX = input$supX
    nInfX = input$infX
    
    updateSliderInput(session,"xInput", value = c(nInfX,nSupX))
    
  })
  
  
  observeEvent(input$redLimites, {
    
    updateSliderInput(session,"xInput", "Eixo Horizontal", min = 0, max = as.integer((max(KdeRipley_()$r))),
                      value = c(0,as.integer((max(KdeRipley_()$r)))))
  })
  
  
})
