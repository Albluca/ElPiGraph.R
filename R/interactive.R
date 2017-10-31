#' Auxiliary function used by the shiny interface
#'
#' @param BaseData 
#' @param TargetPG 
#' @param CombPCA 
#' @param Selected 
#' @param PGCol 
#' @param GroupsLab 
#' @param PointSize 
#' @param p.alpha 
#' @param Main 
#'
#' @return
#' @export
#'
#' @examples
PlotShiny <- function(BaseData, TargetPG, CombPCA, Selected, AssociatedPoints = FALSE, PGCol = "EpG", GroupsLab = NULL, PointSize = 1, p.alpha = .4, Main = '') {

  if(is.null(GroupsLab)){
    GroupsLab = rep("N/A", nrow(X))
  }

  if(length(PGCol) == 1){
    PGCol = rep(PGCol, nrow(TargetPG$NodePositions))
  }

  if(length(PointSize) == 1){
    PointSize = rep(PointSize, nrow(TargetPG$NodePositions))
  }

  if(length(AssociatedPoints) == 1){
    AssociatedPoints = rep(AssociatedPoints, nrow(BaseData))
  }


  # Base Data

  DataVarPerc <- apply(BaseData[,1:2], 2, var)/sum(apply(X, 2, var))

  # Initialize plot

  tSelected <- rep("Data", nrow(BaseData))
  if(any(AssociatedPoints)){
    tSelected[AssociatedPoints] <- "Selected"
  }
  tSelected <- factor(tSelected, levels = c("Data", "Nodes", "Selected"))

  # print(dim(BaseData))
  # print(length(BaseData))

  df1 <- data.frame(PC1 = BaseData[,1], PC2 = BaseData[,2], Group = GroupsLab, Sel = tSelected)

  p <- ggplot2::ggplot(data = df1, mapping = ggplot2::aes(x = PC1, y = PC2, color = Group, alpha = Sel), environment = environment()) +
    ggplot2::geom_point() + ggplot2::scale_alpha_manual(values = c(.3, .7, 1), drop = FALSE)

  # Target graph

  RotData <- CombPCA$x

  tEdg <- t(sapply(1:nrow(TargetPG$Edges$Edges), function(i){
    Node_1 <- TargetPG$Edges$Edges[i, 1]
    Node_2 <- TargetPG$Edges$Edges[i, 2]

    if(PGCol[Node_1] ==  PGCol[Node_2]){
      tCol = PGCol[Node_1]
    }

    if(PGCol[Node_1] !=  PGCol[Node_2]){
      tCol = "Multi"
    }

    if(any(PGCol[c(Node_1, Node_2)] == "None")){
      tCol = "None"
    }

    c(RotData[Node_1,1:2], RotData[Node_2,1:2], Node_1, Node_2, tCol)
  }))

  AllEdg <- cbind(tEdg, 0)

  TarPGVarPerc <- (CombPCA$sdev[1:2]^2)/sum(apply(TargetPG$NodePositions, 2, var))

  df2 <- data.frame(x = as.numeric(AllEdg[,1]),
                    y = as.numeric(AllEdg[,2]),
                    xend = as.numeric(AllEdg[,3]),
                    yend = as.numeric(AllEdg[,4]),
                    from = as.integer(AllEdg[,5]),
                    to = as.integer(AllEdg[,6]),
                    Col = AllEdg[,7],
                    Rep = as.numeric(AllEdg[,6]), stringsAsFactors = FALSE)


  # Plot projections

  tSelected <- rep("Nodes", length(Selected))
  if(any(Selected)){
    tSelected[Selected] <- "Selected"
  }
  tSelected <- factor(tSelected, levels = c("Data", "Nodes", "Selected"))

  p <- p + ggplot2::geom_segment(data = df2, mapping = ggplot2::aes(x=x, y=y, xend=xend, yend=yend, color = Col),
                                 inherit.aes = FALSE) +
    ggplot2::geom_point(mapping = ggplot2::aes(x=PC1, y=PC2, color = PGCol, size = PointSize, alpha = tSelected),
                        data = data.frame(PC1 = CombPCA$x[,1], PC2 = CombPCA$x[,2]),
                        inherit.aes = FALSE)

  if(!is.na(TargetPG$ReportTable[nrow(TargetPG$ReportTable),"FVEP"])){
    p <- p + ggplot2::labs(x = paste0("PC1 (Org data var = ",  signif(100*DataVarPerc[1], 3), "% / Org PG var = ", signif(100*TarPGVarPerc[1], 3), "%)"),
                           y = paste0("PC2 (Org data var = ",  signif(100*DataVarPerc[2], 3), "% / Org PG var = ", signif(100*TarPGVarPerc[2], 3), "%)"),
                           title = paste0(Main,
                                          "/ FVE=",
                                          signif(as.numeric(TargetPG$ReportTable[nrow(TargetPG$ReportTable),"FVE"]), 3),
                                          "/ FVEP=",
                                          signif(as.numeric(TargetPG$ReportTable[nrow(TargetPG$ReportTable),"FVEP"]), 3))
    ) +
      ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))
  } else {
    p <- p + ggplot2::labs(x = paste0("PC1 (Data var = ",  signif(100*DataVarPerc[1], 3), "% / PG var = ", signif(100*TarPGVarPerc[1], 3), "%)"),
                           y = paste0("PC2 (Data var = ",  signif(100*DataVarPerc[2], 3), "% / PG var = ", signif(100*TarPGVarPerc[2], 3), "%)"),
                           title = paste0(Main,
                                          "/ FVE=",
                                          signif(as.numeric(TargetPG$ReportTable[nrow(TargetPG$ReportTable),"FVE"]), 3))
    ) +
      ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))
  }


  return(p)

}








































