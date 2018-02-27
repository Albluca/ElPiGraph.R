

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



f_get_star <- function(NodePositions,ElasticMatrix,NodeCenter) {
  # extracts a star from the graph with the center in NodeCenter
  NodeIndices <- which(ElasticMatrix[NodeCenter,]>0)

  return(list(NodePositions = NodePositions[NodeIndices, ],
              ElasticMatrix = ElasticMatrix[NodeIndices,NodeIndices],
              NodeIndices = NodeIndices))

}



















# Grammar function wrapper ------------------------------------------------


GraphGrammarOperation <- function(X, NodePositions, ElasticMatrix, type, Partition) {

  if(type == 'addnode2node'){
    return(
      AddNode2Node(X = X, NodePositions = NodePositions, ElasticMatrix = ElasticMatrix, Partition = Partition)
    )
  }

  if(type == 'removenode'){
    return(
      RemoveNode(NodePositions = NodePositions, ElasticMatrix =  ElasticMatrix)
    )
  }

  if(type == 'bisectedge'){
    return(
      BisectEdge(NodePositions = NodePositions, ElasticMatrix = ElasticMatrix)
      )
  }

  if(type == 'shrinkedge'){
    return(
      ShrinkEdge(NodePositions = NodePositions, ElasticMatrix = ElasticMatrix)
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
                         Partition) {
  
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
    
    return(list(NodePositions = NPProt, ElasticMatrix = EMProt))
  }
  
  Results <- lapply(as.list(1:NNodes), GenerateMatrices)
  
  return(list(NodePositionArray = lapply(Results, "[[", "NodePositions"),
              ElasticMatrices = lapply(Results, "[[", "ElasticMatrix")))

}

















# 
# 
# AddNode2Node_Old <- function(X, NodePositions, ElasticMatrix, Partition) {
#   
#   NNodes <- nrow(NodePositions)
#   NumberOfGraphs <- NNodes
#   
#   Mus = diag(ElasticMatrix)
#   L = ElasticMatrix - diag(Mus)
#   Connectivities = colSums(L>0)
#   
#   InitEmbm <- PrimitiveElasticGraphEmbedment(X, NodePositions, SquaredX = SquaredX, ElasticMatrix,
#                                              MaxNumberOfIterations = 0, TrimmingRadius = TrimmingRadius, eps = 1,
#                                              FastSolve = FastSolve)
#   
#   
#   DoStuff_1 <- function(i) {
#     
#     meanLambda = mean(L[i, L[i, ]>0])
#     
#     ineighbour = which(L[i,]>0)
#     NewNodePosition = 2*NodePositions[i,] - NodePositions[ineighbour,]
#     NewNode <- f_add_nonconnected_node(NodePositions,ElasticMatrix,NewNodePosition)
#     
#     NPos <- NewNode$NodePositions
#     EMat <- NewNode$ElasticMatrix
#     rm(NewNode)
#     
#     nn <- nrow(NPos)
#     EMat <- f_add_edge(ElasticMatrix = EMat, Node1 = i, Node2 = nn, lambda = ElasticMatrix[i,ineighbour])$ElasticMatrix
#     
#     EMat[i,i] = ElasticMatrix[ineighbour,ineighbour]
#     
#     return(list(NodePosition = NPos, ElasticMatrix = EMat))
#     
#   }
#   
#   
#   DoStuff_N1 <- function(i) {
#     
#     meanLambda = mean(L[i, L[i, ]>0])
#     
#     StarStruct <- f_get_star(NodePositions,ElasticMatrix,i)
#     
#     nplocal <- StarStruct$NodePositions
#     if(is.null(dim(nplocal))){
#       dim(nplocal) <- c(1, length(nplocal))
#     }
#     
#     emlocal <- StarStruct$ElasticMatrix
#     inds <- StarStruct$NodeIndices
#     
#     indlocal <- which(InitEmbm$partition==i)
#     xlocal = X[indlocal, ]
#     
#     if(is.null(dim(xlocal))){
#       dim(xlocal) <- c(1, length(xlocal))
#     }
#     
#     if(length(indlocal)==0){
#       # empty star
#       NodeNewPosition = colMeans(nplocal)
#     } else {
#       minMSE = .Machine$double.xmax
#       m = -1
#       # mean point of the central cluster - seems to work the best
#       NodeNewPosition = colMeans(xlocal)
#     }
#     
#     AddedNode <- f_add_nonconnected_node(NodePositions,
#                                          ElasticMatrix,
#                                          NodeNewPosition)
#     
#     NPos <- AddedNode$NodePositions
#     EMat <- AddedNode$ElasticMatrix
#     
#     nn = nrow(NPos)
#     
#     EMat = f_add_edge(EMat, i, nn, meanLambda)$ElasticMatrix
#     
#     return(list(NodePosition = NPos, ElasticMatrix = EMat))
#     
#   }
#   
#   Results <- as.list(NA, NNodes)
#   
#   Results[Connectivities == 1] <- lapply(as.list(1:NNodes)[Connectivities == 1], DoStuff_1)
#   Results[Connectivities != 1] <- lapply(as.list(1:NNodes)[Connectivities != 1], DoStuff_N1)
#   
#   return(list(NodePositionArray = lapply(Results, "[[", "NodePosition"),
#               ElasticMatrices = lapply(Results, "[[", "ElasticMatrix")))
#   
# }
# 
























BisectEdge <- function(NodePositions, ElasticMatrix) {

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
    
    return(list(NodePosition = AddedNode$NodePositions, ElasticMatrix = em))
  }

  Results <- lapply(as.list(1:nrow(Edges)), DoStuff)

  return(list(NodePositionArray = lapply(Results, "[[", "NodePosition"),
              ElasticMatrices = lapply(Results, "[[", "ElasticMatrix")))


}








