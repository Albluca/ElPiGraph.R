#' Title
#'
#' @param ElasticMatrix
#'
#' @return
#' @export
#'
#' @examples
getPrimitiveGraphStructureBarCode <- function(ElasticMatrix) {

  Mu = diag(ElasticMatrix)
  L = ElasticMatrix - diag(Mu)
  Connectivities = colSums(L>0)
  Mcon <- max(Connectivities)

  N <- table(factor(Connectivities, levels = 1:Mcon))
  barcode = paste0('||', nrow(ElasticMatrix))

  if(Mcon <= 2){
    barcode <- paste0('0',barcode)
  } else {
    barcode <- paste0(paste(rev(N[names(N)>=3]), collapse = '|'), barcode)
  }

  return(barcode)
}



































#' Project data points on the precipal graph
#'
#' @param X numerical matrix containg points on the rows and dimensions on the columns
#' @param NodePositions numerical matrix containg the positions of the nodes on the rows
#' (must have the same dimensionality of X)
#' @param Edges a 2-dimensional matrix containing edges as pairs of integers. The integers much
#' match the rows of NodePositions
#' @param Partition a Partition vector associating points to at most one of the nodes of the graph.
#' It can be NULL, in which case it will be computed by the algorithm
#'
#' @return A list with several elements:
#' \itemize{
#'  \item{"X_projected "}{A matrix containing the projection of the points (on rows) on the edges of the graph}
#'  \item{"MSEP "}{The mean squared error (distance) of the points from the graph}
#'  \item{"ProjectionValues "}{The normalized position of the point on its associted edge.
#'  A value <0 indicates a projection before the initial position of the node.
#'  A value >1 indicates a projection after the final position of the node.
#'  A value betwen 0 and 1 indicates at which percentage of the edge length the point is being projected,
#'  e.g., a value of 0.3 indicates the 30\%.}
#'  \item{"EdgeID "}{An integer indicating the id of the edge on which each point has been projected. Note that
#'  if a point is projected on a node, this id will indicate one of the edges connected to that node.}
#'  \item{"EdgeLen "}{The length of the edges described by the Edges input matrix}
#'  \item{"NodePositions "}{the NodePositions input matrix}
#'  \item{"Edges "}{the Edges input matrix}
#' }
#' 
#' @export
#'
#' @examples
project_point_onto_graph <- function(X, NodePositions, Edges, Partition = NULL){

  # %% this function calculates piece-wise linear projection of a dataset onto
  # %% the graph defined by NodePositions and Edges
  # % Input arguments:
  #   % X - is the dataset
  # % NodePositions, Edges - definition of graph embedment
  # % partition - integer vector of the length equal to size(X,1) defining
  # % the closest node index in the graph
  # %
  # % Outputs:
  #   % X_projected: projected dataset (same space as X)
  # % MSE - mean squared error (distance) from X to graph
  # % EdgeIndices - integer vector of length size(X,1) with indications of
  # % on which edges the projection was done
  # % ProjectionValues - real vector of length size(X,1) with values between 0
  # % and 1 indicating where between Edge(index,1) and Edge(index,2) the
  # % projection was done.

  if(is.null(Partition)){
    Partition <- PartitionData(X, NodePositions, rowSums(X^2))$Partition
  }
  
  X_projected = matrix(0, nrow = nrow(X), ncol = ncol(X))
  ProjectionValues = rep(Inf, nrow(X))
  Distances_squared = rep(Inf, nrow(X))
  EdgeID <- rep(NA, nrow(X))
  EdgeLen <- rep(NA, nrow(Edges))

  for(i in 1:nrow(Edges)){
    Idxs <- which(Partition %in% Edges[i,])

    PrjStruct <- project_point_onto_edge(X = X[Idxs, ], NodePositions = NodePositions[Edges[i,], ], Edge = c(1,2))

    if(length(Idxs)> 0){
      ToFill <- PrjStruct$Distance_Squared < Distances_squared[Idxs]

      X_projected[Idxs[ToFill],] <- PrjStruct$X_Projected[ToFill,]
      ProjectionValues[Idxs[ToFill]] <- PrjStruct$Projection_Value[ToFill]
      Distances_squared[Idxs[ToFill]] <- PrjStruct$Distance_Squared[ToFill]
      EdgeID[Idxs[ToFill]] <- i
    }

    EdgeLen[i] <- sqrt(PrjStruct$EdgeLen_Squared)

  }

  return(list(X_projected = X_projected,
              MSEP = mean(Distances_squared),
              ProjectionValues = ProjectionValues,
              EdgeID = EdgeID,
              EdgeLen = EdgeLen,
              NodePositions = NodePositions,
              Edges = Edges))

}
















