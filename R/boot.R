#' Compute projection-associted uncertainty
#'
#' @param X numeric matrix containing the points to be projected
#' @param BootPG a list of ElPiGraph structures. The nodes dimensionality must
#'   be compatible with the dimensioanlity of the data
#' @param Mode string, the mode used to compute points uncertainty. Currently
#'   the following options are supported
#'   \describe{
#'   \item{"MedianDistPW"}{All the paiwise distances between the projections
#'   of the same point across the different ElPiGraphs are calculated and the
#'   median (per points) is returned}
#'   \item{"MedianDistPW"}{All the paiwise distances between the projections
#'   of the same point across the different ElPiGraphs are calculated and the
#'   mean (per points) is returned}
#'   \item{"MeanDistCentroid"}{The centroid of the projections of the same point
#'   across the different ElPiGraphs are calculated and the mean (per point)
#'   distance of the original points from the centroid is returned}
#'   \item{"MeanDistCentroid"}{The centroid of the projections of the same point
#'   across the different ElPiGraphs are calculated and the mean (per point)
#'   distance of the original points from the centroid is returned}
#'   }
#' @param TargetPG an optional parameter describing the target ElPiGraph. Currently unused.
#'
#' @return a numeric vector with the same length as the number of rows of X. Higher values indicate larger uncertainty.
#' @export
#'
#' @examples
#' 
#'   nRep <- 50
#'   
#'   
#'   TreeEPG <- computeElasticPrincipalTree(X = tree_data, NumNodes = 70,
#'       drawAccuracyComplexity = FALSE, drawEnergy = FALSE,
#'       drawPCAView = FALSE,
#'       nReps = nRep, ProbPoint = .9,
#'       TrimmingRadius = Inf,
#'       ICOver = "DensityProb", DensityRadius = .2)
#'   
#'   PtUnc_1 <- GetProjectionUncertainty(X = tree_data, BootPG = TreeEPG[1:nRep], Mode = "MedianDistPW")
#'   PtUnc_2 <- GetProjectionUncertainty(X = tree_data, BootPG = TreeEPG[1:nRep], Mode = "MedianDistCentroid")
#'   PtUnc_3 <- GetProjectionUncertainty(X = tree_data, BootPG = TreeEPG[1:nRep], Mode = "MeanDistPW")
#'   PtUnc_4 <- GetProjectionUncertainty(X = tree_data, BootPG = TreeEPG[1:nRep], Mode = "MeanDistCentroid")
#'   
#'   pairs(cbind(PtUnc_1, PtUnc_2, PtUnc_3, PtUnc_4))
#'   
#'   PlotPG(X = tree_data, TargetPG = TreeEPG[[nRep+1]], BootPG = TreeEPG[1:nRep], GroupsLab = PtUnc_1)
#'   PlotPG(X = tree_data, TargetPG = TreeEPG[[nRep+1]],  GroupsLab = PtUnc_1, p.alpha = .9)
#' 
GetProjectionUncertainty <- function(X, BootPG, Mode = "MedianDistPW", TargetPG = NULL) {
 
  AllPrj <- lapply(BootPG, function(PGStruct){
    project_point_onto_graph(X = X, NodePositions = PGStruct$NodePositions, Edges = PGStruct$Edges$Edges)
  })
  
  X_Proj <- lapply(AllPrj, "[[", "X_projected")
  # X_dist <- lapply(AllPrj, function(x){
  #   sqrt(rowSums((X - x$X_projected)^2))
  # })
  
  X_Proj_Mat <- do.call(rbind, X_Proj)
  
  PointUnc <- rep(NA, nrow(X))
  
  if(Mode == "MedianDistPW"){
    PointUnc <- sapply(1:nrow(X), function(i){
      Sel <- seq(from=i, to=nrow(X_Proj_Mat), by = nrow(X))
      X_Proj_Dist <- distutils::PartialDistance(X_Proj_Mat[Sel,], X_Proj_Mat[Sel,])
      median(X_Proj_Dist[upper.tri(X_Proj_Dist, diag = FALSE)])
    })
  }
  
  if(Mode == "MeanDistPW"){
    PointUnc <- sapply(1:nrow(X), function(i){
      Sel <- seq(from=i, to=nrow(X_Proj_Mat), by = nrow(X))
      X_Proj_Dist <- distutils::PartialDistance(X_Proj_Mat[Sel,], X_Proj_Mat[Sel,])
      mean(X_Proj_Dist[upper.tri(X_Proj_Dist, diag = FALSE)])
    })
  }
  
  if(Mode == "MeanDistCentroid"){
    PointUnc <- sapply(1:nrow(X), function(i){
      Sel <- seq(from=i, to=nrow(X_Proj_Mat), by = nrow(X))
      X_Proj_Dist <- distutils::PartialDistance(matrix(colMeans(X_Proj_Mat[Sel,]), nrow = 1), X_Proj_Mat[Sel,])
      mean(X_Proj_Dist)
    })
  }
  
  if(Mode == "MedianDistCentroid"){
    PointUnc <- sapply(1:nrow(X), function(i){
      Sel <- seq(from=i, to=nrow(X_Proj_Mat), by = nrow(X))
      X_Proj_Dist <- distutils::PartialDistance(matrix(colMeans(X_Proj_Mat[Sel,]), nrow = 1), X_Proj_Mat[Sel,])
      mean(X_Proj_Dist)
    })
  }
  
  if(Mode == "MedianDistCentroid"){
    PointUnc <- sapply(1:nrow(X), function(i){
      Sel <- seq(from=i, to=nrow(X_Proj_Mat), by = nrow(X))
      X_Proj_Dist <- distutils::PartialDistance(matrix(colMeans(X_Proj_Mat[Sel,]), nrow = 1), X_Proj_Mat[Sel,])
      mean(X_Proj_Dist)
    })
  }
  
  return(PointUnc)
}






