# Base functions: Distance and energy computation --------------------------

#' Assign data points to a set of nodes
#'
#' @param X an n-by-m numeric matrix with the coordinates of the data points
#' @param NodePositions an k-by-m numeric matrix with the coordiante of the nodes
#' @param TrimmingRadius Maximum distance of data points to the nodes to assign a point to a node
#' @param nCores number of cores to use.
#' @param SquaredX the sum by row of the squared positions rowSums(X^2). If NULL it will be calculated by the fucntion.
#'
#' @return A list containing two components: Partition (containing the associated nodes) and 
#' Dists (containing the squqred distance from the node)
#' 
#' @export
#'
#' @examples

PartitionData <- function(X, NodePositions, SquaredX = NULL, TrimmingRadius = Inf, nCores = 1) {
  
  if(is.null(SquaredX)){
    SquaredX = rowSums(X^2)
  }
  
  Dists <- distutils::Partition(Ar = X, Br = NodePositions, SquaredAr = SquaredX)

  PartVect <- Dists$Partition
  Dist <- Dists$Dist
  
  # print("DEBUG (PartitionData):")
  # print(Dists$Partition)
  # print(table(PartVect))
  
  if(is.finite(TrimmingRadius)){
    # print("Filtering")
    ToFilter <- (Dists$Dist > TrimmingRadius^2)
    if(sum(ToFilter)>0){
      # print(sum(ToFilter))
      PartVect[ToFilter] <- 0
      # print(Dists$Partition)
    }
    Dist[Dist > TrimmingRadius^2] <- TrimmingRadius^2
  }

  # print("DEBUG (PartitionData):")
  # print(table(PartVect))
  
  return(list(Partition = PartVect, Dists = Dist))

}



# Base function: Function to deal with elastic matrices --------------------------

#' Create a uniform elastic matrix from a set of edges
#'
#' @param Edges an e-by-2 matrix containing the index of the edges connecting the nodes
#' @param Lambda the lambda parameter. It can be a real value or a vector of lenght e
#' @param Mu the mu parameter. It can be a real value or a vector with a length equal to the number of nodes
#'
#' @return the elastic matrix
#' 
#' @export
#'
#' @examples
MakeUniformElasticMatrix <- function(Edges, Lambda, Mu) {

  NumberOfNodes <- max(Edges)
  NumberOfEdges <- nrow(Edges)

  ElasticMatrix <- matrix(0, nrow = NumberOfNodes, ncol = NumberOfNodes)
  AdjacencyMatrix <- matrix(0, nrow = NumberOfNodes, ncol = NumberOfNodes)

  ElasticMatrix[Edges] <- Lambda
  ElasticMatrix[t(apply(Edges, 1, rev))] <- Lambda

  AdjacencyMatrix[Edges] <- 1
  AdjacencyMatrix[t(apply(Edges, 1, rev))] <- 1

  Connectivities = rowSums(AdjacencyMatrix)
  MuVector = Mu*(Connectivities>1)

  return(ElasticMatrix + diag(MuVector))

}



#' Create an Elastic matrix from a set of edges
#'
#' @param Lambdas the lambda parameters. Either a single value (which will be used for all the edges),
#' or a vector containing the values for each edge
#' @param Mus the mu parameters. Either a single value (which will be used for all the nodes),
#' or a vector containing the values for each node
#' @param Edges an e-by-2 matrix containing the index of the edges connecting the nodes
#'
#' @return the elastic matrix
#' 
#' @export
#'
#' @examples
Encode2ElasticMatrix <- function(Edges, Lambdas, Mus) {

  NumberOfNodes = max(max(Edges))
  NumberOfEdges = nrow(Edges)

  ElasticMatrix = matrix(0, nrow = NumberOfNodes, ncol = NumberOfNodes)

  if(length(Lambdas)==1){
    Lambdas <- rep(Lambdas, NumberOfEdges)
  }
  
  if(length(Mus)==1){
    Mus <- rep(Mus, NumberOfNodes)
  }
  
  for(i in 1:NumberOfEdges){
    ElasticMatrix[Edges[i,1],Edges[i,2]] = Lambdas[i]
    ElasticMatrix[Edges[i,2],Edges[i,1]] = Lambdas[i]
  }

  return(ElasticMatrix+diag(Mus))
}