#' Title
#'
#' @param X
#' @param NodePositions
#' @param Edge
#'
#' @return
#' @export
#'
#' @examples
project_point_onto_edge <- function(X, NodePositions, Edge) {

  if(is.null(dim(X))){
    dim(X) <- c(1, length(X))
  }

  vec = NodePositions[Edge[2],] - NodePositions[Edge[1],]
  u = (t(t(X) - NodePositions[Edge[1],]) %*% vec) / as.vector(vec %*% vec)

  X_Projected <- X
  X_Projected[] <- NA

  if(any(u<0)){
    X_Projected[u<0, ] <- rep(NodePositions[Edge[1],], each = sum(u<0))
  }

  if(any(u>1)){
    X_Projected[u>1, ] <- rep(NodePositions[Edge[2],], each = sum(u>1))
  }

  OnEdge <- (u>=0 & u<=1)

  if(any(OnEdge)){
    UExp <- rep(u[OnEdge], each=length(vec))
    dim(UExp) <- c(length(vec), sum(OnEdge))

    X_Projected[OnEdge, ] <- t(UExp*vec + NodePositions[Edge[1],])
  }

  distance_squared <- rowSums((X_Projected - X) * (X_Projected - X))

  return(list(X_Projected = X_Projected, Projection_Value = as.vector(u),
              Distance_Squared = as.vector(distance_squared),
              EdgeLen_Squared = sum(vec^2)))

}




























#' Title
#'
#' @param X 
#' @param NodePositions 
#' @param ElasticMatrix 
#' @param PartData 
#' @param ComputeMSEP 
#'
#' @return
#' @export
#'
#' @examples
ReportOnPrimitiveGraphEmbedment <- function(X, NodePositions, ElasticMatrix, PartData=NULL, ComputeMSEP = FALSE) {

  # %   This function computes various measurements concerning a primitive
  # %   graph embedment
  # %
  # %           BARCODE is barcode in form ...S4|S3||N, where N is number of
  # %               nodes, S3 is number of 3-stars, S4 (S5,...) is number of
  # %               four (five,...) stars, etc.
  # %           ENERGY is total elastic energy of graph embedment (ENERGY = MSE + UE +
  #                                                                  %               UR)
  # %           NNODES is number of nodes.
  # %           NEDGES is number of edges
  # %           NRIBS is number of two stars (nodes with two otherr connected
  #                                           %               nodes).
  # %           NSTARS is number of stars with 3 and more leaves (nodes
  #                                                               %               connected with central node).
  # %           NRAYS2 is sum of rays minus doubled number of nodes.
  # %           MSE is mean square error or assessment of data approximation
  # %               quality.
  # %           MSEP is mean square error after piece-wise linear projection on the edges
  # %           FVE is fraction of explained variance. This value always
  # %               between 0 and 1. Greater value means higher quality of
  # %               data approximation.
  # %           FVEP is same as FVE but computed after piece-wise linear projection on the edges
  # %           UE is total sum of squared edge lengths.
  # %           UR is total sum of star deviations from harmonicity.
  # %           URN is UR * nodes
  # %           URN2 is UR * nodes^2
  # %           URSD is standard deviation of UR???

  Mu = diag(ElasticMatrix)
  L = ElasticMatrix - diag(Mu)
  Connectivities <- colSums(L>0)
  N <- table(factor(Connectivities, levels = 1:max(Connectivities)))
  DecodedMat <- DecodeElasticMatrix(ElasticMatrix)

  TotalVariance = sum(apply(X, 2, var))
  BranchingFee = 0

  BARCODE = getPrimitiveGraphStructureBarCode(ElasticMatrix)

  if(is.null(PartData)){
    PartData <- PartitionData(X = X, NodePositions = NodePositions, rowSums(X^2))
  }

  Energies <- distutils::ElasticEnergy(X = X, NodePositions = NodePositions,
                                                 ElasticMatrix = ElasticMatrix,
                                                 Dists = PartData$Dists, BranchingFee = BranchingFee)

  NNODES = nrow(NodePositions)
  NEDGES = nrow(DecodedMat$Edges)


  if(length(N)>1){
    NRIBS = N[2]
  } else{
    NRIBS = 0
  }

  if(length(N)>2){
    NSTARS = N[3]
  } else {
    NSTARS = 0
  }

  NRAYS = 0
  NRAYS2 = 0


  if(ComputeMSEP){
    NodeProj <- project_point_onto_graph(X, NodePositions = NodePositions,
                                    Edges = DecodedMat$Edges, Partition = PartData$Partition)
    MSEP = NodeProj$MSEP
    FVEP = (TotalVariance-MSEP)/TotalVariance
  } else {
    MSEP = NA
    FVEP = NA
  }

  FVE = (TotalVariance-Energies$MSE)/TotalVariance
  URN = Energies$RP*NNODES
  URN2 = Energies$RP*NNODES*NNODES
  URSD = 0

  return(list(BARCODE = BARCODE, ENERGY = Energies$ElasticEnergy, NNODES = NNODES, NEDGES = NEDGES,
           NRIBS = NRIBS, NSTARS = NSTARS, NRAYS = NRAYS, NRAYS2 = NRAYS2,
           MSE = Energies$MSE, MSEP = MSEP, FVE = FVE, FVEP = FVEP, UE = Energies$EP, UR = Energies$RP,
           URN = URN, URN2 = URN2, URSD = URSD))


}

