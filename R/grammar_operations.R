

# Some elementary graph transformations -----------------------------------

f_remove_node <- function(NodePositions, ElasticMatrix, NodeNumber) {

  # remove from the graph node number NodeNumber

  return(list(NodePositions = NodePositions[-NodeNumber, ],
              ElasticMatrix = ElasticMatrix[-NodeNumber, -NodeNumber]))

}



f_reattach_edges <- function(ElasticMatrix, NodeNumber1, NodeNumber2) {

  # reattaches all edges connected with NodeNumber2 to NodeNumber1
  # and make a new star with an elasticity average of two merged stars

  ElasticMatrix2 <- ElasticMatrix
  mus <- diag(ElasticMatrix)
  lm <- ElasticMatrix-diag(mus)

  ElasticMatrix2[NodeNumber1,] <- apply(rbind(lm[NodeNumber1,],lm[NodeNumber2,]), 2, max)
  ElasticMatrix2[,NodeNumber1] <- apply(rbind(lm[,NodeNumber1],lm[,NodeNumber2]), 2, max)

  ElasticMatrix2[NodeNumber1,NodeNumber1] <-
    ElasticMatrix[NodeNumber1,NodeNumber1]+ElasticMatrix[NodeNumber2,NodeNumber2]/2

  return(list(ElasticMatrix = ElasticMatrix2))

}



f_add_nonconnected_node <- function(NodePositions, ElasticMatrix, NewNodePosition) {
   # add a new non-connected node

  NodePositions2 <- rbind(NodePositions, as.vector(NewNodePosition))

  ElasticMatrix2 <- matrix(0, nrow = nrow(ElasticMatrix)+1, ncol = ncol(ElasticMatrix)+1)
  ElasticMatrix2[1:nrow(ElasticMatrix), 1:ncol(ElasticMatrix)] <- ElasticMatrix

  return(list(NodePositions = NodePositions2, ElasticMatrix = ElasticMatrix2))
}



f_removeedge <- function(ElasticMatrix, Node1, Node2) {
  # remove edge connecting Node1 and Node 2
  ElasticMatrix[Node1,Node2] <- 0
  ElasticMatrix[Node2,Node1] <- 0

  return(list(ElasticMatrix = ElasticMatrix))
}




f_add_edge <- function(ElasticMatrix, Node1, Node2, lambda) {
  # connects Node1 and Node 2 by an edge with elasticity lambda

  ElasticMatrix[Node1,Node2] <- lambda
  ElasticMatrix[Node2,Node1] <- lambda

  return(list(ElasticMatrix = ElasticMatrix))
}



f_get_star <- function(NodePositions, ElasticMatrix, NodeCenter) {
  # extracts a star from the graph with the center in NodeCenter
  NodeIndices <- which(ElasticMatrix[NodeCenter,]>0)

  return(list(NodePositions = NodePositions[NodeIndices, ],
              ElasticMatrix = ElasticMatrix[NodeIndices,NodeIndices],
              NodeIndices = NodeIndices))

}













# Grammar function wrapper ------------------------------------------------


