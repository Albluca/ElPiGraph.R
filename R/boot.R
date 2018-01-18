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
#' @return a numeric vector with the same length as the number of rows of X. Higher values indicates larger uncertainty.
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
  
  return(PointUnc)
}