RemoveNode <- function(NodePositions,ElasticMatrix) {

  # %
  # % This grammar operation removes a leaf node (connectivity==1)
  # %

  Mus = diag(ElasticMatrix)
  L = ElasticMatrix - diag(Mus)
  Connectivities = colSums(L>0)
  NNodes = nrow(NodePositions)

  NumberOfGraphs = sum(Connectivities==1)
  NodePositionArray = list()
  ElasticMatrices  = list()

  k=1

  for(i in 1:length(Connectivities)){
    if(Connectivities[i]==1){
      RemovedNode <- f_remove_node(NodePositions,ElasticMatrix,i)
      NodePositionArray[[k]] = RemovedNode$NodePositions
      ElasticMatrices[[k]] = RemovedNode$ElasticMatrix
      k=k+1
    }
  }

  return(list(NodePositionArray = NodePositionArray,
              ElasticMatrices = ElasticMatrices))

}







ShrinkEdge <- function(NodePositions,ElasticMatrix) {

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

  k=1
  for(i in 1:nrow(Edges)){
    if(Connectivities[Edges[i,1]]>1 & Connectivities[Edges[i,2]]>1){
      em <- f_reattach_edges(ElasticMatrix,Edges[i,1],Edges[i,2])
      temp <- NodePositions[Edges[i,2],]
      RemovedEdge <- f_remove_node(NodePositions,em$ElasticMatrix,Edges[i,2])

      np <- RemovedEdge$NodePositions
      np[Edges[i,1], ] = (np[Edges[i,1],] + temp)/2

      NodePositionArray[[k]] = np
      ElasticMatrices[[k]] = RemovedEdge$ElasticMatrix
      k=k+1
    }
  }

  return(list(NodePositionArray = NodePositionArray,
              ElasticMatrices = ElasticMatrices))


}








# Multiple grammar application --------------------------------------------