GraphGrammarOperation <- function(X, NodePositions, ElasticMatrix, AdjustVect, type, Partition) {

  if(type == 'addnode2node'){
    return(
      ElPiGraph.R:::AddNode2Node(X = X, NodePositions = NodePositions, ElasticMatrix = ElasticMatrix, Partition = Partition, AdjustVect = AdjustVect)
    )
  }
  
  if(type == 'addnode2node_1'){
    return(
      ElPiGraph.R:::AddNode2Node(X = X, NodePositions = NodePositions, ElasticMatrix = ElasticMatrix, Partition = Partition,
                                 AdjustVect = AdjustVect, Max_K = 1)
    )
  }
  
  if(type == 'addnode2node_2'){
    return(
      ElPiGraph.R:::AddNode2Node(X = X, NodePositions = NodePositions, ElasticMatrix = ElasticMatrix, Partition = Partition,
                                 AdjustVect = AdjustVect, Max_K = 2)
    )
  }

  if(type == 'removenode'){
    return(
      ElPiGraph.R:::RemoveNode(NodePositions = NodePositions, ElasticMatrix =  ElasticMatrix, AdjustVect = AdjustVect)
    )
  }

  if(type == 'bisectedge'){
    return(
      ElPiGraph.R:::BisectEdge(NodePositions = NodePositions, ElasticMatrix = ElasticMatrix, AdjustVect = AdjustVect)
      )
  }
  
  if(type == 'bisectedge_3'){
    return(
      ElPiGraph.R:::BisectEdge(NodePositions = NodePositions, ElasticMatrix = ElasticMatrix, AdjustVect = AdjustVect, Min_K = 3)
    )
  }
  
  if(type == 'shrinkedge'){
    return(
      ElPiGraph.R:::ShrinkEdge(NodePositions = NodePositions, ElasticMatrix = ElasticMatrix, AdjustVect = AdjustVect)
    )
  }
  
  if(type == 'shrinkedge_3'){
    return(
      ElPiGraph.R:::ShrinkEdge(NodePositions = NodePositions, ElasticMatrix = ElasticMatrix, AdjustVect = AdjustVect, Min_K = 3)
    )
  }

  stop("Undefined grammar operation!")

}













# Grammar functions ------------------------------------------------


#' Adds a node to each graph node
#'
#' This grammar operation adds a node to each graph node. The positions of the node
#' is chosen as a linear extrapolation for a leaf node (in this case the elasticity of
#' a newborn star is chosed as in BisectEdge operation), or as the data point giving
#' the minimum local MSE for a star (without any optimization).
#'
#' @param X
#' @param NodePositions
#' @param ElasticMatrix
#'
#' @return
#' @export
#'
#' @details
#'
#' 
#'
#' @examples
AddNode2Node <- function(X,
                         NodePositions,
                         ElasticMatrix,
                         Partition,
                         AdjustVect,
                         Max_K = Inf) {
  
  NNodes <- nrow(NodePositions)
  NNp1 <- NNodes + 1
  NumberOfGraphs <- NNodes

  Mus = diag(ElasticMatrix)
  L = ElasticMatrix - diag(Mus)
  Connectivities = colSums(L>0)

  # Create prototypes for new NodePositions, ElasticMatrix and inds
  NPProt = matrix(0, nrow = NNp1, ncol = ncol(NodePositions))
  NPProt[1:NNodes, ] = NodePositions
  
  EMProt = matrix(0, nrow = NNp1, ncol = NNp1)
  EMProt[1:NNodes, 1:NNodes] = L
  
  MuProt = rep(0, NNp1)
  MuProt[1:NNodes] = Mus
  
  GenerateMatrices <- function(i) {
    # Compute mean edge elastisity for edges with node i 
    LVect <- L[i,]
    meanLambda = mean(LVect[LVect != 0])
    
    # Add edge to elasticity matrix
    EMProt[NNp1, i] = meanLambda
    EMProt[i, NNp1] = meanLambda
    
    if(Connectivities[i]==1){
      # Add node to terminal node
      StarNodeID <- which(LVect != 0)
      # Calculate new node position
      NewNodePosition = 2 * NodePositions[i, ] - NodePositions[StarNodeID, ];
      # Complete elasticity matrix
      MuProt[NNp1] = Mus[StarNodeID]
    } else {
      # Add node to star
      LeafNodesID <- which(LVect != 0)
      # If number of data points associated with star centre is zero
      if(all(Partition != i)){
        # then select the mean of all leaves as new position
        if(length(LeafNodesID)>1){
          NewNodePosition = colMeans(NodePositions[LeafNodesID, ])
        } else {
          NewNodePosition = NodePositions[LeafNodesID, ]
        }
      } else {
        # otherwise take the mean of points associated with central node.
        PointsID <- which(Partition == i)
        if(length(PointsID)>1){
          NewNodePosition = colMeans(X[PointsID, ])
        } else {
          NewNodePosition = X[PointsID, ]
        }
      }

    }
      
    NPProt[NNp1, ] = NewNodePosition
    diag(EMProt) <- MuProt
    
    AdjustVect <- c(AdjustVect, FALSE)
    
    return(list(NodePositions = NPProt,
                ElasticMatrix = EMProt,
                AdjustVect = AdjustVect))
  }
  
  
  if(!is.infinite(Max_K)){
    Degree <- rowSums(ElasticMatrix>0)
    Degree[Degree>1] <- Degree[Degree>1] - 1
    
    if(sum(Degree <= Max_K)>1){
      Results <- lapply(as.list(which(Degree <= Max_K)), GenerateMatrices)
    } else {
      stop("AddNode2Node impossible with the current parameters!")
    }
    
  } else {
    Results <- lapply(as.list(1:NNodes), GenerateMatrices)
  }
  
  return(
    list(
      NodePositionArray = lapply(Results, "[[", "NodePositions"),
      ElasticMatrices = lapply(Results, "[[", "ElasticMatrix"),
      AdjustVect = lapply(Results, "[[", "AdjustVect")
    )
  )

}



