#' Interactivelly modify data 
#'
#' @param X 
#' @param TargetPG 
#' @param PGCol 
#' @param GroupsLab 
#' @param PointSize 
#' @param p.alpha 
#' @param Main 
#'
#' @return
#' @export
#'
#' @examples
RearrangePlot <- function(X, TargetPG, PGCol = "EpG", GroupsLab = NULL, PointSize = 1, p.alpha = .4, Main = '') {

  library(shiny)

  ui <- shinyUI(fluidPage(
    titlePanel("Interactive graph rearrangement"),
    plotOutput("graph", width = "100%", height = "1500px", click = "plot_click")
  ))

  server <- shinyServer(function(input, output, session) {

    CombPCA <- suppressWarnings(irlba::prcomp_irlba(TargetPG$NodePositions, n = 2, retx = TRUE, center = TRUE))
    PG.df <- data.frame(PC1 = CombPCA$x[,1], PC2 = CombPCA$x[,2], id=1:nrow(CombPCA$x))

    BaseData <- t(t(X) - CombPCA$center) %*% CombPCA$rotation
    Partition <- PartitionData(X = BaseData, NodePositions = CombPCA$x, SquaredX = rowSums(BaseData^2), TrimmingRadius = Inf, nCores = 1)

    Selected <- rep(FALSE, nrow(PG.df))
    Points.Selected <- rep(FALSE, nrow(BaseData))

    # makeReactiveBinding('X')
    makeReactiveBinding('Selected')
    makeReactiveBinding('CombPCA')
    makeReactiveBinding('Points.Selected')


    output$graph <- renderPlot({
      PlotShiny(BaseData = BaseData, TargetPG = TargetPG, CombPCA = CombPCA, Selected = Selected,
                AssociatedPoints = Points.Selected, PGCol = "EpG", GroupsLab = GroupsLab,
                PointSize = PointSize, p.alpha = p.alpha, Main = Main)
    })

    observeEvent(input$plot_click, {
      # Get 1 datapoint within 15 pixels of click, see ?nearPoints

      # print(input$plot_click)
      np <- nearPoints(PG.df, input$plot_click, maxpoints=1 , threshold = 15)

      if(nrow(np)>0){

        # A node is being selected

        if(!any(Selected)){
          Selected[PG.df$id == np$id] <<- TRUE

          if(any(Partition$Partition == which(Selected))){
            Points.Selected[] <<- FALSE
            Points.Selected[Partition$Partition == which(Selected)] <<- TRUE
          }

        } else {
          if(Selected[PG.df$id == np$id]){
            Selected[PG.df$id == np$id] <<- FALSE
          } else {
            Selected <<- rep(FALSE, nrow(PG.df))
            Selected[PG.df$id == np$id] <<- TRUE
            if(any(Partition$Partition == which(Selected))){
              Points.Selected[] <<- FALSE
              Points.Selected[Partition$Partition == which(Selected)] <<- TRUE
            }
          }
        }

      } else {

        # A new position is being selected

        if(any(Selected)){

          NewX <- input$plot_click$x
          NewY <- input$plot_click$y

          Disp.x <- NewX - PG.df$PC1[Selected]
          Disp.y <- NewY - PG.df$PC2[Selected]

          print(Disp.x)
          print(Disp.y)

          if(any(Partition$Partition == which(Selected))){
            BaseData[Partition$Partition == which(Selected),1] <<- BaseData[Partition$Partition == which(Selected),1] + Disp.x
            BaseData[Partition$Partition == which(Selected),2] <<- BaseData[Partition$Partition == which(Selected),2] + Disp.y
          }

          CombPCA$x[Selected,1] <<- CombPCA$x[Selected,1] + Disp.x
          CombPCA$x[Selected,2] <<- CombPCA$x[Selected,2] + Disp.y

          PG.df$PC1[Selected] <<- CombPCA$x[Selected,1]
          PG.df$PC2[Selected] <<- CombPCA$x[Selected,2]

          Selected <<- rep(FALSE, nrow(PG.df))
          Points.Selected[] <<- FALSE

        }

      }

    })

  })

  shinyApp(ui=ui,server=server)

}











