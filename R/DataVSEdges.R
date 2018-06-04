#' Title
#'
#' @param X a data matrix
#' @param TargetPG an ElPiGraph object
#' @param GroupsLab a vector of labels for the point of the matrix 
#'
#' @return a list with assocition tables and Chi-squred test for category associtions with Edges+Nodes and Nodes
#' @export
#'
#' @examples
EdgeCatAssociation <- function(X, TargetPG, GroupsLab = NULL, TrimmingRadius = Inf) {
  
  PartData <- PartitionData(X = X, NodePositions = TargetPG$NodePositions, SquaredX = rowSums(X^2), TrimmingRadius = TrimmingRadius)
  
  Prj <- project_point_onto_graph(X = X, NodePositions = TargetPG$NodePositions,
                           Edges = TargetPG$Edges$Edges, Partition = PartData$Patition)
  
  OnNode <- (Prj$ProjectionValues <= 0 | Prj$ProjectionValues >= 1)
  OnEdge <- (Prj$ProjectionValues > 0 & Prj$ProjectionValues < 1)
  
  Association <- rep(NA, nrow(X))
  
  Association[OnEdge] <- paste("Edge =", Prj$EdgeID[OnEdge])
  Association[OnNode] <- paste("Node =", PartData$Partition[OnNode])
  
  TB_E <- table(Association, GroupsLab)
  TB_N <- table(paste("Node =", PartData$Partition), GroupsLab)
  
  return(
    list(
      OnEdges = list(Table = TB_E, ChiTest = chisq.test(TB_E, simulate.p.value = TRUE)),
      OnNodes = list(Table = TB_N, ChiTest = chisq.test(TB_N, simulate.p.value = TRUE))
    )
  )
  
}