BisectEdge <- function(NodePositions,
                       ElasticMatrix,
                       AdjustVect,
                       Min_K = 1) {

  # % This grammar operation inserts a node inside the middle of each edge
  # % The elasticity of the edges do not change
  # % The elasticity of the newborn star is chosen as
  # % mean over the neighbour stars if the edge connects two star centers
  # % or
  # % the one of the single neigbour star if this is a dangling edge
  # % or
  # % if one starts from a single edge, the star elasticities should be on
  # % one of two elements in the diagoal of the ElasticMatrix

  DecodedMat <- DecodeElasticMatrix(ElasticMatrix)

  Edges <- DecodedMat$Edges

  if(is.null(dim(Edges))){
    dim(Edges) <- c(1, length(Edges))
  }

  NumberOfGraphs = nrow(Edges)
  NNodes = nrow(NodePositions)

  # NodePositionArray = list()
  # ElasticMatrices = list()

  DoStuff <- function(i) {
    
    NewNodePosition <- colMeans(NodePositions[Edges[i,],])
    AddedNode <- f_add_nonconnected_node(NodePositions,ElasticMatrix,NewNodePosition)
    nn <- nrow(AddedNode$NodePositions)
    
    lambda <- ElasticMatrix[Edges[i,1], Edges[i,2]]
    
    em <- f_removeedge(AddedNode$ElasticMatrix,Edges[i,1],Edges[i,2])
    em <- f_add_edge(em$ElasticMatrix,Edges[i,1],nn,lambda)
    em <- f_add_edge(em$ElasticMatrix,Edges[i,2],nn,lambda)
    
    em <- em$ElasticMatrix
    
    mu1 = ElasticMatrix[Edges[i,1],Edges[i,1]]
    mu2 = ElasticMatrix[Edges[i,2],Edges[i,2]]
    
    if (mu1 > 0 & mu2 > 0){
      em[nn,nn] <- mean(mu1,mu2)
    } else{
      em[nn,nn] <- max(mu1,mu2)
    }
    
    AdjustVect <- c(AdjustVect, FALSE)
    
    return(list(NodePositions = AddedNode$NodePositions, ElasticMatrix = em, AdjustVect = AdjustVect))
  }

  if(Min_K>1){
    Degree <- sapply(as.list(1:NNodes), function(i){sum(Edges == i)})
    EdgDegree <- apply(Edges, 1, function(x) {
      max(Degree[x])
    })
    
    Results <- lapply(as.list(which(EdgDegree>=Min_K)), DoStuff)
  } else {
    Results <- lapply(as.list(1:nrow(Edges)), DoStuff)
  }
  
  return(
    list(
      NodePositionArray = lapply(Results, "[[", "NodePositions"),
      ElasticMatrices = lapply(Results, "[[", "ElasticMatrix"),
      AdjustVect = lapply(Results, "[[", "AdjustVect")
    )
  )
  
}








