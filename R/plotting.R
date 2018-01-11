
# Plotting Functions (Diagnostic) --------------------------------------------

#' Plot the MSD VS Energy plot
#'
#' @param PrintGraph a struct returned by computeElasticPrincipalGraph
#' @param Main string, title of the plot
#'
#' @return a ggplot plot
#' @export
#'
#' @examples
plotMSDEnergyPlot <- function(ReportTable, Main = ''){
  
  df <- rbind(data.frame(Nodes = as.integer(ReportTable[,"NNODES"]),
                   Value = as.numeric(ReportTable[,"ENERGY"]), Type = "Energy"),
              data.frame(Nodes = as.integer(ReportTable[,"NNODES"]),
                         Value = as.numeric(ReportTable[,"MSEP"]), Type = "MSEP")
  )
                         
  p <- ggplot2::ggplot(data = df, mapping = ggplot2::aes(x = Nodes, y = Value, color = Type, shape = Type),
                       environment = environment()) +
    ggplot2::geom_point() + ggplot2::geom_line() + ggplot2::facet_grid(Type~., scales = "free_y") +
    ggplot2::guides(color = "none", shape = "none") + ggplot2::ggtitle(Main)
  
  return(p)
  
}







#' Accuracy-Complexity plot
#'
#' @param Main string, tht title of the plot
#' @param Mode integer or string, the mode used to identify minima: if 'LocMin', the barcode of the 
#' local minima will be plotted, if the number n, the barcode will be plotted each n configurations.
#' If NULL, no barcode will be plotted
#' @param Xlims a numeric vector of length 2 indicating the minimum and maximum of the x axis. If NULL (the default)
#' the rage of the data will be used
#' @param ReportTable A report table as returned from an ElPiGraph computation function
#' @param AdjFactor numeric, the factor used to adjust the values on the y axis (computed as UR*NNODE^AdjFactor)
#'
#' @return a ggplot plot
#' @export 
#'
#' @examples
accuracyComplexityPlot <- function(ReportTable, AdjFactor=1, Main = '', Mode = 'LocMin', Xlims = NULL){

  if(is.null(Xlims)){
    Xlims <- range(as.numeric(ReportTable[,"FVEP"]))
  }

  YVal <- as.numeric(ReportTable[,"UR"])*(as.integer(ReportTable[,"NNODES"])^AdjFactor)

  
  df <- data.frame(FVEP = as.numeric(ReportTable[,"FVEP"]), Comp = YVal)
  
  
  p <- ggplot2::ggplot(data = df, ggplot2::aes(x = FVEP, y = Comp), environment = environment()) +
    ggplot2::geom_point() + ggplot2::geom_line() +
    ggplot2::labs(title = Main, x = "Fraction of Explained Variance", y = "Geometrical Complexity") +
    ggplot2::coord_cartesian(xlim = Xlims)
  
  TextMat <- NULL
 
  if(Mode == 'LocMin'){
    for(i in 2:(length(YVal)-1)){
      xp = YVal[i-1]
      x = YVal[i]
      xn = YVal[i+1]
      if(x < min(c(xp,xn))){
        diff = abs(x-(xp+xn)/2);
        if(diff>0.01){
          TextMat <- rbind(TextMat, c(ReportTable[i,"FVEP"], y = YVal[i], labels = ReportTable[i,"BARCODE"]))
        }
      }
    }
  }
  
  if(is.numeric(Mode)){
    Mode = round(Mode)

    TextMat <- rbind(TextMat, c(ReportTable[2,"FVEP"], y = YVal[2], labels = ReportTable[2,"BARCODE"]))
    TextMat <- rbind(TextMat, c(ReportTable[length(YVal),"FVEP"], y = YVal[length(YVal)], labels = ReportTable[length(YVal),"BARCODE"]))

    if(Mode > 2){
      Mode <- Mode - 1
      Step <- (length(YVal) - 2)/Mode
      
      for (i in seq(from=2+Step, to = length(YVal)-1, by = Step)) {
        TextMat <- rbind(TextMat, c(ReportTable[round(i),"FVEP"], y = YVal[round(i)], labels = ReportTable[round(i),"BARCODE"]))
      }
    }
    
  }
  
  if(!is.null(TextMat)){
    df2 <- data.frame(FVEP = as.numeric(TextMat[,1]), Comp = as.numeric(TextMat[,2]), Label = TextMat[,3])
    
    p <- p + ggplot2::geom_text(data = df2, mapping = ggplot2::aes(x = FVEP, y = Comp, label = Label),
                                check_overlap = TRUE, inherit.aes = FALSE, nudge_y = .005)
  }
  
  return(p)
}