#' Compute "on the graph" distance
#'
#' @param X 
#' @param TargetPG 
#'
#' @return
#' @export
#'
#' @examples
#' 
#' 
#' library(ElPiGraph.R)
#' PG <- computeElasticPrincipalTree(X = tree_data, NumNodes = 50, InitNodes = 2, verbose = TRUE)
#' Dist <- DistanceOnGraph(X = tree_data, TargetPG = PG[[1]])
#' HC <- hclust(as.dist(Dist$FullDist))
#' GG <- cutree(HC, k = 10)
#' 
#' PlotPG(X = tree_data, TargetPG = PG[[1]], GroupsLab = factor(GG))
#' 
#' CompleteDist <- Dist$FullDist + Dist$DistFromGraph
#' HC <- hclust(as.dist(CompleteDist))
#' GGFull <- cutree(HC, k = 10)
#' 
#' PlotPG(X = tree_data, TargetPG = PG[[1]], GroupsLab = factor(GGFull))
#' 
#' table(GG, GGFull)
#' 
#' 
DistanceOnGraph <- function(X, TargetPG){
  
  # Get the project structure
  ProjStruct <- project_point_onto_graph(X = X,
                                         NodePositions = TargetPG$NodePositions,
                                         Edges = TargetPG$Edges$Edges,
                                         Partition = TargetPG$Partition)
  
  # Construct the graph
  Net <- igraph::graph_from_edgelist(ProjStruct$Edges, directed = FALSE)
  
  # Get the wigthted shortest distance for all fo the nodes of the graph
  NodesDist <- igraph::shortest.paths(graph = Net, weights = ProjStruct$EdgeLen)
  
  # Fix projestruct
  ProjStruct$ProjectionValues[ProjStruct$ProjectionValues<0] <- 0
  ProjStruct$ProjectionValues[ProjStruct$ProjectionValues>1] <- 1
  
  # Big dist mat
  FullDist <- matrix(Inf, ncol = nrow(X), nrow = nrow(X))
  # diag(FullDist) <- 0

  
  # for each pair of edges
  for(i in 2:igraph::ecount(Net)){
    for(j in 1:i){
      
      # print(c(i, j))
      
      Nodes_1 <- igraph::ends(graph = Net, es = i)
      Nodes_2 <- igraph::ends(graph = Net, es = j)
      
      if(all(rowSums(matrix(ProjStruct$Edges %in% Nodes_1, ncol = 2)) != 2)){
        Nodes_1 <- Nodes_1[,c(2:1)]
      }
      
      if(all(rowSums(matrix(ProjStruct$Edges %in% Nodes_1, ncol = 2)) != 2)){
        Nodes_2 <- Nodes_2[,c(2:1)]
      }
      
      NodesOnEdge1 <- which(ProjStruct$EdgeID == i)
      NodesOnEdge2 <- which(ProjStruct$EdgeID == j)
      
      DistBetweenNodes <- NodesDist[Nodes_1[1,], Nodes_2[1,]]
      
      
      if(length(NodesOnEdge1)>0 & length(NodesOnEdge1)>0){
        
        # Node 1/1
        
        DistMat <- matrix(DistBetweenNodes[1,1], nrow = length(NodesOnEdge1), ncol = length(NodesOnEdge2))
        
        DistMat <- (DistMat + ProjStruct$ProjectionValues[NodesOnEdge1] * ProjStruct$EdgeLen[i]) + 
          t(t(DistMat) + ProjStruct$ProjectionValues[NodesOnEdge2] * ProjStruct$EdgeLen[j])
        
        # Node 1/2
        
        DistMat2 <- matrix(DistBetweenNodes[1,2], nrow = length(NodesOnEdge1), ncol = length(NodesOnEdge2))
        
        DistMat2 <- (DistMat2 + ProjStruct$ProjectionValues[NodesOnEdge1] * ProjStruct$EdgeLen[i]) + 
          t(t(DistMat2) + (1-ProjStruct$ProjectionValues[NodesOnEdge2]) * ProjStruct$EdgeLen[j])
        
        DistMat <- pmin(DistMat, DistMat2)
        
        # Node 2/1
        
        DistMat2 <- matrix(DistBetweenNodes[2,1], nrow = length(NodesOnEdge1), ncol = length(NodesOnEdge2))
        
        DistMat2 <- (DistMat2 + (1-ProjStruct$ProjectionValues[NodesOnEdge1]) * ProjStruct$EdgeLen[i]) + 
          t(t(DistMat2) + ProjStruct$ProjectionValues[NodesOnEdge2] * ProjStruct$EdgeLen[j])
        
        DistMat <- pmin(DistMat, DistMat2)
        
        # Node 2/2
        
        DistMat2 <- matrix(DistBetweenNodes[2,2], nrow = length(NodesOnEdge1), ncol = length(NodesOnEdge2))
        
        DistMat2 <- (DistMat2 + (1-ProjStruct$ProjectionValues[NodesOnEdge1]) * ProjStruct$EdgeLen[i]) + 
          t(t(DistMat2) + (1-ProjStruct$ProjectionValues[NodesOnEdge2]) * ProjStruct$EdgeLen[j])
        
        DistMat <- pmin(DistMat, DistMat2)
        
        FullDist[NodesOnEdge1, NodesOnEdge2] <- DistMat
        FullDist[NodesOnEdge2, NodesOnEdge1] <- t(DistMat)
        
      }
      
      
      if(length(NodesOnEdge1)>0){
        # Points on edge 1
        FullDist[NodesOnEdge1, NodesOnEdge1] <- as.matrix(dist(ProjStruct$ProjectionValues[NodesOnEdge1]))
      }
      
      if(length(NodesOnEdge2)>0){
        # Points on edge 2
        FullDist[NodesOnEdge2, NodesOnEdge2] <- as.matrix(dist(ProjStruct$ProjectionValues[NodesOnEdge2]))
      }
      
    }
  }
  
  return(list(
    FullDist = FullDist,
    DistFromGraph = rowSums((X - ProjStruct$X_projected)^2)
  ))
  
}






#' Cross embedd the elastic graph
#'
#' @param X_Source 
#' @param X_Target 
#' @param TargetPG 
#' @param TrimmingRadius 
#'
#' @return
#' @export
#'
#' @examples
CrossEmbedment <- function(X_Source, X_Target, TargetPG, TrimmingRadius = Inf) {
  
  if(nrow(X_Source) != nrow(X_Target)){
    stop("Incompatible datasets")
  }
  
  if(ncol(X_Source) != ncol(TargetPG$NodePositions)){
    stop("Incompatible ElPiGraph")
  }
  
  PD <- ElPiGraph.R::PartitionData(X = X_Source,
                                   NodePositions = TargetPG$NodePositions,
                                   TrimmingRadius = TrimmingRadius)
  
  NodeEmbd <- sapply(as.list(sort(unique(PD$Partition))), function(i){
    
    if(sum(PD$Partition == 0)){
      return(rep(NA, ncol(X_Target)))
    }
    
    if(sum(PD$Partition == i)>1){
      return(colMeans(X_Target[PD$Partition == i,]))
    } else {
      return(X_Target[PD$Partition == i,])
    }
    
  })
  
  if(any(PD$Partition == 0)){
    TargetPG$NodePositions <- t(NodeEmbd[,-1])
  } else {
    TargetPG$NodePositions <- t(NodeEmbd)
  }
  
  return(TargetPG)
  
}