RemoveNode <- function(NodePositions,
                       ElasticMatrix,
                       AdjustVect) {

  # %
  # % This grammar operation removes a leaf node (connectivity==1)
  # %

  Mus = diag(ElasticMatrix)
  L = ElasticMatrix - diag(Mus)
  Connectivities = colSums(L>0)
  NNodes = nrow(NodePositions)

  NumberOfGraphs = sum(Connectivities==1)
  NodePositionArray = list()
  ElasticMatrices = list()
  AdjustVectList = list()

  k=1

  for(i in 1:length(Connectivities)){
    if(Connectivities[i]==1){
      
      tAdjustVect <- AdjustVect
      tAdjustVect <- tAdjustVect[-i]
      
      RemovedNode <- f_remove_node(NodePositions,ElasticMatrix,i)
      NodePositionArray[[k]] = RemovedNode$NodePositions
      ElasticMatrices[[k]] = RemovedNode$ElasticMatrix
      AdjustVectList[[k]] = tAdjustVect
      
      k=k+1
    }
  }

  return(list(NodePositionArray = NodePositionArray,
              ElasticMatrices = ElasticMatrices,
              AdjustVect = AdjustVectList))

}







ShrinkEdge <- function(NodePositions,
                       ElasticMatrix,
                       AdjustVect,
                       Min_K = 1) {

  # %
  # % This grammar operation removes an edge from the graph
  # % If this is an edge connecting a leaf node then it is equivalent to
  # % RemoveNode. So we remove only internal edges.
  # % If this is an edge connecting two stars then their leaves are merged,
  # % and the star is placed in the middle of the shrinked edge.
  # % The elasticity of the new formed star is the average of two star
  # % elasticities.
  # %

  Mus <- diag(ElasticMatrix)
  L <- ElasticMatrix - diag(Mus)
  Connectivities <- colSums(L>0)
  NNodes <- nrow(NodePositions)

  DecodedMat <- DecodeElasticMatrix(ElasticMatrix)
  Edges <- DecodedMat$Edges

  if(is.null(dim(Edges))){
    dim(Edges) <- c(1, length(Edges))
  }

  NumberOfGraphs <- 0

  for(i in 1:nrow(Edges)){
    if(Connectivities[Edges[i,1]] > 1 & Connectivities[Edges[i,2]] > 1){
      NumberOfGraphs <- NumberOfGraphs+1
    }
  }

  NodePositionArray = list()
  ElasticMatrices  = list()
  AdjustVectList = list()

  k=1
  for(i in 1:nrow(Edges)){
    if((Connectivities[Edges[i,1]]>1 & Connectivities[Edges[i,2]]>1)
       & (Connectivities[Edges[i,1]]>=Min_K | Connectivities[Edges[i,1]]>=Min_K)){
      
      tAdjustVect <- AdjustVect
      em <- f_reattach_edges(ElasticMatrix,Edges[i,1],Edges[i,2])
      temp <- NodePositions[Edges[i,2],]
      RemovedEdge <- f_remove_node(NodePositions, em$ElasticMatrix, Edges[i,2])
      tAdjustVect <- tAdjustVect[-Edges[i,2]]

      np <- RemovedEdge$NodePositions
      np[Edges[i,1], ] = (np[Edges[i,1],] + temp)/2

      NodePositionArray[[k]] = np
      ElasticMatrices[[k]] = RemovedEdge$ElasticMatrix
      AdjustVectList[[k]] = tAdjustVect
      k=k+1
    }
  }

  return(list(NodePositionArray = NodePositionArray,
              ElasticMatrices = ElasticMatrices,
              AdjustVect = AdjustVectList))


}








# Multiple grammar application --------------------------------------------