# Plotting Functions (2D plots) --------------------------------------------



#' Plot a graph with pie chart associated with each node
#'
#' @param X numerical 2D matrix, the n-by-m matrix with the position of n m-dimensional points
#' @param TargetPG the main principal graph to plot
#' @param Graph a igraph object of the ElPiGraph, if NULL (the default) it will be computed by the function
#' @param LayOut the global layout of yhe final network. It can be
#' \itemize{
#'  \item 'tree', a tree
#'  \item 'circle', a closed circle
#'  \item 'circle_line', a line arranged as a circle
#'  \item 'nicely', the topology will be inferred by ighraph
#' }
#' @param TreeRoot the id of the node to use as the root of the tree when LayOut = 'tree'
#' @param Main string, the title of the plot
#' @param ScaleFunction function, a function used to scale the nuumber of points (sqrt by default)
#' @param NodeSizeMult integer, an adjustment factor to control the size of the pies 
#' @param ColCat string vector, a vector of colors to associate to each category
#' @param GroupsLab string factor, a vector indicating the category of each data point
#' @param Partition A vector associating each point to a node of the ElPiGraph. If NULL (the default), this will be computed
#' @param TrimmingRadius numeric, the trimming radius to use when associting points to nodes when Partition = NULL
#' @param Leg.cex naumeric, a value to adjust the size of the legend
#'
#' @return NULL
#' @export
#'
#' @examples
plotPieNet <- function(X,
                       TargetPG,
                       GroupsLab = NULL,
                       Partition = NULL,
                       TrimmingRadius = Inf,
                       Graph = NULL,
                       LayOut = 'nicely',
                       TreeRoot = numeric(),
                       Main="",
                       ScaleFunction = sqrt,
                       NodeSizeMult = 1,
                       ColCat = NULL,
                       Leg.cex = 1) {

  if(!is.factor(GroupsLab)){
    GroupsLab <- factor(GroupsLab)
  }

  if(is.null(ColCat)){
    ColCat <- c(rainbow(length(unique(GroupsLab))), NA)
    names(ColCat) <- c(levels(droplevels(GroupsLab)), NA)
  } else {
    if(sum(names(ColCat) %in% levels(GroupsLab)) < length(unique(GroupsLab))){
      print("Reassigning colors to categories")
      names(ColCat) <- c(levels(GroupsLab), NA)
    }
    ColCat <- ColCat[levels(GroupsLab)]
    ColCat <- c(ColCat, NA)
  }

  if(is.null(Partition)){
    print("Partition will be computed. Consider do that separetedly")
    Partition <- PartitionData(X = X, NodePositions = TargetPG$NodePositions,
                               SquaredX = rowSums(X^2), TrimmingRadius = TrimmingRadius,
                               nCores = 1)$Partition
  }

  GroupPartTab <- matrix(0, nrow = nrow(TargetPG$NodePositions), ncol = length(ColCat))
  colnames(GroupPartTab) <- c(levels(GroupsLab), "None")
  
  TTab <- table(Partition[Partition > 0], GroupsLab)
  GroupPartTab[as.integer(rownames(TTab)), colnames(TTab)] <- TTab
  
  Missing <- setdiff(1:nrow(TargetPG$NodePositions), unique(Partition))
  
  if(length(Missing)>0){
    GroupPartTab[Missing, "None"] <- 1
  }
  
  if(is.null(Graph)){
    print("A graph will be constructed. Consider do that separatedly")
    Net <- ConstructGraph(PrintGraph = TargetPG)
  } else {
    Net <- Graph
  }

  PieList <- apply(GroupPartTab, 1, list)
  PieList <- lapply(PieList, function(x){x[[1]]})
  
  PieColList <- lapply(PieList, function(x){ColCat})
  
  LayOutDONE <- FALSE
  
  if(LayOut == 'tree'){
    RestrNodes <- igraph::layout_as_tree(graph = igraph::as.undirected(Net, mode = 'collapse'), root = TreeRoot)
    LayOutDONE <- TRUE
  }
  
  if(LayOut == 'circle'){
    IsoGaph <- igraph::graph.ring(n = igraph::vcount(Net), directed = FALSE, circular = TRUE)
    Iso <- igraph::graph.get.isomorphisms.vf2(igraph::as.undirected(Net, mode = 'collapse'), IsoGaph)
    if(length(Iso)>0){
      VerOrder <- igraph::V(Net)[Iso[[1]]]
      RestrNodes <- igraph::layout_in_circle(graph = Net, order = VerOrder)
      LayOutDONE <- TRUE
    } else {
      Net1 <- ConstructGraph(PrintGraph = TargetPG)
      IsoGaph <- igraph::graph.ring(n = igraph::vcount(Net1), directed = FALSE, circular = TRUE)
      Iso <- igraph::graph.get.isomorphisms.vf2(igraph::as.undirected(Net1, mode = 'collapse'), IsoGaph)
      VerOrder <- igraph::V(Net1)[Iso[[1]]]
      RestrNodes <- igraph::layout_in_circle(graph = Net, order = VerOrder$name)
      LayOutDONE <- TRUE
    }
  }
  
  if(LayOut == 'circle_line'){
    IsoGaph <- igraph::graph.ring(n = igraph::vcount(Net), directed = FALSE, circular = FALSE)
    Iso <- igraph::graph.get.isomorphisms.vf2(igraph::as.undirected(Net, mode = 'collapse'), IsoGaph)
    if(length(Iso) > 0){
      VerOrder <- igraph::V(Net)[Iso[[1]]]
      RestrNodes <- igraph::layout_in_circle(graph = Net, order = VerOrder)
      LayOutDONE <- TRUE
    } else {
      Net1 <- ConstructGraph(PrintGraph = TargetPG)
      IsoGaph <- igraph::graph.ring(n = igraph::vcount(Net1), directed = FALSE, circular = FALSE)
      Iso <- igraph::graph.get.isomorphisms.vf2(igraph::as.undirected(Net1, mode = 'collapse'), IsoGaph)
      VerOrder <- igraph::V(Net1)[Iso[[1]]]
      RestrNodes <- igraph::layout_in_circle(graph = Net, order = VerOrder$name)
      LayOutDONE <- TRUE
    }
    
  }
  
  if(LayOut == 'nicely'){
    RestrNodes <- igraph::layout_nicely(graph = Net)
    LayOutDONE <- TRUE
  }
  
  if(!LayOutDONE){
    print(paste("LayOut =", LayOut, "unrecognised"))
    return(NULL)
  }
  
  igraph::plot.igraph(Net, layout = RestrNodes[,1:2], main = Main,
                      vertex.shape="pie", vertex.pie.color = PieColList,
                      vertex.pie=PieList, vertex.pie.border = NA,
                      vertex.size=NodeSizeMult*do.call(what = ScaleFunction,
                                                       list(table(factor(x = Partition, levels = 1:nrow(TargetPG$NodePositions))))),
                      edge.color = "black", edge.arrow.size = Arrow.size, vertex.label.dist = 0.7, vertex.label.color = "black")
  
  legend(x = "bottom", legend = names(ColCat), fill = ColCat, horiz = TRUE, cex = Leg.cex)

}







