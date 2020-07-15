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

# Inicio do serve

#' Title
#'
#' @param input 
#' @param output 
#' @param session 
#'
#' @return
#' @export
#'
#' @examples
shinyServer(function(input, output, session) {
  
  #   ### Quando o processo é automatizado desde o inicio, com o processo
  #   ### automatico, a nuvem de pontos deve estar na pasta las e o arquivo csv
  #   ### na pasta csv.  Os nomes foram padronizados nas etapas anteriores
  
  #   #### Caso nao, deve-se definir o diretorio manualmente
  
  # Nome automatico ou manual
  
  output$transectoOutput <- renderUI({
    if (input$autoProcess) {
      diretorio = input$diretorioInput
      
      inpD <-
        file_path_sans_ext(dir(paste0(diretorio, "\\las\\"), pattern = '.las'))  # Arquivos na pasta las
      inpE <- " "
      inpD <- c(inpD, inpE)
      
      selectizeInput("transectoInput",
                     "Transecto",
                     choices = inpD,
                     selected = " ")
    } else{
      textInput("transectoInput", "Transecto", value = "Nome da Planilha")
    }
  })
  
  
  # Atualiza o nome do shp automaticamente
  
  observeEvent(input$transectoInput, {
    updateTextInput(session, "arquivoSHP", value = input$transectoInput)
    
  })
  
  observeEvent(input$arquivoSHP, {
    updateTextInput(session, "arquivoSHP", value = input$arquivoSHP)
    
  })
  
  
  # Definindo Lat Long dos pontos na planilha
  
  # Longetude
  
  output$coordTreeOutputX <- renderUI({
    if (input$autoProcess) {
      textInput("coordTreeX", "Longetude Automatica", value = "X")

    } else{
      textInput("coordTreeX", "Longetude Manual", value = "Longetude")
    }
  })

  # # Latitude

  output$coordTreeOutputY <- renderUI({
    if (input$autoProcess) {
      textInput("coordTreeY", "Latitude Automatica", value = "Y")

    } else{
      textInput("coordTreeY", "Latitude Manual", value = "Latitude")
    }
  })
  
  
  # Calculo da funcao K de Ripley
  
  
  KdeRipley_ <- eventReactive(input$go, {
    
    diretorio <- input$diretorioInput
    
    
    # padronizar variaveis
    #------------
    
    inputT <- input$transectoInput
    
    transectoI <- input$arquivoSHP
    
    diretorioSHP <- input$diretorioSHP
    
    percentil <- input$percentil
    
    # Carreganfo dados
    
    
    # Criar funcao para selecionar automaticamente ou manualmente arquivos
    # Colocar o numero de arquivos que serão selecionados 1, 2, 3 ou 4 plhanilhas
    # definir diretorio manual ou automatico
    # definir sep = ",", dec = "."
    #-----------------------------------------------------
    
    # Nome automatico com processos anteriores ou manual
    
    
    if (input$autoProcess) {
      emergentTree <-
        read.table(
          paste0(
            diretorio,
            "\\csv\\",
            inputT,
            "tree_tile_0002_0001_treelist.csv"
          ),
          header = T,
          sep = ",",
          dec = "."
        )
    } else{
      emergentTree <-
        read.table(
          paste0(diretorio, inputT, ".csv"),
          header = T,
          sep = ",",
          dec = "."
        )
    }
    
    PPP <- emergentTree
    
    # Filtrando percentil 95
    
    PPP %<>% filter(Height > quantile(PPP$Height, percentil))
    
    # Criando poligono com extenções
    
    # Definir oque serão eixos X e Y
    #-----------------------------------
    
    
    
    
    #---------------------------------
    
    if (input$autoProcess) {
      
      coordinates(PPP) = ~ X + Y
      
    } else{

      coordinates(PPP) = c(input$coordTreeX , input$coordTreeY)
    }
    
    #------------------------
   
    
    # criando windows apartir de shp
    
    # Opcao de criar diretorio manualmente
    # colocar a opcao clipoly para area sem shp
    # colocar opcao manual com todos os ponto ou definir limite manualmente com pontos
    #-------------------------------------
    
    S <-
      readShapePoly(paste0(diretorio, diretorioSHP, transectoI, ".shp"))
    
    SP <- as(S, "SpatialPolygons")
    
    W <- as(SP, "owin")
    
    # criando pontos a partir de dados shp
    
    #---------------------------------------
    # Opcao com click poly
    #----------------------------------------
    
    # criando ppp
    
    
    # if (input$autoProcess) {
      
      p <- ppp(PPP$X, PPP$Y, window = W)
      
    # } else{
    #   
    #   p <- ppp(PPP$X_descartPossibi21543, PPP$Y_descartPossibi21543, window = W)
    # }

    
    # K test e K test envelopado
    
    ke <- envelope(p, Kest, nsim = input$n)
    
    ke
    
    # plot(ke, xlim = c(1400,1460), main=" ")
    
    
    #---------------------------
    # Criar opcao F (l)
    #------------------------------
    
    
  })
  
  
  # Plotando o grafico no painel
  
  output$KdeRipley <- renderPlot({
    plo <-
      plot(KdeRipley_(),
           
           # Opcao com nome do grafico
           #--------------------------
           
           main = "Testando",
           xlim = c(input$xInput[1], input$xInput[2]))
    
    plo
  })
  
  
  # botao para iniciar o processo
  
  # Trocar input$n por nome input$nSimulacao
  #----------------------------
  
  observeEvent(input$n, {
    label <- paste0("Simular ", input$n, " vezes")
    updateActionButton(session, "go", label = label)
  })
  
  # atualizando limites superior e inferior horizontal do grafico + 1
  
  observeEvent(input$go, {
    updateSliderInput(
      session,
      "xInput",
      "Eixo Horizontal",
      min = 0,
      max = as.integer((max(KdeRipley_(
        
      )$r))),
      value = c(0, as.integer((
        max(KdeRipley_()$r + 1)
      )))
    )
    
  })
  
  # Intervalo superio e inferior do grafico
  # trocar tag
  #------------------------------
  
  # Intervalo horizontal do grafico
  
  observeEvent(input$infX, {
    nInfX = input$infX
    nSupX = input$supX
    
    updateSliderInput(session, "xInput", value = c(nInfX, nSupX))
    
  })
  
  observeEvent(input$supX, {
    nSupX = input$supX
    nInfX = input$infX
    
    updateSliderInput(session, "xInput", value = c(nInfX, nSupX))
    
  })
  
  
  # Botao para redefinir intervalos para maximo e minimo
  
  
  #------------------
  #trocar tags
  #----------------
  
  observeEvent(input$redLimites, {
    updateSliderInput(
      session,
      "xInput",
      "Eixo Horizontal",
      min = 0,
      max = as.integer((max(KdeRipley_(
        
      )$r))),
      value = c(0, as.integer((
        max(KdeRipley_()$r)
      )))
    )
  })
  
  
})