#' Application of the grammar operation. This in an internal function that should not be used in by the end-user
#'
#' @param X numerical 2D matrix, the n-by-m matrix with the position of n m-dimensional points
#' @param NodePositions numerical 2D matrix, the k-by-m matrix with the position of k m-dimensional points
#' @param ElasticMatrix numerical 2D matrix, the k-by-k elastic matrix
#' @param operationtypes string vector containing the operation to use
#' @param SquaredX rowSums(X^2), if NULL it will be computed
#' @param verbose boolean. Should addition information be displayed
#' @param n.cores integer. How many cores to use. If EnvCl is not NULL, that cliuster setup will be used,
#' otherwise a SOCK cluster willbe used
#' @param EnvCl a cluster structure returned, e.g., by makeCluster.
#' If a cluster structure is used, all the nodes must be able to access all the variable needed by PrimitiveElasticGraphEmbedment
#' @param MaxNumberOfIterations is an integer number indicating the maximum number of iterations for the EM algorithm
#' @param TrimmingRadius is a real value indicating the trimming radius, a parameter required for robust principal graphs
#' (see https://github.com/auranic/Elastic-principal-graphs/wiki/Robust-principal-graphs)
#' @param eps a real number indicating the minimal relative change in the nodenpositions
#' to be considered the graph embedded (convergence criteria)
#' @param Mode integer, the energy mode. It can be 1 (difference is computed using the position of the nodes) and
#' 2 (difference is computed using the changes in elestic energy of the configuraztions)
#' @param FinalEnergy string indicating the final elastic emergy associated with the configuration. Currently it can be "Base" or "Penalized"
#' @param alpha positive numeric, the value of the alpha parameter of the penalized elastic energy
#' @param beta positive numeric, the value of the beta parameter of the penalized elastic energy
#' @param gamma 
#' @param FastSolve boolean, should FastSolve be used when fitting the points to the data?
#' @param AvoidSolitary boolean, should configurations with "solitary nodes", i.e., nodes without associted points be discarded?
#' @param EmbPointProb numeric between 0 and 1. If less than 1 point will be sampled at each iteration. Prob indicate the probability of
#' using each points. This is an *experimental* feature, which may helps speeding up the computation if a large number of points is present.
#' @param AdjustVect 
#' @param AdjustElasticMatrix 
#' @param ... 
#' @param MinParOP integer, the minimum number of operations to use parallel computation
#'
#' @return
#'
#' @examples
ApplyOptimalGraphGrammarOpeation <- function(X,
                                             NodePositions,
                                             ElasticMatrix,
                                             AdjustVect = NULL,
                                             operationtypes,
                                             SquaredX = NULL,
                                             verbose = FALSE,
                                             n.cores = 1,
                                             EnvCl = NULL,
                                             MinParOP = 20,
                                             MaxNumberOfIterations = 100,
                                             eps = .01,
                                             TrimmingRadius = Inf,
                                             Mode = 1,
                                             FinalEnergy = "Base",
                                             alpha = 1,
                                             beta = 1,
                                             gamma = 1,
                                             FastSolve = FALSE,
                                             EmbPointProb = 1,
                                             AvoidSolitary = FALSE,
                                             AdjustElasticMatrix = NULL,
                                             ...) {

  if(is.null(AdjustVect)){
    AdjustVect <- rep(FALSE, nrow(NodePositions))
  }
  
  # % this function applies the most optimal graph grammar operation of operationtype
  # % the embedment of an elastic graph described by ElasticMatrix

  k=1

  if(is.null(SquaredX)){
    SquaredX = rowSums(X^2)
  }
  
  NodePositionArrayAll <- list()
  ElasticMatricesAll <- list()
  AdjustVectAll <- list()

  Partition = ElPiGraph.R::PartitionData(X = X, NodePositions = NodePositions, SquaredX = SquaredX, TrimmingRadius = TrimmingRadius)$Partition
  
  for(i in 1:length(operationtypes)){
    if(verbose){
      tictoc::tic()
      print(paste(i, 'Operation type =', operationtypes[i]))
    }

    NewMatrices <- ElPiGraph.R:::GraphGrammarOperation(X = X, NodePositions = NodePositions,
                                         ElasticMatrix = ElasticMatrix, type = operationtypes[i],
                                         Partition = Partition, AdjustVect = AdjustVect)

    NodePositionArrayAll <- c(NodePositionArrayAll, NewMatrices$NodePositionArray)
    ElasticMatricesAll <- c(ElasticMatricesAll, NewMatrices$ElasticMatrices)
    AdjustVectAll <- c(AdjustVectAll, NewMatrices$AdjustVect)

    if(verbose){
      tictoc::toc()
    }

  }

  # minEnergy = .Machine$double.xmax
  # k = -1

  if(verbose){
    tictoc::tic()
    print("Optimizing graphs")
  }

  Valid <- as.list(1:length(NodePositionArrayAll))
  
  # Check that each point is associated with at least one point. Otherwise we exclude the configuration
  if(AvoidSolitary){
    Valid <- sapply(Valid, function(i){
      Partition <- ElPiGraph.R::PartitionData(X = X,
                                 NodePositions = NodePositionArrayAll[[i]],
                                 SquaredX = SquaredX,
                                 TrimmingRadius = TrimmingRadius)$Partition
      if(all(1:nrow(NodePositionArrayAll[[i]]) %in% Partition)){
        return(i)
      }
      return(0)
    })
    
    if(verbose){
      tictoc::tic()
      print(paste0(sum(Valid > 0), "configurations out of", length(Valid), "used"))
    }
    
    Valid <- Valid[Valid > 0]
  }
  
  CombinedInfo <- lapply(Valid, function(i){
    list(NodePositions = NodePositionArrayAll[[i]], ElasticMatrix = ElasticMatricesAll[[i]], AdjustVect = AdjustVectAll[[i]])
  })
  
  # We are adjusting the elastic matrix
  if(!is.null(AdjustElasticMatrix)){
    CombinedInfo <- lapply(CombinedInfo, AdjustElasticMatrix, ...)
  }
  
  # print(paste("DEBUG:", TrimmingRadius))
  
  DynamicProcess <- length(CombinedInfo) %/% MinParOP + 1
  if(DynamicProcess > n.cores){
    DynamicProcess <- n.cores
  }
  
  if((n.cores > 1) & (DynamicProcess > 1) ){
    
    if(is.null(EnvCl)){
      cl <- parallel::makeCluster(n.cores)
      parallel::clusterExport(cl, varlist = c("X"), envir = environment())
    } else {
      cl <- EnvCl
    }
    
    Embed <- parallel::parLapply(cl[1:DynamicProcess], CombinedInfo, function(input){
      ElPiGraph.R:::PrimitiveElasticGraphEmbedment(X = X,
                                                   NodePositions = input$NodePositions,
                                                   ElasticMatrix = input$ElasticMatrix,
                                                   SquaredX = SquaredX,
                                                   verbose = FALSE,
                                                   MaxNumberOfIterations = MaxNumberOfIterations,
                                                   eps = eps,
                                                   FinalEnergy = FinalEnergy,
                                                   alpha = alpha,
                                                   beta = beta,
                                                   gamma = gamma,
                                                   Mode = Mode,
                                                   TrimmingRadius = TrimmingRadius,
                                                   FastSolve = FastSolve,
                                                   prob = EmbPointProb)
    })
    
    if(is.null(EnvCl)){
      parallel::stopCluster(cl)
    }
    
  } else {
    Embed <- lapply(CombinedInfo, function(input){
      ElPiGraph.R:::PrimitiveElasticGraphEmbedment(X = X,
                                                   NodePositions = input$NodePositions,
                                                   ElasticMatrix = input$ElasticMatrix,
                                                   SquaredX = SquaredX,
                                                   verbose = FALSE,
                                                   MaxNumberOfIterations = MaxNumberOfIterations,
                                                   eps = eps,
                                                   FinalEnergy = FinalEnergy,
                                                   alpha = alpha,
                                                   beta = beta,
                                                   Mode = Mode,
                                                   TrimmingRadius = TrimmingRadius,
                                                   FastSolve = FastSolve,
                                                   prob = EmbPointProb)
    })
  }
  
  if(length(Embed)==0){
    return(NA)
  }
  
  Best <- which.min(sapply(Embed, "[[", "ElasticEnergy"))
  
  minEnergy <- Embed[[Best]]$ElasticEnergy
  NodePositions2 <- Embed[[Best]]$EmbeddedNodePositions
  ElasticMatrix2 <- CombinedInfo[[Best]]$ElasticMatrix
  AdjustVect2 <- CombinedInfo[[Best]]$AdjustVect
  
  if(verbose){
    tictoc::toc()
  }

  return(
    list(
      NodePositions = NodePositions2,
      ElasticMatrix = ElasticMatrix2,
      ElasticEnergy = minEnergy,
      MSE = Embed[[Best]]$MSE,
      EP = Embed[[Best]]$EP,
      RP = Embed[[Best]]$RP,
      AdjustVect = AdjustVect2
    )
  )

}