#' Obtain a consens tree from bootstrapped data
#'
#' @param BootPG list of ElPiGraph structures containing the bootstrapped data
#' @param Mode string, the mode to use 
#' @param MinEdgMult integer, minimal multiplicity of the edges of the consensus graph
#' @param MinNodeMult integer, minimal multiplicity of the nodes of the consensus graph
#' @param Clusters integer, the number of clusters inferred by the kmeans step
#' @param RemoveIsolatedNodes boolean, should the procedure remove graph nodes that are not connected to any other node?
#' @param OnlyLCC boolean, should the procedure return only the largest connected component of the graph?
#' @param PlotResult boolean, should debugging information be plotted?
#' @param CollapseRadius numeric, the distance to use in order to compute the multiplicity of the nodes. If NULL, it will be inferred from the data
#' @param FilterEdges.Min numeric, the minimal length of edges in the final graph. Shorter edges will be removed, unless the removal results in an
#' increase of the components of the graph
#' @param FilterEdges.Max numeric, the maximum length of edges in the final graph. Longer edges will be removed, unless the removal results in an
#' increase of the components of the graph
#'
#' @return
#' @export
#'
#' @examples
GenertateConsensusGraph <- function(BootPG,
                                    Mode = "NodeDist",
                                    CollapseRadius = NULL,
                                    FilterEdges.Min = NULL,
                                    FilterEdges.Max = NULL,
                                    # RestrictCR = 5,
                                    # MinNodes = 25,
                                    # MaxNodes = 200,
                                    Clusters = 100,
                                    MinEdgMult = 2,
                                    MinNodeMult = 2,
                                    # NodesInflation = 1,
                                    RemoveIsolatedNodes = TRUE,
                                    OnlyLCC = FALSE,
                                    PlotResult = TRUE) {
  
  
  
  if(Mode == "NodeDist"){
    
    # Get all the node position on the bootstrapped ElPiGraph
    AllNodePos <- lapply(BootPG, "[[", "NodePositions")
    AllNodesCount <- sapply(AllNodePos, nrow)
    
    GraphID_Vect <- lapply(as.list(1:length(AllNodesCount)), function(i){rep(i, AllNodesCount[i])})
    GraphID_Vect <- unlist(GraphID_Vect)
    
    NodeID_Vect <- lapply(as.list(1:length(AllNodesCount)), function(i){1:AllNodesCount[i]})
    NodeID_Vect <- unlist(NodeID_Vect)
    
    # Get all the edge connections position on the bootstrapped ElPiGraph
    AllEdges <- lapply(lapply(BootPG, "[[", "Edges"), "[[", "Edges")
    AllEdgesCount <- sapply(AllEdges, nrow)
    EdgeID_Vect <- lapply(as.list(1:length(AllEdgesCount)), function(i){rep(i, AllEdgesCount[i])})
    EdgeID_Vect <- unlist(EdgeID_Vect)
    
    # Compare the distance between all of the nodes
    AllNodePos_Mat <- do.call(rbind, AllNodePos)
    rownames(AllNodePos_Mat) <- paste0("Gr_", GraphID_Vect, "_N_", NodeID_Vect)
    
    AllEdge_Mat <- lapply(1:length(AllEdges), function(i){
      matrix(paste0("Gr_", i, "_N_", AllEdges[[i]]), ncol = 2)
    })
    AllEdge_Mat <- do.call(rbind, AllEdge_Mat)
    
    AllNodeDist <- distutils::PartialDistance(AllNodePos_Mat, AllNodePos_Mat)
    colnames(AllNodeDist) <- rownames(AllNodePos_Mat)
    rownames(AllNodeDist) <- rownames(AllNodePos_Mat)
    
    if(PlotResult){
      EffDists <- as.vector(AllNodeDist[upper.tri(AllNodeDist)])
      plot(density(EffDists, from = 0), main = "Intranode distance", xlab = "Distance")
      # abline(v = MinTol, lwd = 3)
    }
    
    
    if(is.null(CollapseRadius)){
      # Get the average edge lenght in the graphs
      MeanDistByNet <- sapply(1:length(BootPG), function(i){
        mean(
          rowSums(
            (BootPG[[i]]$NodePositions[BootPG[[i]]$Edges$Edges[,1],] - 
               BootPG[[i]]$NodePositions[BootPG[[i]]$Edges$Edges[,2],])^2
          )
        )
      })
      
      MeanDistByNet <- sqrt(MeanDistByNet)
      CollapseRadius <- mean(MeanDistByNet)
      
    }
    
    if(PlotResult){
      abline(v = CollapseRadius, col = 'red', lty = 2)
    }
    
    cat(paste("CollapseRadius = ", CollapseRadius, "\n"))
    
    # Remove nodes with limited representability
    Selected <- rowSums(AllNodeDist < CollapseRadius) >= MinNodeMult
    
    cat(paste(sum(Selected), "Nodes will be used to construct the initial network\n"))
    
    cat("Constructing Network\n")
    tictoc::tic()
    BigNet <- igraph::graph_from_adjacency_matrix(1*(AllNodeDist[Selected,Selected] < CollapseRadius), mode = "undirected", diag = FALSE)
    tictoc::toc()
    
    cat("Performing kmeans\n")
    
    KM <- kmeans(AllNodePos_Mat[Selected,], centers = Clusters, iter.max = 1000, nstart = 1000)
    
    # library(ggplot2)
    # 
    # p <- ggplot(data.frame(AllNodePos_Mat[Selected,1:2], KM$cluster), aes(x = k8k.sgX, y = k8k.sgY, color = factor(KM.cluster))) + geom_point()
    
    # AllEdges
    
    # ClusPos <- lapply(1:nrow(KM$centers), function(i){
    #   if(sum(KM$cluster == i)>2){
    #     colMeans((AllNodePos_Mat[Selected,])[KM$cluster == i,])
    #   } else {
    #     (AllNodePos_Mat[Selected,])[KM$cluster == i,]
    #   }
    # })
    
    ClusPos <- KM$centers
    
    ConMat <- matrix(0, nrow(KM$centers), nrow(KM$centers))
    
    tictoc::tic()
    cat("Working on nodes ")
    for(i in 2:nrow(KM$centers)){
      cat(i, " ")
      for(j in 1:(i-1)){
        Nei1 <- igraph::neighborhood(graph = BigNet, order = 1, nodes = names(which(KM$cluster == i)))
        ConMat[i, j] <- sum(names(which(KM$cluster == j)) %in% unique(names(unlist(Nei1))))
      }
    }
    ConMat <- ConMat + t(ConMat)
    cat("\n")
    tictoc::toc()
    
    ConMat[ConMat < MinEdgMult] <- 0
    # ConMat[ConMat > 0] <- 1
    
    NewNet <- igraph::graph_from_adjacency_matrix(ConMat, mode = "undirected", weighted = "mult", diag = FALSE)
    igraph::V(NewNet)$Pos <- 1:nrow(ClusPos)
    
    # plot(NewNet, vertex.label = NA, vertex.size = 1)
    
    CombNet <- list(
      Nodes = ClusPos[igraph::V(NewNet)$Pos,],
      Edges = igraph::get.edgelist(NewNet),
      Graph = NewNet
    )
    
    # 
    # # Get a random permutation of the graphs
    # CollateSeq <- sample(1:length(BootPG))
    # 
    # # Define the initial graph
    # CombNet <- list(
    #   Nodes = AllNodePos[[CollateSeq[1]]],
    #   Edges = matrix(paste0("Gr_", CollateSeq[1], "_N_", AllEdges[[CollateSeq[1]]]), ncol = 2)
    # )
    # 
    # rownames(CombNet$Nodes) <- paste0("Gr_", CollateSeq[1], "_N_", 1:nrow(CombNet$Nodes))
    # 
    # for(i in 2:length(CollateSeq)){
    #   
    #   # Get the nodes for the graphs to combine
    #   Net2 <- AllNodePos[[CollateSeq[i]]]
    #   
    #   # Get the cross-graph distances
    #   PWNodeDist <- distutils::PartialDistance(CombNet$Nodes, Net2)
    #   
    #   # Find the closest nodes across graphs
    #   Closest.Id.Target <- apply(PWNodeDist, 1, which.min)
    #   Closest.Id.Target <- paste0("Gr_", CollateSeq[i], "_N_", Closest.Id.Target)
    #   
    #   Closest.Id.Source <- rownames(CombNet$Nodes)
    #   Closest.Dist <- apply(PWNodeDist, 1, min)
    #   
    #   # Only consider points that are closer than the average edge length
    #   Closest.Id.Target <- Closest.Id.Target[Closest.Dist < min(MeanDistByNet[CollateSeq[1:i]])]
    #   Closest.Id.Source <- Closest.Id.Source[Closest.Dist < min(MeanDistByNet[CollateSeq[1:i]])]
    #   # Closest.Dist <- Closest.Dist[Closest.Dist < min(MeanDistByNet[CollateSeq[1:i]])]
    #   Closest.Dist <- Closest.Dist[Closest.Dist < max(MeanDistByNet)]
    #   
    #   # Closest.Id.Source <- paste0("G_", CollateSeq[i], "_N_", Closest.Id.Source)
    #   
    #   NewEdges <- rbind(
    #     matrix(unlist(CombNet$Edges), ncol = 2),
    #     matrix(paste0("Gr_", CollateSeq[i], "_N_", AllEdges[[CollateSeq[i]]]), ncol = 2)
    #   )
    #   
    #   # Construct the fusion network
    #   CombNet.graph <- igraph::graph_from_edgelist(
    #     matrix(as.vector(NewEdges), ncol = 2),
    #     directed = FALSE
    #   )
    #   
    #   # Prepare the contraction vector
    #   ContVect <- c(rownames(CombNet$Nodes), paste0("Gr_", CollateSeq[i], "_N_", 1:nrow(Net2)))
    #   names(ContVect) <- ContVect
    #   
    #   # UsedIDs <- as.integer(sapply(strsplit(ContVect[grep("G_X_N_", ContVect)], "G_X_N_"), "[[", 2))
    #   # NexIDs <- (max(UsedIDs) + 1):(max(UsedIDs) + length(Closest.Id.Target))
    #   # NexIDs <- paste0("G_X_N_", NexIDs)
    #   
    #   ContVect[match(Closest.Id.Source, ContVect)] <- ContVect[match(Closest.Id.Target, ContVect)]
    #   # ContVect[match(Closest.Id.Target, ContVect)] <- NexIDs
    #   
    #   CombNet.graph <- igraph::contract.vertices(graph = CombNet.graph, mapping = match(ContVect, igraph::V(CombNet.graph)$name))
    #   CombNet.graph <- igraph::simplify(CombNet.graph, remove.multiple = TRUE, remove.loops = TRUE)
    #   CombNet.graph <- igraph::induced.subgraph(graph = CombNet.graph, igraph::degree(CombNet.graph)>0)
    #   
    #   NewnodesPosition <- sapply(igraph::V(CombNet.graph)$name, function(x){
    #     if(length(x)>1){
    #       colMeans(AllNodePos_Mat[x,])
    #     } else {
    #       AllNodePos_Mat[x,]
    #     }
    #   })
    #   
    #   NewNodesNames <- sapply(igraph::V(CombNet.graph)$name, function(x){x[1]})
    #   
    #   colnames(NewnodesPosition) <- NewNodesNames
    #   igraph::V(CombNet.graph)$name <- NewNodesNames
    #   
    #   CombNet <- list(
    #     Nodes = t(NewnodesPosition),
    #     Edges = igraph::get.edgelist(CombNet.graph)
    #   )
    #   
    #   # 
    #   
    #   
    #   IntraNodal <- distutils::PartialDistance(CombNet$Nodes, CombNet$Nodes)
    #   diag(IntraNodal) <- Inf
    #   sum(IntraNodal < max(MeanDistByNet))
    #   
    # }
    # 
    # NodeTolMult <- rowSums(AllNodeDist < MinTol)
    # hist(NodeTolMult)
    
    # FilAllNodePos_Mat <- AllNodePos_Mat[NodeTolMult > MinNodeMult + 1, ]
    
    
    # # library(fpc)
    # pamk.best <- fpc::pamk(AllNodePos_Mat)
    # cat("number of clusters estimated by optimum average silhouette width:", pamk.best$nc, "\n")
    # # plot(pam(d, pamk.best$nc))
    
    # tictoc::tic()
    # TT <- NbClust::NbClust(data = AllNodePos_Mat, min.nc = AllNodesCount[1], max.nc = round(AllNodesCount[1]*NodesInflation),
    #                        method = "kmeans")
    # tictoc::toc()
    
    # library(RWeka)
    # 
    # weka_ctrl <- Weka_control(
    #   I = 10000,                          # max no. of overall iterations
    #   M = 1000,                          # max no. of iterations in the kMeans loop
    #   L = MinNodes,                            # min no. of clusters
    #   H = MaxNodes,                           # max no. of clusters
    #   D = "weka.core.EuclideanDistance", # distance metric Euclidean
    #   C = 0.4,                           # cutoff factor ???
    #   S = 12                             # random number seed (for reproducibility)
    # )
    # 
    # # Run the algorithm on your data, d
    # x_means <- XMeans(AllNodePos_Mat, control = weka_ctrl)
    # 
    # Cls <- x_means$class_ids
    # 
    # for(i in 10:200){
    #   KM <- kmeans(x = AllNodePos_Mat, iter.max = 100, centers = i)
    #   TT <- c(TT, sum(KM$tot.withinss))
    # }
    
    # Try threshold of matrix + make graph + detect componentd
    
    # HC <- hclust(d = as.dist(AllNodeDist))
    # 
    # for(i in MinNodes:MaxNodes){
    #   
    #   Cls <- cutree(HC, k = i)
    #   
    #   CentrDist <- sapply(1:max(Cls), function(j){
    #     if(sum(Cls == j)>1){
    #       mean(distutils::PartialDistance(matrix(colMeans(AllNodePos_Mat[Cls == j,]), nrow = 1),
    #                                  AllNodePos_Mat[Cls == j,]))
    #     } else {
    #       0
    #     }
    #   })
    #   
    #   if(max(CentrDist) < MaxMean){
    #     print(paste(i, "nodes selected"))
    #     break()
    #   }
    #   
    # }
    # 
    # # if(min(Cls) == 0){
    # #   Cls <- Cls +1
    # # }
    # 
    # Crt <- sapply(1:max(Cls), function(i) {
    #   if(sum(Cls == i)>1){
    #     colMeans(AllNodePos_Mat[Cls == i, ])
    #   } else {
    #     AllNodePos_Mat[Cls == i, ]
    #   }
    # })
    # 
    # IdNodes <- split(rownames(AllNodePos_Mat), Cls)
    # 
    # ConMat <- matrix(0, max(Cls), max(Cls))
    # 
    # 
    # for(i in 1:(max(Cls)-1)){
    #   
    #   # plot(t(Crt[1:2,]))
    #   
    #   for(j in (i+1):max(Cls)){
    #     
    #     N1 <- IdNodes[[i]] 
    #     N2 <- IdNodes[[j]] 
    #     
    #     # points(FilAllNodePos_Mat[N1, ], col = "blue")
    #     # points(FilAllNodePos_Mat[N2, ], col = "blue")
    #     
    #     GrIds_N1 <- as.numeric(sapply(strsplit(N1, "_"), "[[", 2))
    #     NodeIds_N1 <- as.numeric(sapply(strsplit(N1, "_"), "[[", 4))
    #     
    #     GrIds_N2 <- as.numeric(sapply(strsplit(N2, "_"), "[[", 2))
    #     NodeIds_N2 <- as.numeric(sapply(strsplit(N2, "_"), "[[", 4))
    #     
    #     GrInt <- intersect(GrIds_N1, GrIds_N2)
    #     
    #     if( length(GrInt) == 0 ){
    #       next()
    #     }
    #     
    #     for(k in GrInt){
    #       
    #       Nodes1 <- NodeIds_N1[GrIds_N1 == k]
    #       Nodes2 <- NodeIds_N2[GrIds_N2 == k]
    #       
    #       if(length(Nodes1) > 0 & length(Nodes2) > 0){
    #         
    #         V1 <- AllEdges[[k]][,1] %in% Nodes1
    #         V2 <- AllEdges[[k]][,2] %in% Nodes2
    #         
    #         V3 <- AllEdges[[k]][,1] %in% Nodes2
    #         V4 <- AllEdges[[k]][,2] %in% Nodes1
    #         
    #         ConMat[i, j] <- ConMat[i, j] + sum(V1 & V2) + sum(V3 & V4)
    #       }
    #       
    #     }
    #   }
    # }
    
    # EdgeList <- which(ConMat >= MinEdgMult, arr.ind = TRUE)
    # 
    # GR <- igraph::graph.empty(n = ncol(Crt), directed = FALSE)
    # igraph::V(GR)$nodeID <- paste(1:ncol(Crt))
    # GR <- igraph::add.edges(GR, edges = t(EdgeList))
    
    if(OnlyLCC){

      AllClus <- igraph::clusters(NewNet)
      
      GR1 <- igraph::delete.vertices(NewNet, which(AllClus$membership != which.max(AllClus$csize)))

      CombNet$Nodes <- ClusPos[as.integer(igraph::V(GR1)$Pos), ]
      CombNet$Edges <- igraph::get.edgelist(GR1)
      CombNet$Graph <- GR1

      NewNet <- GR1
    }

    if(RemoveIsolatedNodes & !OnlyLCC){

      if(any(igraph::degree(NewNet) == 0)){
        GR1 <- igraph::delete.vertices(NewNet, which(igraph::degree(NewNet) == 0))
        
        CombNet$Nodes <- ClusPos[as.integer(igraph::V(GR1)$Pos),]
        CombNet$Edges <- igraph::get.edgelist(GR1)
        CombNet$Graph <- GR1
        
        NewNet <- GR1
      }
      
    }
    
    if(!igraph::is.connected(NewNet)){
      warning("Graph is not connected")
      PlotResult <- TRUE
    }
    
    
    
    if(!is.null(FilterEdges.Min) | !is.null(FilterEdges.Max)){
      
      cat("Using length-dependent edge filtering of the final graph\n")
      
      NodeDist <- distutils::PartialDistance(Ar = CombNet$Nodes, Br = CombNet$Nodes)
      EdgDist <- apply(CombNet$Edges, 1, function(x) {
        NodeDist[x[1], x[2]]
      })
      
      igraph::E(NewNet)$len <- EdgDist
      igraph::E(NewNet)$id <- 1:igraph::ecount(NewNet)
      
      plot(density(EdgDist, from=0))
      
      GR1 <- NewNet
      GraphComp <- igraph::count_components(NewNet)
      
      cat(paste(igraph::ecount(GR1), "edges present before length filtering\n"))
      
      if(!is.null(FilterEdges.Max)){
        abline(v=FilterEdges.Max, col="red", lty = 2)
        
        ToFilter <- igraph::E(GR1)$id[igraph::E(GR1)$len > FilterEdges.Max]
        OrderedID <- order(E(GR1)$len[match(ToFilter, igraph::E(GR1)$id)], decreasing = TRUE)
        
        cat(paste(length(ToFilter), "potential edges to be filtered due to being longer then threshold\n"))
        
        for(edg in ToFilter[OrderedID]){
          GR1.temp <- igraph::delete.edges(GR1, which(igraph::E(GR1)$id == edg))
          # print(paste(edg, igraph::count_components(GR1.temp)))
          if(igraph::count_components(GR1.temp) == GraphComp){
            GR1 <- GR1.temp
          }
        }
      }
      
      if(!is.null(FilterEdges.Min)){
        abline(v=FilterEdges.Min, col="red", lty = 2)
        
        ToFilter <- igraph::E(GR1)$id[igraph::E(GR1)$len < FilterEdges.Min]
        OrderedID <- order(E(GR1)$len[match(ToFilter, igraph::E(GR1)$id)], decreasing = FALSE)
        
        for(edg in ToFilter[OrderedID]){
          GR1.temp <- igraph::delete.edges(GR1, which(igraph::E(GR1)$id == edg))
          if(igraph::count_components(GR1.temp) == GraphComp){
            GR1 <- GR1.temp
          }
        }
      }
      
      cat(paste(igraph::ecount(GR1), "edges present after length filtering\n"))
      
      # print(ecount(NewNet))
      
      # GR1 <- igraph::delete.edges(NewNet, which(ToFilter))
      
      CombNet$Nodes <- ClusPos[as.integer(igraph::V(GR1)$Pos),]
      CombNet$Edges <- igraph::get.edgelist(GR1)
      CombNet$Graph <- GR1
      
      NewNet <- GR1
      
      # print(ecount(NewNet))
      
    }
    
    
    if(PlotResult){
      
      if(ncol(CombNet$Nodes)>5){
        RotPoints <- irlba::prcomp_irlba(CombNet$Nodes, 2, retx = TRUE)
      } else {
        RotPoints <- prcomp(CombNet$Nodes, retx = TRUE)
      }
      
      plot(RotPoints$x[,1:2], col = "red")
      for(i in 1:nrow(CombNet$Edges)){
        arrows(x0 = RotPoints$x[CombNet$Edges[i, 1], 1],
               y0 = RotPoints$x[CombNet$Edges[i, 1], 2],
               x1 = RotPoints$x[CombNet$Edges[i, 2], 1],
               y1 = RotPoints$x[CombNet$Edges[i, 2], 2],
               length = 0)
      }
    }
    
    # Return nodes and edges
    return(list(NodePos = CombNet$Nodes, EdgeMat = CombNet$Edges, Graph = CombNet$Graph, EdgMult = igraph::E(CombNet$Graph)$mult))
    
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  # if(Mode == "EdgeDist"){
  #   
  #   # Get all the node position on the bootstrapped ElPiGraph
  #   AllNodePos <- lapply(BootPG, "[[", "NodePositions")
  #   AllNodesCount <- sapply(AllNodePos, nrow)
  #   
  #   GraphID_Vect <- lapply(as.list(1:length(AllNodesCount)), function(i){rep(i, AllNodesCount[i])})
  #   GraphID_Vect <- unlist(GraphID_Vect)
  #   
  #   NodeID_Vect <- lapply(as.list(1:length(AllNodesCount)), function(i){1:AllNodesCount[i]})
  #   NodeID_Vect <- unlist(NodeID_Vect)
  #   
  #   # Get all the edge connections position on the bootstrapped ElPiGraph
  #   AllEdges <- lapply(lapply(BootPG, "[[", "Edges"), "[[", "Edges")
  #   AllEdgesCount <- sapply(AllEdges, nrow)
  #   EdgeID_Vect <- lapply(as.list(1:length(AllEdgesCount)), function(i){rep(i, AllEdgesCount[i])})
  #   EdgeID_Vect <- unlist(EdgeID_Vect)
  #   
  #   # Compare the distance between all of the edges, by consideiring the max distance between
  #   # the nodes in the edge configurations with the smallest distance between the nodes
  #   
  #   # The Similarity list will contain the edge similarity per ElPiGraph struct
  #   Similarity <- list()
  #   
  #   # The GraphPairs list will contain the list of pairs
  #   GraphPairs <- list()
  #   
  #   pb <- txtProgressBar(min = 1, max = length(AllNodesCount)-1, style = 3)
  #   
  #   cat("Generating similarity matrices\n")
  #   # For each ElPiGraph i from 1 to n-1
  #   for(i in 1:(length(AllNodesCount)-1)){
  #     
  #     setTxtProgressBar(pb = pb, value = i)
  #     
  #     # For each ElPiGraph j from i+1 to n
  #     for(j in (i+1):length(AllNodesCount)){
  #       
  #       # pre-compute the distance between all of the nodes
  #       PartDistMat <-  distutils::PartialDistance(AllNodePos[[i]], AllNodePos[[j]])
  #       
  #       # Initialize Similarity of the ElPiGraph under consideration
  #       Similarity[[length(Similarity)+1]] <- matrix(0, nrow = nrow(AllEdges[[i]]), ncol = nrow(AllEdges[[j]]))
  #       GraphPairs[[length(Similarity)]] <- c(i,j)
  #       
  #       # For each edge of ElPiGraph i
  #       for(k in 1:nrow(AllEdges[[i]])){
  #         
  #         # Get the distance between the nodes of the selected edge and all the other nodes
  #         TDistMat <- rbind(PartDistMat[AllEdges[[i]][k,], AllEdges[[i]][,1]],
  #               PartDistMat[AllEdges[[i]][k,], AllEdges[[i]][,2]])
  #         
  #         # For each node we compute the max distance by considering the same c(1, 4) and inverse c(2, 3) order
  #         Maxvect <- rbind(
  #           rbind(
  #             apply(TDistMat[c(1, 4),], 2, max),
  #             apply(TDistMat[c(2, 3),], 2, max)
  #           )
  #         )
  #         
  #         # and get which coparison lead to the best results by taking the minimum.
  #         # We save the index to kow if we need to take the direct or reverse edge
  #         MinIDVect <- apply(Maxvect, 2, which.min)
  #         MinValVect <- Maxvect[cbind(MinIDVect, 1:ncol(Maxvect))]
  #         
  #         # Get the index of the similar values
  #         SelEdgs <- which(MinValVect < MinTol)
  #         
  #         # Did we get any edge?
  #         if(length(SelEdgs) > 0){
  #           # Save the Info in the Similairity matrix
  #           Similarity[[length(Similarity)]][k, SelEdgs] <- c(1,-1)[MinIDVect[SelEdgs]]
  #         }
  #         
  #         # 
  #         # plot(AllNodePos[[i]][AllEdges[[i]][k,],1:2], xlim=c(-1, 1), ylim=c(-1,1))
  #         # points(AllNodePos[[i]][AllEdges[[i]][which.min(MinMaxVect),],1:2], col = "red")
  #         
  #       }
  #     }
  #   }
  #   
  #   # Now lets use the Similarity information to construct and merged network
  #   BigNet <- igraph::graph.empty(n = length(NodeID_Vect), directed = FALSE)
  #   
  #   # Create a vector to keep track of Node collapse
  #   NodeRef <- paste0("Gr_", GraphID_Vect, "_N_", NodeID_Vect)
  #   names(NodeRef) <- NodeRef
  #   InitialNodeRef <- NodeRef
  #   
  #   # Initialize the node contraction Vector
  #   NodeContraction <- 1:igraph::vcount(BigNet)
  #   names(NodeContraction) <- NodeRef
  #   
  #   # Fix names
  #   igraph::V(BigNet)$name <- NodeRef
  #   
  #   # Add nodes to the structure
  #   for(i in 1:length(BootPG)){
  #     BigNet <- igraph::add.edges(graph = BigNet, edges = paste0("Gr_", i, "_N_", t(BootPG[[i]]$Edges$Edges)))
  #   }
  #   
  #   pb <- txtProgressBar(min = 1, max = length(Similarity), style = 3)
  #   
  #   cat("\nProcessing similarity matrices\n")
  #   
  #   # For each similarity matrix
  #   for(i in 1:length(Similarity)){
  #     setTxtProgressBar(pb = pb, value = i)
  #     for(j in 1:nrow(Similarity[[i]])){
  #       
  #       Gr1 <- GraphPairs[[i]][1]
  #       Gr2 <- GraphPairs[[i]][2]
  #       
  #       Target <- paste0("Gr_", Gr1, "_N_", AllEdges[[Gr1]][j,])
  #       
  #       DirectMatch <- which(Similarity[[i]][j,]>0)
  #       if(length(DirectMatch)>0){
  #         NodeRef[paste0("Gr_", Gr2, "_N_", AllEdges[[Gr2]][DirectMatch,1])] <- NodeRef[Target[1]]
  #         NodeRef[paste0("Gr_", Gr2, "_N_", AllEdges[[Gr2]][DirectMatch,2])] <- NodeRef[Target[2]]
  #       }
  #       
  #       ReverseMatch <- which(Similarity[[i]][j,]<0)
  #       if(length(DirectMatch)>0){
  #         NodeRef[paste0("Gr_", Gr2, "_N_", AllEdges[[Gr2]][DirectMatch,2])] <- NodeRef[Target[1]]
  #         NodeRef[paste0("Gr_", Gr2, "_N_", AllEdges[[Gr2]][DirectMatch,1])] <- NodeRef[Target[2]]
  #       }
  #       
  #     }
  #     
  #   }
  #   
  #   # Update Node contraction vector
  #   NodeContraction <- NodeContraction[NodeRef]
  #   
  #   # Contract vertices
  #   MergedBigNet <- igraph::contract(graph = BigNet, mapping = NodeContraction)
  #   
  #   # Eliminate empty vertices
  #   MergedBigNet <- igraph::induced.subgraph(graph = MergedBigNet, vids = which(igraph::degree(MergedBigNet) > 0))
  #   
  #   # Get the names of the vertices collapsed
  #   NodesInVertices <- igraph::V(MergedBigNet)$name
  #   
  #   # and gives the vertices a more compact name
  #   igraph::V(MergedBigNet)$name <- sapply(igraph::V(MergedBigNet)$name, "[[", 1)
  #   
  #   # get the edge multiplicity
  #   AdjMat <- as.matrix(igraph::get.adjacency(MergedBigNet))
  #   FoundEdges <- which(AdjMat>0, arr.ind = TRUE)
  #   EdgMult <- AdjMat[FoundEdges]
  #   
  #   # define a "mult" edge attribute for edge
  #   MergedBigNet <- igraph::set_edge_attr(MergedBigNet, "mult", index = igraph::E(MergedBigNet), 1)
  #   
  #   # and for nodes
  #   MergedBigNet <- igraph::set_vertex_attr(MergedBigNet, "mult", index = igraph::V(MergedBigNet), sapply(NodesInVertices, length))
  #   
  #   # and remove duplicated edges. the mult attribute will keep track of the multiplicity of the edge
  #   MergedBigNet <- igraph::simplify(MergedBigNet, remove.multiple = TRUE, remove.loops = TRUE,
  #                            edge.attr.comb = list(mult = "sum"))
  #   
  #   # Get the number of ElPiGraphs participating to the network
  #   nNets <- lapply(NodesInVertices, length)
  #   
  #   # Filter out edges supported by less than MinEdgMult edges
  #   MergedBigNetFilt <- igraph::delete_edges(graph = MergedBigNet, edges = which(igraph::E(MergedBigNet)$mult < MinEdgMult))
  #   MergedBigNetFilt <- igraph::delete_vertices(graph = MergedBigNetFilt, v = which(igraph::V(MergedBigNet)$mult < MinNodeMult))
  #   
  #   MergedBigNetFilt <- igraph::induced.subgraph(graph = MergedBigNetFilt, vids = which(igraph::degree(MergedBigNetFilt) > 0))
  #   
  #   # Get the list of edges
  #   EdgeList <- igraph::get.edgelist(MergedBigNetFilt)
  #   
  #   # Initialize the matrix containing node position
  #   CombNodePos <- matrix(0, nrow = igraph::vcount(MergedBigNetFilt), ncol = ncol(AllNodePos[[1]]))
  #   
  #   # for each node of the big graph
  #   for(i in 1:igraph::vcount(MergedBigNetFilt)){
  #     # get the name of the edge
  #     vName <- unlist(igraph::V(MergedBigNetFilt)$name[i])
  #     # and all the associted nodes
  #     vGroup <- NodesInVertices[[which(sapply(NodesInVertices, function(x){vName %in% x}))]]
  #     
  #     # replace the edge name with an id
  #     EdgeList[EdgeList == vName] <- i
  #     
  #     # Extract graph id and node id from the node
  #     SplitSTR <- strsplit(vGroup, "_")
  #     GrID <- as.numeric(sapply(SplitSTR, "[[", 2))
  #     NodeID <- as.numeric(sapply(SplitSTR, "[[", 4))
  #     
  #     # get the list of nodes
  #     tNodePos <- NULL
  #     for(j in unique(GrID)){
  #       tNodePos <- rbind(tNodePos, AllNodePos[[j]][NodeID[GrID == j],])
  #     }
  #     # and compute the centroid
  #     CombNodePos[i,] <- colMeans(tNodePos)
  #   }
  #   
  #   # Return nodes and edges
  #   return(list(NodePos = CombNodePos, EdgeMat = EdgeList))
  #   
  # }
  
  
  
  
  
  
  
  # # Get all the node position on the bootstrapped ElPiGraph
  # AllNodePos <- lapply(BootPG, "[[", "NodePositions")
  # 
  # # And combine them into a matrix
  # AllNodePos_Mat <- do.call(rbind, AllNodePos)
  # 
  # # Get all the node position on the bootstrapped ElPiGraph
  # AllNodePos <- lapply(BootPG, "[[", "NodePositions")
  # 
  # 
  # # Also compute the distance matrix
  # AllDists <- distutils::PartialDistance(AllNodePos_Mat, AllNodePos_Mat)
  # 
  # plot(AllNodePos_Mat[,1:2])
  # KM <- kmeans(x = AllNodePos_Mat, centers = BootPG[[1]]$NodePositions)
  # 
  # 
  # plot(AllNodePos_Mat[,1:2])
  # points(tree_data[,1:2], pch = 2, col = "blue")
  # points(AllNodePos_Mat[rowSums(AllDists < .07) > 22, 1:2], col='red')
  # 
  # hist(apply(AllDists, 1, quantile, .25))
  # abline(v=median(AllDists))
  # 
  # plot(AllNodePos_Mat[apply(AllDists, 1, quantile, .1) < quantile(AllDists, .1),1:2])
  # 
  # NodesPerGraph <- sapply(BootPG, function(x) {nrow(x$NodePositions)})
  # 
  # GraphID_Vect <- lapply(1:length(BootPG), function(i){
  #   rep(i, NodesPerGraph[i])
  # })
  # 
  # NodeID_Vect <- lapply(NodesPerGraph, function(i){
  #   1:i
  # })
  # 
  # GraphID_Vect <- do.call(c, GraphID_Vect)
  # NodeID_Vect <- do.call(c, NodeID_Vect)
  # 
  # nClust <-
  # 
  # 
  # plot(AllNodePos_Mat[,1:2])
  # 
  # lapply(split(GraphID_Vect, KM$cluster), function(x){length(unique(x))})
  # 
  # groups <- cutree(hclust(as.dist(AllDists)), k = max(NodeID_Vect))
  # 
  # 
  # AdjMat <- matrix(0, nrow = max(NodeID_Vect), ncol = max(NodeID_Vect))
  # 
  # for(i in 1:(length(BootPG)-1)){
  #   for(k in 1:nrow(BootPG[[i]]$Edges)){
  #     AdjMat[BootPG[[i]]$Edges[k, 1]] <-
  #   }
  # 
  #   for(j in (i+1):length(BootPG)){
  #     apply(AllDists[GraphID_Vect == i, GraphID_Vect == j], 1, which.min)
  #   }
  # }



}







#' Find the points associted with the final ElPiGraph structure
#'
#' @param X numeric matrix (rows are points)
#' @param BootPG a list of ElPiGraph structures
#' @param TrimmingRadius the trimming radius to use. If NULL (the default), the one provided by the single ElPiGraph structures will be used
#'
#' @return
#' @export
#'
#' @examples
FindAssocited <- function(X, BootPG, TrimmingRadius = NULL) {
  
  SquaredX <- rowSums(X^2)
  
  if(is.null(TrimmingRadius)){
    AssocitedPoints <- sapply(BootPG, function(tStruct){
      PD <- PartitionData(X = X, NodePositions = tStruct$NodePositions, SquaredX = SquaredX, TrimmingRadius = tStruct$TrimmingRadius, nCores = 1)
      return(PD$Partition != 0)
    })
  } else {
    AssocitedPoints <- sapply(BootPG, function(tStruct){
      PD <- PartitionData(X = X, NodePositions = tStruct$NodePositions, SquaredX = SquaredX, TrimmingRadius = TrimmingRadius, nCores = 1)
      return(PD$Partition != 0)
    })
  }
  
  return(rowSums(AssocitedPoints))
}









CollapseNodes <- function(NodePositions, Edges) {
  
}