ApplyOptimalGraphGrammarOpeation <- function(X,
                                             NodePositions,
                                             ElasticMatrix,
                                             operationtypes,
                                             SquaredX = NULL,
                                             verbose = FALSE,
                                             n.cores = 1,
                                             EnvCl = NULL,
                                             MaxNumberOfIterations = 100,
                                             eps = .01,
                                             TrimmingRadius = Inf,
                                             Mode = 1,
                                             MinimizingEnergy = "Base",
                                             FinalEnergy = "Base",
                                             alpha = 1,
                                             beta = 1,
                                             FastSolve = FALSE,
                                             AvoidSolitary = FALSE) {

  # % this function applies the most optimal graph grammar operation of operationtype
  # % the embedment of an elastic graph described by ElasticMatrix

  k=1

  if(is.null(SquaredX)){
    SquaredX = rowSums(SquaredX)
  }
  
  NodePositionArrayAll <- list()
  ElasticMatricesAll <- list()

  Partition = PartitionData(X = X, NodePositions = NodePositions, SquaredX = SquaredX, TrimmingRadius = TrimmingRadius)$Partition
  
  for(i in 1:length(operationtypes)){
    if(verbose){
      tictoc::tic()
      print(paste(i, 'Operation type =', operationtypes[i]))
    }

    NewMatrices <- GraphGrammarOperation(X = X, NodePositions = NodePositions,
                                         ElasticMatrix = ElasticMatrix, type = operationtypes[i],
                                         Partition = Partition)

    NodePositionArrayAll <- c(NodePositionArrayAll, NewMatrices$NodePositionArray)
    ElasticMatricesAll <- c(ElasticMatricesAll, NewMatrices$ElasticMatrices)

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
  
  if(AvoidSolitary){
    Valid <- lapply(Valid, function(i){
      Partition <- PartitionData(X = X,
                                 NodePositions = NodePositionArrayAll[[i]],
                                 SquaredX = SquaredX,
                                 TrimmingRadius = TrimmingRadius)$Partition
      if(all(1:nrow(NodePositionArrayAll[[i]]) %in% Partition)){
        return(i)
      }
      return(0)
    })
    
    Valid <- Valid[Valid > 0]
  }
  
  CombinedInfo <- lapply(Valid, function(i){
    list(NodePositions = NodePositionArrayAll[[i]], ElasticMatrix = ElasticMatricesAll[[i]])
  })
  
  # print(paste("DEBUG:", TrimmingRadius))
  
  if(n.cores > 1){
    
    if(is.null(EnvCl)){
      cl <- parallel::makeCluster(n.cores)
      parallel::clusterExport(cl, varlist = c("X"), envir = environment())
    } else {
      cl <- EnvCl
    }
    
    Embed <- parallel::parLapply(cl, CombinedInfo, function(input){
      PrimitiveElasticGraphEmbedment(X, input$NodePositions, input$ElasticMatrix, SquaredX = SquaredX, verbose = FALSE,
                                     MaxNumberOfIterations = MaxNumberOfIterations, eps = eps,
                                     MinimizingEnergy = MinimizingEnergy, FinalEnergy = FinalEnergy,
                                     alpha = alpha, beta = beta, Mode = Mode,
                                     TrimmingRadius = TrimmingRadius, FastSolve = FastSolve)
    })
    
    if(is.null(EnvCl)){
      parallel::stopCluster(cl)
    }
    
  } else {
    Embed <- lapply(CombinedInfo, function(input){
      PrimitiveElasticGraphEmbedment(X, input$NodePositions, input$ElasticMatrix, SquaredX = SquaredX, verbose = FALSE,
                                     MaxNumberOfIterations = MaxNumberOfIterations, eps = eps,
                                     MinimizingEnergy = MinimizingEnergy, FinalEnergy = FinalEnergy,
                                     alpha = alpha, beta = beta, Mode = Mode,
                                     TrimmingRadius = TrimmingRadius, FastSolve = FastSolve)
    })
  }
  
  if(length(Embed)==0){
    return(NA)
  }
  
  Best <- which.min(sapply(Embed, "[[", "ElasticEnergy"))
  
  minEnergy <- Embed[[Best]]$ElasticEnergy
  NodePositions2 <- Embed[[Best]]$EmbeddedNodePositions
  ElasticMatrix2 <- ElasticMatricesAll[[Best]]
  
  if(verbose){
    tictoc::toc()
  }

  return(list(NodePositions = NodePositions2, ElasticMatrix = ElasticMatrix2, ElasticEnergy = minEnergy))

}




