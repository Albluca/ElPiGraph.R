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




# 
# 
# GenertateConsensusGraph <- function(BootPG, Mode = "NodeDist") {
#   
#   AllNodePos <- lapply(BootPG, "[[", "NodePositions")
#   
#   AllNodePos_Mat <- do.call(rbind, AllNodePos)
#   
#   AllDists <- distutils::PartialDistance(AllNodePos_Mat, AllNodePos_Mat)
# 
#   plot(AllNodePos_Mat[,1:2])
#   KM <- kmeans(x = AllNodePos_Mat, centers = BootPG[[1]]$NodePositions)
#   
#   
#   plot(AllNodePos_Mat[,1:2])
#   points(tree_data[,1:2], pch = 2, col = "blue")
#   points(AllNodePos_Mat[rowSums(AllDists < .07) > 22, 1:2], col='red')
#   
#   hist(apply(AllDists, 1, quantile, .25))
#   abline(v=median(AllDists))
#   
#   plot(AllNodePos_Mat[apply(AllDists, 1, quantile, .1) < quantile(AllDists, .1),1:2])
#   
#   NodesPerGraph <- sapply(BootPG, function(x) {nrow(x$NodePositions)})
#   
#   GraphID_Vect <- lapply(1:length(BootPG), function(i){
#     rep(i, NodesPerGraph[i])
#   })
#   
#   NodeID_Vect <- lapply(NodesPerGraph, function(i){
#     1:i
#   })
#   
#   GraphID_Vect <- do.call(c, GraphID_Vect)
#   NodeID_Vect <- do.call(c, NodeID_Vect)
#   
#   nClust <- 
#   
#   
#   plot(AllNodePos_Mat[,1:2])
#   
#   lapply(split(GraphID_Vect, KM$cluster), function(x){length(unique(x))})
#   
#   groups <- cutree(hclust(as.dist(AllDists)), k = max(NodeID_Vect))
#   
#   
#   AdjMat <- matrix(0, nrow = max(NodeID_Vect), ncol = max(NodeID_Vect))
#   
#   for(i in 1:(length(BootPG)-1)){
#     for(k in 1:nrow(BootPG[[i]]$Edges)){
#       AdjMat[BootPG[[i]]$Edges[k, 1]] <- 
#     }
#     
#     for(j in (i+1):length(BootPG)){
#       apply(AllDists[GraphID_Vect == i, GraphID_Vect == j], 1, which.min)
#     }
#   }
#   
#   
#   
# }
# 
# 
# 
# 
# 
# 
# 