#' Interactivelly look at data
#'
#' @param X
#'
#' @return
#' @export
#'
#' @examples
ExploreNei <- function(X) {

  library(shiny)

  ui <- shinyUI(
    fluidRow(
      textInput(inputId = 'mDist', label = "Max dist", value = "1"),
      textInput(inputId = 'mStep', label = "Step dist", value = ".1"),
      plotOutput("dataDist", width = "100%", height = "1000px", click = "plot_click_data"),
      plotOutput("radialDist", width = "100%", height = "500px", click = "plot_click_dist")
    )
  )

  server <- shinyServer(function(input, output, session) {

    if(ncol(X)<2){
      PCAData <- irlba::prcomp_irlba(X, n = 2, retx = TRUE)
    } else {
      PCAData <- prcomp(X, retx = TRUE)
    }

    Data.df <- data.frame(x = PCAData$x[,"PC1"],
                          y = PCAData$x[,"PC2"],
                          col = "Data",
                          id = 1:nrow(PCAData$x), stringsAsFactors = FALSE)

    Selected <- 0
    Included <- NULL
    DistData <- NULL
    DVect <- NULL
    makeReactiveBinding('Selected')
    makeReactiveBinding('DistData')


    output$dataDist <- renderPlot({
      Data.df$col[] = "Data"
      if(Selected > 0){
        Data.df$col[Selected] <- "Selected"
        if(length(DistData) > 0){
          Included <- (Data.df$id[-Selected])[DistData$Idxs]
          Data.df$col[Included] = "Neighbors"
        }
      }
      ggplot2::ggplot(data = Data.df, ggplot2::aes(x=x, y=y, color=col)) +
        ggplot2::geom_point(size = 3)

    })


    output$radialDist <- renderPlot({

      if(length(DistData)>0){
        # df <- data.frame(x = log2(DVect), y = log2(DistData$PCount + 1))
        
        df <- data.frame(x = log2(100*DVect+1), y = log2(DistData$PCount + 1)/log2(100*DVect+1))
        
        out.lm <- lm(y~x, data=df)
        out.seg <- segmented::segmented(out.lm, seg.Z=~x)

        # print(summary(out.seg))

        # CISeg <- segmented::confint.segmented(out.seg)

        # print(CISeg)

        p <- ggplot2::ggplot(data = df, ggplot2::aes(x=x, y=y)) +
          ggplot2::geom_line()

        # if(!is.null(CISeg$x)){
        #   p <- p + ggplot2::geom_vline(xintercept = CISeg$x[1])
        # }

        return(p)
      } else {
        return(NULL)
      }

    })





    observeEvent(input$plot_click_data, {
      np <- nearPoints(Data.df, input$plot_click_data, maxpoints=1 , threshold = 15)

      if(nrow(np)>0){

        Selected <<- as.integer(np$id)

        DVect <<- seq(from = as.numeric(input$mStep),
                      to = as.numeric(input$mDist),
                      by = as.numeric(input$mStep))

        # print(DVect)

        DistData <<- distutils::RadialCount(Ar = X[-Selected,],
                                            Pr = X[Selected,],
                                            SquaredAr = rowSums(X[-Selected,]^2),
                                            DVect = DVect
        )

        # print(DistData)

      }

    })


  })

  shinyApp(ui=ui,server=server)

}









