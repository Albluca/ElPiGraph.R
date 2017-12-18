#' Ex
#'
#' @param Edges
#' @param ProjStruct
#' @param EdgeSeq
#'
#' @return
#' @export
#'
#' @examples
getPseudotime <- function(Edges, ProjStruct, EdgeSeq){

  Pt <- rep(NA, nrow(ProjStruct$X_projected))
  tLen <- 0
  NodePos <- 0

  for(i in 2:length(EdgeSeq)){
    SelEdgID <- which(
      apply(
        apply(Edges, 1, function(x) {
          x %in% EdgeSeq[(i-1):i]
        }), 2, all)
    )

    # print(paste(i, SelEdgID, tLen))

    if(length(SelEdgID) != 1){
      stop("Path not found in the graph")
    }

    Selected <- ProjStruct$EdgeID == SelEdgID
    if(all(Edges[SelEdgID,] == EdgeSeq[(i-1):i])){
      rev <- FALSE
    } else {
      rev <- TRUE
    }

    Pos <- ProjStruct$ProjectionValues[Selected]
    Pos[Pos <= 0] <- 0
    Pos[Pos >= 1] <- 1

    if(rev){
      Pos <- 1 - Pos
    }

    if(sum(Selected)>0){
      Pt[Selected] <- tLen + Pos*ProjStruct$EdgeLen[SelEdgID]
    }

    tLen <- tLen + ProjStruct$EdgeLen[SelEdgID]
    NodePos <- cbind(NodePos, tLen)
  }

  return(list(Pt = Pt, PathLen = tLen, NodePos = as.vector(NodePos)))

}













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






#' Title
#'
#' @param ExpData 
#' @param Paths 
#' @param TargetPG 
#' @param Partition 
#' @param PrjStr 
#' @param Main 
#' @param genes 
#'
#' @return
#' @export
#'
#' @examples
CompareExpOnBranches <- function(ExpData,
                                 Paths,
                                 TargetPG,
                                 Partition,
                                 PrjStr,
                                 Main = "",
                                 genes = 4) {
  
  CombDF <- NULL

  if(is.numeric(genes)){
    
    GenesByVar <- apply(ExpData, 1, var)
    
    if(length(GenesByVar) <= genes){
      genes = length(GenesByVar)
    }
    
    genes <- names(GenesByVar[order(GenesByVar, decreasing = TRUE)])[1:genes]
    
  }
  
  tExpData <- ExpData[genes, ]
  
  for(i in 1:length(Paths)){
    PtOnPath <- getPseudotime(Edges = TargetPG$Edges$Edges,
                              ProjStruct = PrjStr, EdgeSeq = Paths[[i]])
    
    PtVect <- PtOnPath$Pt
    names(PtVect) <- colnames(tExpData)
    MetlExp <- reshape::melt(t(tExpData))
    
    CombDF <- rbind(
      CombDF, data.frame(Pt = PtVect[as.character(MetlExp$X1)],
                         gene = MetlExp$X2, exp = MetlExp$value,
                         traj = i)
    )
    
  }
  
  CombDF$traj <- factor(CombDF$traj)
  
  CombDF <- CombDF[!is.na(CombDF$Pt), ]
  
  if(nrow(CombDF)>0){
    p <- ggplot2::ggplot(CombDF,
                         ggplot2::aes(x=Pt, y=exp, color = traj)) + ggplot2::geom_point(alpha = .3) +
      ggplot2::geom_smooth() + ggplot2::scale_color_discrete("Branch") +
      ggplot2::facet_wrap(~gene, scales = "free_y") +
      ggplot2::labs(title = Main, y = "Gene expression", x = "Pseudotime")
    
    return(p)
    
  } else {
    
    return(NULL)
    
  }
  
}






















#' Title
#'
#' @param ExpData 
#' @param Paths 
#' @param TargetPG 
#' @param Partition 
#' @param PrjStr 
#' @param Main 
#' @param genes 
#'
#' @return
#' @export
#'
#' @examples
ExpOnPath <- function(ExpData,
                      Group = NULL,
                      Path,
                      TargetPG,
                      Partition,
                      PrjStr,
                      Main = "",
                      genes = 4) {
                                 
  
  if(is.null(Group)){
    Group <- rep("N/A", ncol(ExpData))
  }
  
  if(is.numeric(genes)){
    
    GenesByVar <- apply(ExpData, 1, var)
    
    if(length(GenesByVar) <= genes){
      genes = length(GenesByVar)
    }
    
    genes <- names(GenesByVar[order(GenesByVar, decreasing = TRUE)])[1:genes]
    
  }
  
  tExpData <- ExpData[genes, ]
  
  PtOnPath <- getPseudotime(Edges = TargetPG$Edges$Edges,
                            ProjStruct = PrjStr, EdgeSeq = Path)
  
  PtVect <- PtOnPath$Pt
  names(PtVect) <- colnames(tExpData)
  MetlExp <- reshape::melt(t(tExpData))
  
  CombDF <- data.frame(Pt = PtVect[as.character(MetlExp$X1)],
                       gene = MetlExp$X2, exp = MetlExp$value,
                       group = Group)
  
  CombDF <- CombDF[!is.na(CombDF$Pt), ]
  
  if(nrow(CombDF)>0){
    p <- ggplot2::ggplot(CombDF,
                         ggplot2::aes(x=Pt, y=exp)) +
      ggplot2::geom_point(ggplot2::aes(color = group), alpha = .3) +
      ggplot2::geom_smooth() + ggplot2::scale_color_discrete("Group") +
      ggplot2::facet_wrap(~gene, scales = "free_y") +
      ggplot2::labs(title = Main, y = "Gene expression", x = "Pseudotime")
    
    return(p)
    
  } else {
    
    return(NULL)
    
  }
  
}
































#' Title
#'
#' @param X
#' @param NodePositions
#' @param Edges
#' @param Partition
#'
#' @return
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
              EdgeID = EdgeID, EdgeLen = EdgeLen))

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