#' Compute the Laplacian matrix
#'
#' @param ElasticMatrix an e-by-e elastic matrix
#'
#' @return the Laplacian matrix
#' 
#' @export
#'
#' @examples
ComputeSpringLaplacianMatrix <- function(ElasticMatrix) {

  NumberOfNodes <- nrow(ElasticMatrix)
  # first, make the vector of mu coefficients
  Mu <- diag(ElasticMatrix)
  # create the matrix with edge elasticity moduli at non-diagonal elements
  Lambda <- ElasticMatrix - diag(Mu)
  # Diagonal matrix of edge elasticities
  LambdaSums <- colSums(Lambda)
  DL <- diag(LambdaSums)
  # E matrix (contribution from edges) is simply weighted Laplacian
  E <- DL-Lambda

  # S matrix (contribution from stars) is composed of Laplacian for positive strings (star edges) with
  # elasticities mu/k, where k is the order of the star, and Laplacian for
  # negative strings with elasticities -mu/k^2. Negative springs connect all
  # star leafs in a clique.

  StarCenterIndices <- which(Mu>0)
  S <- matrix(0, nrow = NumberOfNodes, ncol = NumberOfNodes)

  for (i in 1:length(StarCenterIndices)){

    Spart = matrix(0, nrow = NumberOfNodes, ncol = NumberOfNodes)
    # leaf indices
    leafs = which(Lambda[,StarCenterIndices[i]]>0)
    # order of the star
    K = length(leafs)

    Spart[StarCenterIndices[i],StarCenterIndices[i]] = Mu[StarCenterIndices[i]]
    Spart[StarCenterIndices[i],leafs] = -Mu[StarCenterIndices[i]]/K
    Spart[leafs,StarCenterIndices[i]] = -Mu[StarCenterIndices[i]]/K
    Spart[leafs,leafs] = Mu[StarCenterIndices[i]]/K^2
    S = S+Spart

  }

  return(E+S)

}




#' Converts ElasticMatrix into a set of edges and vectors of elasticities for edges and stars
#'
#' @param ElasticMatrix an e-by-e elastic matrix
#'
#' @return a list with three elements: a matrix with the edges (Edges), a vector of lambdas (Lambdas), and a vector of Mus (Mus)
#' 
#' @export
#'
#' @examples
DecodeElasticMatrix <- function(ElasticMatrix) {

  Mus <- diag(ElasticMatrix)
  L <- ElasticMatrix - diag(Mus)

  # L <- ElasticMatrix
  # diag(L) <- 0

  Edges <- which(L>0, arr.ind = TRUE)
  inds <- which(Edges[,1]<Edges[,2])

  Edges = Edges[inds,]
  
  if(is.null(dim(Edges))){
    dim(Edges) <- c(1, length(Edges))
  }
  
  Lambdas = L[Edges]

  return(list(Edges = Edges, Lambdas = Lambdas, Mus = Mus))
}







#' Estimates the relative difference between two node configurations
#'
#' @param NodePositions a k-by-m numeric matrix with the coordiantes of the nodes in the old configuration
#' @param NewNodePositions a k-by-m numeric matrix with the coordiantes of the nodes in the new configuration
#' @param Mode an integer indicating the modality used to compute the difference (currently only 1 is an accepted value)
#' @param X an n-by-m numeric matrix with the coordinates of the data points
#' @param BranchingFee currenty not used
#'
#' @return
#' @export
#'
#' @examples
ComputeRelativeChangeOfNodePositions <- function(NodePositions,
                                                 NewNodePositions,
                                                 Mode = 1,
                                                 BranchingFee = 0) {


  # diff = norm(NodePositions-NewNodePositions)/norm(NewNodePositions);
  # diff = immse(NodePositions,NewNodePositions)/norm(NewNodePositions);
  if(Mode == 1){
    diff = rowSums((NodePositions-NewNodePositions)^2)/rowSums(NewNodePositions^2)
    diff = max(diff)
  }

  # diff = mean(diff);

  return(diff)

}