#' Plot data and principal graph(s) 
#'
#' @param X numerical 2D matrix, the n-by-m matrix with the position of n m-dimensional points
#' @param TargetPG the main principal graph to plot
#' @param BootPG A list of principal graphs that will be considered as bostrapped curves
#' @param PGCol string, the label to be used for the main principal graph
#' @param PlotProjections string, the plotting mode for the node projection on the principal graph.
#' It can be "none" (no projections will be plotted), "onNodes" (the projections will indicate how points are associated to nodes),
#' and "onEdges" (the projections will indicate how points are projected on edges or nodes of the graph)
#' @param GroupsLab factor or numeric vector. A vector indicating either a category or a numeric value associted with
#' each data point
#' @param PointViz string, the modality to show points. It can be 'points' (data will be represented a dot) or
#' 'density' (the data will be represented by a field)
#' @param Main string, the title of the plot
#' @param p.alpha numeric between 0 and 1, the alpha value of the points. Lower values will prodeuce more transparet points
#' @param PointSize numeric vector, a vector indicating the size to be associted with each node of the graph.
#' If NA points will have size 0.
#' @param NodeLabels string vector, a vector indicating the label to be associted with each node of the graph
#' @param LabMult numeric, a multiplier controlling the size of node labels
#' @param Do_PCA bolean, should the node of the principal graph be used to derive principal component projections and
#' rotate the space? If TRUE the plots will use the "EpG PC" as dimensions, if FALSE, the original dimensions will be used. 
#' @param DimToPlot a integer vector specifing the PCs (if Do_PCA=TRUE) or dimension (if Do_PCA=FALSE) to plot. All the
#' combination will be considered, so, for example, if DimToPlot = 1:3, three plot will be produced.
#'
#' @return
#' @export
#'
#' @examples
PlotPG <- function(X,
                   TargetPG,
                   BootPG = NULL,
                   PGCol = "",
                   PlotProjections = "none",
                   GroupsLab = NULL,
                   PointViz = "points",
                   Main = '', p.alpha = .3,
                   PointSize = NULL,
                   NodeLabels = NULL,
                   LabMult = 1,
                   Do_PCA = TRUE,
                   DimToPlot = c(1,2)) {
  
  
  # X = Data.Kowa.CV$Analysis$FinalExpMat
  # TargetPG = Data.Kowa.CV$Analysis$FinalStruct
  # GroupsLab = Data.Kowa.CV$Analysis$FinalGroup
  # p.alpha = .4
  # Main = 'Kowalczyk et al (CV Sel)'
  # DimToPlot = 1:3
  # 
  # BootPG = NULL
  # PGCol = "EPG"
  # PlotProjections = "none"
  # PointViz = "points"
  # PointSize = NULL
  # NodeLabels = NULL
  # LabMult = 1
  # Do_PCA = TRUE
  # 
  # 
  
  if(length(PGCol) == 1){
    PGCol = rep(PGCol, nrow(TargetPG$NodePositions))
  }
  
  if(is.null(GroupsLab)){
    GroupsLab = factor(rep("N/A", nrow(X)))
  }
  
  levels(GroupsLab) <- c(levels(GroupsLab), unique(PGCol))
  
  if(!is.null(PointSize)){
    if(!is.na(PointSize)){
      if(length(PointSize) == 1){
        PointSize = rep(PointSize, nrow(TargetPG$NodePositions))
      }
    }
  }
  
  

  if(Do_PCA){
    CombPCA <- prcomp(TargetPG$NodePositions, retx = TRUE, center = TRUE)
    BaseData <- t(t(X) - CombPCA$center) %*% CombPCA$rotation
    DataVarPerc <- apply(BaseData, 2, var)/sum(apply(X, 2, var))
    DimToPlot <- intersect(DimToPlot, 1:ncol(CombPCA$x))
  } else {
    BaseData <- X
    DataVarPerc <- apply(X, 2, var)/sum(apply(X, 2, var))
    DimToPlot <- intersect(DimToPlot, 1:ncol(X))
  }
  
  
  # Base Data
  
  AllComb <- combn(DimToPlot, 2)
  
  PlotList <- list()
  
  for(i in 1:ncol(AllComb)){
    
    Idx1 <- AllComb[1,i]
    Idx2 <- AllComb[2,i]
    
    if(Do_PCA){
      df1 <- data.frame(PCA = BaseData[,Idx1], PCB = BaseData[,Idx2], Group = GroupsLab)
    } else {
      df1 <- data.frame(PCA = BaseData[,Idx1], PCB = BaseData[,Idx2], Group = GroupsLab)
    }
    
    
    # Initialize plot
    
    Inizialized <- FALSE
    
    if(PointViz == "points"){
      p <- ggplot2::ggplot(data = df1, mapping = ggplot2::aes(x = PCA, y = PCB), environment = environment()) +
        ggplot2::geom_point(alpha = p.alpha, mapping = ggplot2::aes(color = Group))
      Inizialized <- TRUE
    }
    
    if(PointViz == "density"){
      p <- ggplot2::ggplot(data = df1, mapping = ggplot2::aes(x = PCA, y = PCB), environment = environment()) +
        ggplot2::stat_density2d(geom="raster", ggplot2::aes(color = Group, fill = Group, alpha = ..density..), contour = FALSE) +
        ggplot2::theme_minimal()
      Inizialized <- TRUE
    }
    
    if(!Inizialized){
      stop("Invalid point representaion selected")
    }
    
    # Target graph
    
    if(Do_PCA){
      RotData <- t(t(TargetPG$NodePositions) - CombPCA$center) %*% CombPCA$rotation
    } else {
      RotData <- TargetPG$NodePositions
    }
    
    
    tEdg <- t(sapply(1:nrow(TargetPG$Edges$Edges), function(i){
      Node_1 <- TargetPG$Edges$Edges[i, 1]
      Node_2 <- TargetPG$Edges$Edges[i, 2]
      
      if(PGCol[Node_1] ==  PGCol[Node_2]){
        tCol = paste("ElPiG", PGCol[Node_1])
      }
      
      if(PGCol[Node_1] !=  PGCol[Node_2]){
        tCol = "ElPiG Multi"
      }
      
      if(any(PGCol[c(Node_1, Node_2)] == "None")){
        tCol = "ElPiG None"
      }
      
      c(RotData[Node_1,c(Idx1, Idx2)], RotData[Node_2,c(Idx1, Idx2)], tCol)
    }))
    
    AllEdg <- cbind(tEdg, 0)
    
    if(Do_PCA){
      TarPGVarPerc <- (CombPCA$sdev^2)/sum(apply(TargetPG$NodePositions, 2, var))
    } else {
      TarPGVarPerc <- apply(TargetPG$NodePositions, 2, var)/sum(apply(TargetPG$NodePositions, 2, var))
    }
    
    df2 <- data.frame(x = as.numeric(AllEdg[,1]),
                      y = as.numeric(AllEdg[,2]),
                      xend = as.numeric(AllEdg[,3]),
                      yend = as.numeric(AllEdg[,4]),
                      Col = AllEdg[,5],
                      Rep = as.numeric(AllEdg[,6]), stringsAsFactors = FALSE)
    
    # df2$Col <- factor(df2$Col, levels = levels(GroupsLab))
    
    
    # Replicas
    
    if(!is.null(BootPG)){
      AllEdg <- lapply(1:length(BootPG), function(i){
        tTree <- BootPG[[i]]
        
        if(Do_PCA){
          RotData <- t(t(tTree$NodePositions) - CombPCA$center) %*% CombPCA$rotation
        } else {
          RotData <- tTree$NodePositions
        }
        
        tEdg <- t(sapply(1:nrow(tTree$Edges$Edges), function(i){
          c(RotData[tTree$Edges$Edges[i, 1],c(Idx1, Idx2)], RotData[tTree$Edges$Edges[i, 2],c(Idx1, Idx2)])
        }))
        
        cbind(tEdg, i)
      })
      
      AllEdg <- do.call(rbind, AllEdg)
      
      df3 <- data.frame(x = AllEdg[,1], y = AllEdg[,2], xend = AllEdg[,3], yend = AllEdg[,4], Rep = AllEdg[,5])
      
      p <- p + ggplot2::geom_segment(data = df3, mapping = ggplot2::aes(x=x, y=y, xend=xend, yend=yend),
                                     inherit.aes = FALSE, alpha = .3, color = "black")
      
    }
    
    
    
    # Plot projections
    
    
    if(PlotProjections == "onEdges"){
      
      if(Do_PCA){
        Partition <- PartitionData(X = BaseData, NodePositions = CombPCA$x, SquaredX = rowSums(BaseData^2), TrimmingRadius = Inf, nCores = 1)
        OnEdgProj <- project_point_onto_graph(X = BaseData, NodePositions = CombPCA$x, Edges = TargetPG$Edges$Edges, Partition = Partition$Partition)
      } else {
        Partition <- PartitionData(X = BaseData, NodePositions = TargetPG$NodePositions, SquaredX = rowSums(BaseData^2), TrimmingRadius = Inf, nCores = 1)
        OnEdgProj <- project_point_onto_graph(X = BaseData, NodePositions = TargetPG$NodePositions, Edges = TargetPG$Edges$Edges, Partition = Partition$Partition)
      }
      
      ProjDF <- data.frame(X = BaseData[,Idx1], Y = BaseData[,Idx2],
                           Xend = OnEdgProj$X_projected[,Idx1], Yend = OnEdgProj$X_projected[,Idx2],
                           Group = GroupsLab)
      
      p <- p + ggplot2::geom_segment(data = ProjDF,
                                     mapping = ggplot2::aes(x=X, y=Y, xend = Xend, yend = Yend, col = Group), inherit.aes = FALSE)
    }
    
    if(PlotProjections == "onNodes"){
      
      if(Do_PCA){
        Partition <- PartitionData(X = BaseData, NodePositions = CombPCA$x, SquaredX = rowSums(BaseData^2), TrimmingRadius = Inf, nCores = 1)
        ProjDF <- data.frame(X = BaseData[,Idx1], Y = BaseData[,Idx2],
                             Xend = CombPCA$x[Partition$Partition,Idx1], Yend = CombPCA$x[Partition$Partition,Idx2],
                             Group = GroupsLab)
      } else {
        Partition <- PartitionData(X = BaseData, NodePositions = TargetPG$NodePositions, SquaredX = rowSums(BaseData^2), TrimmingRadius = Inf, nCores = 1)
        ProjDF <- data.frame(X = BaseData[,Idx1], Y = BaseData[,Idx2],
                             Xend = TargetPG$NodePositions[Partition$Partition,Idx1], Yend = TargetPG$NodePositions[Partition$Partition,Idx2],
                             Group = GroupsLab)
      }
      
      
      
      p <- p + ggplot2::geom_segment(data = ProjDF,
                                     mapping = ggplot2::aes(x=X, y=Y, xend = Xend, yend = Yend, col = Group),
                                     inherit.aes = FALSE, alpha=.3)
    }
    
    
    if(is.factor(GroupsLab)){
      p <- p + ggplot2::geom_segment(data = df2, mapping = ggplot2::aes(x=x, y=y, xend=xend, yend=yend, col = Col),
                                     inherit.aes = TRUE) + ggplot2::labs(linetype = "")
    } else {
      p <- p + ggplot2::geom_segment(data = df2, mapping = ggplot2::aes(x=x, y=y, xend=xend, yend=yend),
                                     inherit.aes = FALSE)
    }
    
    if(Do_PCA){
      df4 <- data.frame(PCA = CombPCA$x[,Idx1], PCB = CombPCA$x[,Idx2])
    } else {
      df4 <- data.frame(PCA = TargetPG$NodePositions[,Idx1], PCB = TargetPG$NodePositions[,Idx2])
    }
    
    
    if(!is.null(PointSize)){
      if(!is.na(PointSize)){
        p <- p + ggplot2::geom_point(mapping = ggplot2::aes(x=PCA, y=PCB, size = PointSize),
                                   data = df4,
                                   inherit.aes = FALSE)
      } else {
        p <- p + ggplot2::geom_point(mapping = ggplot2::aes(x=PCA, y=PCB),
                                     data = df4, size = 0,
                                     inherit.aes = FALSE)
      }
    } else {
      p <- p + ggplot2::geom_point(mapping = ggplot2::aes(x=PCA, y=PCB),
                                   data = df4,
                                   inherit.aes = FALSE)
    }
    
    
    
    
    
    if(!is.null(NodeLabels)){
      
      if(Do_PCA){
        df4 <- data.frame(PCA = CombPCA$x[,Idx1], PCB = CombPCA$x[,Idx2], Lab = NodeLabels)
      } else {
        df4 <- data.frame(PCA = TargetPG$NodePositions[,Idx1], PCB = TargetPG$NodePositions[,Idx2], Lab = NodeLabels)
      }
      
      p <- p + ggplot2::geom_text(mapping = ggplot2::aes(x=PCA, y=PCB, label = Lab),
                                  data = df4, hjust = 0,
                                  inherit.aes = FALSE, na.rm = TRUE,
                                  check_overlap = TRUE, color = "black", size = LabMult)
    }
    
    if(Do_PCA){
      LabX <- paste0("EpG PC", Idx1, " (Data var = ",  signif(100*DataVarPerc[Idx1], 3), "% / PG var = ", signif(100*TarPGVarPerc[Idx1], 3), "%)")
      LabY <- paste0("EpG PC", Idx2, " (Data var = ",  signif(100*DataVarPerc[Idx2], 3), "% / PG var = ", signif(100*TarPGVarPerc[Idx2], 3), "%)")
    } else {
      LabX <- paste0("Dimension ", Idx1, " (Data var = ",  signif(100*DataVarPerc[Idx1], 3), "% / PG var = ", signif(100*TarPGVarPerc[Idx1], 3), "%)")
      LabY <- paste0("Dimension ", Idx2, " (Data var = ",  signif(100*DataVarPerc[Idx2], 3), "% / PG var = ", signif(100*TarPGVarPerc[Idx2], 3), "%)")
    }
    
    
    if(!is.na(TargetPG$ReportTable[nrow(TargetPG$ReportTable),"FVEP"])){
      p <- p + ggplot2::labs(x = LabX,
                             y = LabY,
                             title = paste0(Main,
                                            "/ FVE=",
                                            signif(as.numeric(TargetPG$ReportTable[nrow(TargetPG$ReportTable),"FVE"]), 3),
                                            "/ FVEP=",
                                            signif(as.numeric(TargetPG$ReportTable[nrow(TargetPG$ReportTable),"FVEP"]), 3))
      ) +
        ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))
    } else {
      p <- p + ggplot2::labs(x = LabX,
                             y = LabY,
                             title = paste0(Main,
                                            "/ FVE=",
                                            signif(as.numeric(TargetPG$ReportTable[nrow(TargetPG$ReportTable),"FVE"]), 3))
      ) +
        ggplot2::theme(plot.title = ggplot2::element_text(hjust = 0.5))
    }
    
    
    PlotList[[length(PlotList)+1]] <- p
    
  }
  
  return(PlotList)
  
}