#' Function fitting a primitive elastic graph to the data
#'
#' @param X is n-by-m matrix containing the positions of the n points in the m-dimensional space
#' @param NodePositions is k-by-m matrix of positions of the graph nodes in the same space as X
#' @param ElasticMatrix is a k-by-k symmetric matrix describing the connectivity and the elastic
#' properties of the graph. Star elasticities (mu coefficients) are along the main diagonal
#' (non-zero entries only for star centers), and the edge elasticity moduli are at non-diagonal elements.
#' @param MaxNumberOfIterations is an integer number indicating the maximum number of iterations for the EM algorithm
#' @param TrimmingRadius is a real value indicating the trimming radius, a parameter required for robust principal graphs
#' (see https://github.com/auranic/Elastic-principal-graphs/wiki/Robust-principal-graphs)
#' @param eps a real number indicating the minimal relative change in the nodenpositions
#' to be considered the graph embedded (convergence criteria)
#' @param verbose is a boolean indicating whether diagnostig informations should be plotted
#' @param Mode integer, the energy mode. It can be 1 (difference is computed using the position of the nodes) and
#' 2 (difference is computed using the changes in elestic energy of the configuraztions)
#' @param SquaredX the sum (by node) of X squared. It not specified, it will be calculated by the fucntion
#' @param FastSolve boolean, shuold the Fastsolve of Armadillo by enabled?
#' @param DisplayWarnings boolean, should warning about convergence be displayed? 
#' 
#'
#' @return
#' @export
#'
#' @examples
PrimitiveElasticGraphEmbedment <- function(X,
                                           NodePositions,
                                           ElasticMatrix,
                                           MaxNumberOfIterations,
                                           TrimmingRadius,
                                           eps,
                                           Mode = 1,
                                           SquaredX = NULL,
                                           verbose = FALSE,
                                           FastSolve = FALSE,
                                           DisplayWarnings = FALSE,
                                           prob = 1) {

  N = nrow(X)
  PointWeights = rep(1, N)

  #Auxiliary computations
  
  SpringLaplacianMatrix = ComputeSpringLaplacianMatrix(ElasticMatrix)
  
  # Main iterative EM cycle: partition, fit given the partition, repeat

  if(is.null(SquaredX)){
    SquaredX <- rowSums(X^2)
  }
  
  
  # print(paste("DEBUG (PrimitiveElasticGraphEmbedment):",TrimmingRadius))
  PartDataStruct <- PartitionData(X = X, NodePositions = NodePositions,
                                  SquaredX = SquaredX,
                                  TrimmingRadius = TrimmingRadius)
  
  # print("DEBUG (PrimitiveElasticGraphEmbedment):")
  # print(table(PartDataStruct$Partition))
  
  if(verbose | Mode == 2){
    OldPriGrElEn <- distutils::ElasticEnergy(X = X,
                                             NodePositions =  NodePositions,
                                             ElasticMatrix = ElasticMatrix,
                                             Dists = PartDataStruct$Dists,
                                             BranchingFee = 0)
  } else {
    OldPriGrElEn <- list(ElasticEnergy = NA, MSE = NA, EP = NA, RP = NA)
  }
  
  Converged <- FALSE
  
  for(i in 1:MaxNumberOfIterations){
    
    if(MaxNumberOfIterations == 0){
      
      Converged <- TRUE
      
      PriGrElEn <- OldPriGrElEn
      difference = NA
      
      NewNodePositions <- distutils::FitGraph2DataGivenPartition(X = X,
                                                                 PointWeights = PointWeights,
                                                                 NodePositions = NodePositions,
                                                                 SpringLaplacianMatrix = SpringLaplacianMatrix,
                                                                 partition = PartDataStruct$Partition,
                                                                 FastSolve = FastSolve)
      
      break()
      
    }
    
    # Updated positions
    
    
    # if(prob<1){
    #   NewNodePositions <- distutils::FitGraph2DataGivenPartition(X = X[runif(nrow(X)) < prob, ],
    #                                                              PointWeights = PointWeights,
    #                                                              NodePositions = NodePositions,
    #                                                              SpringLaplacianMatrix = SpringLaplacianMatrix,
    #                                                              partition = PartDataStruct$Partition,
    #                                                              FastSolve = FastSolve)
    # } else {
      NewNodePositions <- distutils::FitGraph2DataGivenPartition(X = X,
                                                                 PointWeights = PointWeights,
                                                                 NodePositions = NodePositions,
                                                                 SpringLaplacianMatrix = SpringLaplacianMatrix,
                                                                 partition = PartDataStruct$Partition,
                                                                 FastSolve = FastSolve)
    # }
    
    NewNodePositions <- distutils::FitGraph2DataGivenPartition(X = X,
                                                                 PointWeights = PointWeights,
                                                                 NodePositions = NodePositions,
                                                                 SpringLaplacianMatrix = SpringLaplacianMatrix,
                                                                 partition = PartDataStruct$Partition,
                                                               FastSolve = FastSolve)
    
    
    if(verbose | Mode == 2){
      PriGrElEn <- distutils::ElasticEnergy(X = X,
                                                       NodePositions = NewNodePositions,
                                                       ElasticMatrix =  ElasticMatrix,
                                                       Dists = PartDataStruct$Dists,
                                                       BranchingFee = 0)
    } else {
      PriGrElEn <- list(ElasticEnergy = NA, MSE = NA, EP = NA, RP = NA)
    }
    
    # Look at differences
    
    if(Mode == 1){
      difference <- ComputeRelativeChangeOfNodePositions(NodePositions, NewNodePositions)
    }
    
    if(Mode == 2){
      difference <- (OldPriGrElEn$ElasticEnergy - PriGrElEn$ElasticEnergy)/PriGrElEn$ElasticEnergy
    }
    
    # Print Info
    
    if(verbose){
      print(paste("Iteration", i, "diff=", signif(difference, 5), "E=", signif(PriGrElEn$ElasticEnergy, 5),
                  "MSE=", signif(PriGrElEn$MSE, 5), "EP=", signif(PriGrElEn$EP, 5),
                  "RP=", signif(PriGrElEn$RP, 5)))
    }
    
    # Have we converged?
    
    if(is.nan(difference)){
      difference = 0
    }
    
    if(difference < eps){
      Converged <- TRUE
      break()
    } else {
      if(i < MaxNumberOfIterations){
        PartDataStruct <- PartitionData(X = X, NodePositions = NewNodePositions, SquaredX = SquaredX,
                                        TrimmingRadius = TrimmingRadius)
        
        NodePositions = NewNodePositions
        OldPriGrElEn = PriGrElEn
      }
    }
    
  }
  
  if(DisplayWarnings & !Converged){
    warning(paste0("Maximum number of iterations (", MaxNumberOfIterations, ") has been reached. diff = ", difference))
  }

  if(!verbose & Mode != 2){
    PriGrElEn <- distutils::ElasticEnergy(X = X,
                                                     NodePositions = NewNodePositions,
                                                     ElasticMatrix =  ElasticMatrix,
                                                     Dists = PartDataStruct$Dists,
                                                     BranchingFee = 0)
    # print(paste("Iteration", i, "diff=", signif(difference, 5), "E=", signif(PriGrElEn$ElasticEnergy, 5),
    #             "MSE=", signif(PriGrElEn$MSE, 5), "EP=", signif(PriGrElEn$EP, 5),
    #             "RP=", signif(PriGrElEn$RP, 5)))
  }
  
  # PriGrElEn <- distutils::ElasticEnergy(X = X, NodePositions =  NodePositions, ElasticMatrix =  ElasticMatrix,
  #                                                    Dists = PartDataStruct$Dists,
  #                                                    BranchingFee = 0)

  return(list(EmbeddedNodePositions = NewNodePositions,
              ElasticEnergy = PriGrElEn$ElasticEnergy,
              partition = PartDataStruct$Partition,
              MSE = PriGrElEn$RP,
              EP = PriGrElEn$RP,
              RP = PriGrElEn$RP))

}

