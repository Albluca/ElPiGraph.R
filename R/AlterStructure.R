#' Extend leaves with additional nodes
#'
#' @param X numeric matrix, the data matrix
#' @param TargetPG list, the ElPiGraph structure to extend
#' @param LeafIDs integer vector, the id of nodes to extend. If NULL, all the vertices will be extended.
#' @param TrimmingRadius positive numeric, the trimming radius used to control distance 
#' @param ControlPar positive numeric, the paramter used to control the contribution of the different data points
#' @param DoSA bollean, should optimization (via simulated annealing) be performed when Mode = "QuantDists"?
#' @param Mode string, the mode used to extend the graph. "QuantCentroid" and "WeigthedCentroid" are currently implemented
#' @param PlotSelected boolean, should a diagnostic plot be visualized
#'
#' @return The extended ElPiGraph structure
#' 
#' The value of ControlPar has a different interpretation depending on the valus of Mode. In each case, for only the extreme points,
#' i.e., the points associated with the leaf node that do not have a projection on any edge are considered.
#' 
#' If Mode = "QuantCentroid", for each leaf node, the extreme points are ordered by their distance from the node
#' and the centroid of the points farther away than the ControlPar is returned.
#' 
#' If Mode = "WeigthedCentroid", for each leaf node, a weight is computed for each points by raising the distance to the ControlPar power.
#' Hence, larger values of ControlPar result in a larger influence of points farther from the node
#' 
#' If Mode = "QuantDists", for each leaf node, ... will write it later
#'
#'
#' @export
#'
#' @examples
#' 
#' TreeEPG <- computeElasticPrincipalTree(X = tree_data, NumNodes = 50,
#' drawAccuracyComplexity = FALSE, drawEnergy = FALSE)
#' 
#' ExtStruct <- ExtendLeaves(X = tree_data, TargetPG = TreeEPG[[1]], Mode = "QuantCentroid", ControlPar = .5)
#' PlotPG(X = tree_data, TargetPG = ExtStruct)
#' 
#' ExtStruct <- ExtendLeaves(X = tree_data, TargetPG = TreeEPG[[1]], Mode = "QuantCentroid", ControlPar = .9)
#' PlotPG(X = tree_data, TargetPG = ExtStruct)
#' 
#' ExtStruct <- ExtendLeaves(X = tree_data, TargetPG = TreeEPG[[1]], Mode = "WeigthedCentroid", ControlPar = .2)
#' PlotPG(X = tree_data, TargetPG = ExtStruct)
#' 
#' ExtStruct <- ExtendLeaves(X = tree_data, TargetPG = TreeEPG[[1]], Mode = "WeigthedCentroid", ControlPar = .8)
#' PlotPG(X = tree_data, TargetPG = ExtStruct)
#' 
ExtendLeaves <- function(X,
                         TargetPG, Mode = "WeigthedCentroid",
                         ControlPar = .9, 
                         DoSA = FALSE,
                         LeafIDs = NULL,
                         TrimmingRadius = Inf,
                         PlotSelected = TRUE) {
  
  # Generate net
  Net <- ConstructGraph(PrintGraph = TargetPG)
  
  # get leafs
  if(is.null(LeafIDs)){
    LeafIDs <- which(igraph::degree(Net) == 1)
  }
  
  # check LeafIDs
  if(any(igraph::degree(Net, LeafIDs) > 1)){
    stop("Only leaf nodes can be extended")
  }
  
  # and their neigh
  Nei <- igraph::neighborhood(graph = Net, order = 1, nodes = LeafIDs)
  
  # and put stuff together
  NeiVect <- sapply(1:length(Nei), function(i){setdiff(Nei[[i]], LeafIDs[i])})
  NodesMat <- cbind(LeafIDs, NeiVect)
  
  # project data on the nodes
  PD <- PartitionData(X = X, NodePositions = TargetPG$NodePositions, TrimmingRadius = TrimmingRadius)
  
  # Inizialize the new nodes and edges
  NNPos <- NULL
  NEdgs <- NULL
  
  # Keep track of the new nodes IDs
  NodeID <- nrow(TargetPG$NodePositions)
  
  # keep track of the used nodes
  UsedNodes <- NULL
  WeiVal <- NULL
  
  # for each leaf
  for(i in 1:nrow(NodesMat)){
    
    # generate the new node id
    NodeID <- NodeID + 1
    
    if(sum(PD$Partition == NodesMat[i,1]) == 0){
      next()
    }
    
    # get all the data associated with the leaf node
    tData <- X[PD$Partition == NodesMat[i,1], ]
    
    dim(tData) <- c(sum(PD$Partition == NodesMat[i,1]), ncol(X))
    
    # and project them on the edge
    Proj <- project_point_onto_edge(X = X[PD$Partition == NodesMat[i,1], ],
                                    NodePositions = TargetPG$NodePositions,
                                    Edge = NodesMat[i,])
    
    # Select the distances of the associated points
    Dists <- PD$Dists[PD$Partition == NodesMat[i,1]]
    
    # Set distances of points projected on beyond the initial position of the edge to 0
    Dists[Proj$Projection_Value >= 0] <- 0
    
    if(Mode == "QuantCentroid"){
      ThrDist <- quantile(Dists[Dists>0], ControlPar)
      SelPoints <- which(Dists >= ThrDist)
      
      print(paste(length(SelPoints), "points selected to compute the centroid while extending node", NodesMat[i,1]))
      
      if(length(SelPoints)>1){
        NN <- colMeans(tData[SelPoints,])
      } else {
        NN <- tData[SelPoints,]
      }
      
      NNPos <- rbind(NNPos, NN)
      NEdgs <- rbind(NEdgs, c(NodesMat[i,1], NodeID))
      
      UsedNodes <- c(UsedNodes, which(PD$Partition == NodesMat[i,1])[SelPoints])
    }
    
    if(Mode == "WeigthedCentroid"){
      
      Dist2 <- Dists^(2*ControlPar)
      Wei <- Dist2/max(Dist2)
      
      if(length(Wei)>1){
        NN <- apply(tData, 2, function(x){sum(x*Wei)/sum(Wei)})
      } else {
        NN <- tData
      }
      
      NNPos <- rbind(NNPos, NN)
      NEdgs <- rbind(NEdgs, c(NodesMat[i,1], NodeID))
      
      UsedNodes <- c(UsedNodes, which(PD$Partition == NodesMat[i,1]))
      WeiVal <- c(WeiVal, Wei)
    }
    
    if(Mode == "QuantDists"){
      
      if(sum(Dists>0)==0){
        next()
      }
      
      if(sum(Dists>0)>1 & nrow(tData)>1){
        
        tData.Filtered = tData[Dists>0,]
        
        DistFun <- function(NodePosition) {
          quantile(
            ElPiGraph.R::project_point_onto_edge(X = tData.Filtered,
                                                 NodePositions = rbind(
                                                   TargetPG$NodePositions[NodesMat[i,1],],
                                                   NodePosition),
                                                 Edge = c(1,2))$Distance_Squared,
            
            ControlPar)
        }
        
        StartingPoint <- tData.Filtered[which.min(apply(tData.Filtered, 1, DistFun)),]
        
        if(DoSA){
          
          print("Performing simulated annealing. This may take a while")
          
          StartingPoint <- GenSA::GenSA(
            par = StartingPoint , fn = DistFun,
            lower = apply(tData.Filtered, 2, min),
            upper = apply(tData.Filtered, 2, max)
          )$par
        }
        
        
        Projections <- ElPiGraph.R::project_point_onto_edge(X = tData.Filtered,
                                                            NodePositions = rbind(
                                                              TargetPG$NodePositions[NodesMat[i,1],],
                                                              StartingPoint),
                                                            Edge = c(1,2), ExtProj = TRUE)
        
        SelId <- which.max(
          distutils::PartialDistance(Projections$X_Projected,
                                     matrix(TargetPG$NodePositions[NodesMat[i,1],], nrow = 1))
        )
        
        StartingPoint <- Projections$X_Projected[SelId, ]
        
      } else {
        
        StartingPoint <- tData[Dists>0,]
        
      }
      
      NNPos <- rbind(NNPos, StartingPoint)
      NEdgs <- rbind(NEdgs, c(NodesMat[i,1], NodeID))
      
      UsedNodes <- c(UsedNodes, which(PD$Partition == NodesMat[i,1]))
    }
    
  }
  
  # plot(X)
  # points(TargetPG$NodePositions, col="red")
  # points(NNPos, col="blue")
  # 
  TargetPG$NodePositions <- rbind(TargetPG$NodePositions, NNPos)
  TargetPG$Edges$Edges <- rbind(TargetPG$Edges$Edges, NEdgs)
  TargetPG$Edges$Lambdas <- c(TargetPG$Edges$Lambdas, rep(NA, nrow(NEdgs)))
  TargetPG$Edges$Mus <- c(TargetPG$Edges$Lambdas, rep(NA, nrow(NEdgs)))
  
  
  if(PlotSelected){
    
    if(Mode == "QuantCentroid"){
      Cats <- rep("Unused", nrow(X))
      if(!is.null(UsedNodes)){
        Cats[UsedNodes] <- "Used"
      }
      
      p <- PlotPG(X = X, TargetPG = TargetPG, GroupsLab = Cats)
      print(p)
    }
    
    if(Mode == "WeigthedCentroid"){
      Cats <- rep(0, nrow(X))
      if(!is.null(UsedNodes)){
        Cats[UsedNodes] <- WeiVal
      }
      
      p <- PlotPG(X = X[Cats>0, ], TargetPG = TargetPG, GroupsLab = Cats[Cats>0])
      print(p)
      
      p1 <- PlotPG(X = X, TargetPG = TargetPG, GroupsLab = Cats)
      print(p1)
    }
    
    
  }
  
  return(TargetPG)
  
}












#' Filter "small" branches 
#'
#' @param X numeric matrix, the data matrix
#' @param TargetPG list, the ElPiGraph structure to extend
#' @param TrimmingRadius positive numeric, the trimming radius used to control distance 
#' @param ControlPar positive numeric, the paramter used to control the contribution of the different data points
#' @param Mode string, the mode used to extend the graph. "PointNumber", "PointNumber_Extrema", "PointNumber_Leaves",
#' "EdgesNumber", and "EdgesLength" are currently implemented
#' @param PlotSelected boolean, should a diagnostic plot be visualized (currently not implemented)
#'
#' @return a list with 2 values: Nodes (a matrix containing the new nodes positions) and Edges (a matrix describing the new edge structure)
#' 
#' The value of ControlPar has a different interpretation depending on the valus of Mode.
#' 
#' If Mode = "PointNumber", branches with less that ControlPar points projected on the branch
#' (points projected on the extreme points are not considered) are removed
#' 
#' If Mode = "PointNumber_Extrema", branches with less that ControlPar points projected on the branch or the extreme
#' points are removed
#' 
#' If Mode = "PointNumber_Leaves", branches with less that ControlPar points projected on the branch and any leaf points
#' (points projected on non-leaf extreme points are not considered) are removed
#' 
#' If Mode = "EdgesNumber", branches with less that ControlPar edges are removed
#' 
#' If Mode = "EdgesLength", branches with with a length smaller than ControlPar are removed
#'
#' @export
#' 
CollapseBrances <- function(X,
                            TargetPG,
                            Mode = "PointNumber",
                            ControlPar = 5, 
                            TrimmingRadius = Inf,
                            PlotSelected = TRUE) {
  
  # Generate net
  Net <- ConstructGraph(PrintGraph = TargetPG)
  
  # Set a color for the edges
  igraph::E(Net)$status <- "keep"
  
  # Get the leaves
  Leaves <- names(which(igraph::degree(Net, mode = "all")==1))
  
  # get the partition
  PartStruct <- PartitionData(X = X, NodePositions = TargetPG$NodePositions, TrimmingRadius = TrimmingRadius)
  
  # Project points ont the graph
  ProjStruct <- project_point_onto_graph(X = X,
                                         NodePositions = TargetPG$NodePositions,
                                         Edges = TargetPG$Edges$Edges,
                                         Partition = PartStruct$Partition)
  
  # get branches
  Branches <- ElPiGraph.R::GetSubGraph(Net = Net, Structure = 'branches')
  
  # get the number of points on the different branches
  AllBrInfo <- lapply(Branches, function(BrNodes){
    
    # print(BrNodes)
    
    PotentialPoints <- rep(FALSE, length(ProjStruct$EdgeID))
    
    NodeNames <- as.integer(names(BrNodes))
    
    # Get the points on the extrema
    
    StartEdg <- which(apply(ProjStruct$Edges == NodeNames[1], 1, any))
    StartOnNode <- rep(FALSE, length(ProjStruct$EdgeID))
    
    SelPoints <- ProjStruct$EdgeID %in% StartEdg
    StartOnNode[SelPoints] <- ProjStruct$ProjectionValues[SelPoints] > 1 | ProjStruct$ProjectionValues[SelPoints] < 0
    
    EndEdg <- which(apply(ProjStruct$Edges == NodeNames[length(NodeNames)], 1, any))
    EndOnNode <- rep(FALSE, length(ProjStruct$EdgeID))
    
    SelPoints <- ProjStruct$EdgeID %in% EndOnNode
    EndOnNode[SelPoints] <- ProjStruct$ProjectionValues[SelPoints] > 1 | ProjStruct$ProjectionValues[SelPoints] < 0
    
    EdgLen <- 0
    
    # Get the points on the branch (extrema are excluded)
    for(i in 2:length(BrNodes)){
      
      # Get the edge on the segment
      WorkingEdg <- which(apply(ProjStruct$Edges, 1, function(x){all(x %in% NodeNames[(i-1):i])}))
      
      # Get the length of the segment
      EdgLen <- EdgLen + ProjStruct$EdgeLen[WorkingEdg]
      
      # Get the points on the segment
      Points <- ProjStruct$EdgeID == WorkingEdg
      Points[is.na(Points)] <- FALSE
      
      # Is the edge in the right direction?
      if(all(ProjStruct$Edges[WorkingEdg, ] == NodeNames[(i-1):i])){
        Reverse <- FALSE
      } else {
        Reverse <- FALSE
      }
      
      # Counting points at the begining
      if(i == 2 & length(BrNodes) > 2){
        if(Reverse){
          PotentialPoints[Points] <- (ProjStruct$ProjectionValues[Points] < 1) | PotentialPoints[Points]
        } else {
          PotentialPoints[Points] <- (ProjStruct$ProjectionValues[Points] > 0) | PotentialPoints[Points]
        }
        next()
      }
      
      # Counting points at the end
      if(i == length(BrNodes)){
        if(Reverse){
          PotentialPoints[Points] <- (ProjStruct$ProjectionValues[Points] > 0) | PotentialPoints[Points]
        } else {
          PotentialPoints[Points] <- (ProjStruct$ProjectionValues[Points] < 1) | PotentialPoints[Points]
        }
        next()
      }
      
      # all the other cases
      PotentialPoints[Points] <- (ProjStruct$ProjectionValues[Points] > 0 & ProjStruct$ProjectionValues[Points] < 1) | PotentialPoints[Points] 
    }

    PointsOnEdgesLeaf <- PotentialPoints
    
    if(NodeNames[1] %in% Leaves){
      PointsOnEdgesLeaf <- PointsOnEdgesLeaf | StartOnNode
    }
    
    if(NodeNames[length(NodeNames)] %in% Leaves){
      PointsOnEdgesLeaf <- PointsOnEdgesLeaf | EndOnNode
    }
    
    return(
      c(
        PointsOnEdges = sum(PotentialPoints),
        PointsOnEdgeExtBoth = sum(PotentialPoints | StartOnNode | EndOnNode),
        PointsOnEdgesLeaf = sum(PointsOnEdgesLeaf),
        EdgesCount = length(BrNodes) - 1,
        EdgesLen = EdgLen
      )
    )
  })
  
  
  # Now all the information has been pre-computed and it is possible to filter
  
  if(Mode == "PointNumber"){
    ToFilter <- sapply(AllBrInfo, "[[", "PointsOnEdges") < ControlPar
  }
  
  if(Mode == "PointNumber_Extrema"){
    ToFilter <- sapply(AllBrInfo, "[[", "PointsOnEdgeExtBoth") < ControlPar
  }
  
  if(Mode == "PointNumber_Leaves"){
    ToFilter <- sapply(AllBrInfo, "[[", "PointsOnEdgesLeaf") < ControlPar
  }
  
  if(Mode == "EdgesNumber"){
    ToFilter <- sapply(AllBrInfo, "[[", "EdgesCount") < ControlPar
  }
  
  if(Mode == "EdgesLength"){
    ToFilter <- sapply(AllBrInfo, "[[", "EdgesLen") < ControlPar
  }
  
  # Nothing to filter
  if(sum(ToFilter)==0){
    return(
      list(
        Edges = TargetPG$Edges$Edges,
        Nodes = TargetPG$NodePositions
      )
    )
    
    return(list(TargetPG))
  }

  # TargetPG_New <- TargetPG
  # NodesToRemove <- NULL
  
  # Transform Branches in a list of vectors of names
  Branches_Names <- lapply(Branches, names)
  
  # Keep track of all the nodes to remove
  AllNodes_InternalBranches <- NULL
  
  # For all the branches
  for(i in 1:length(ToFilter)){
    
    # If we need to filter this
    if(ToFilter[i] == TRUE){
      
      NodeNames <- Branches_Names[[i]]
      
      # Is it a final branch ? 
      if(any(NodeNames[c(1, length(NodeNames))] %in% Leaves)){
        # It's a terminal branch, we can safely take it out
        
        print(paste("Removing the terminal branch with nodes:", paste(NodeNames, collapse = " ")))
        
        if(length(NodeNames) > 2){
          NodeNames_Ext <- c(
            NodeNames[1],
            rep(NodeNames[-c(1, length(NodeNames))], each = 2),
            NodeNames[length(NodeNames)]
          )
        } else {
          NodeNames_Ext <- NodeNames
        }
        
        # Set edges to be removed
        for(j in 1:length(NodeNames)){
          igraph::E(Net)$status[igraph::get.edge.ids(graph = Net, vp = NodeNames_Ext)] <- "remove"
        }
        
      } else {
        
        # It's a "bridge". We cannot simply remove nodes. Need to introduce a new one by "fusing" two stars
        
        print(paste("Removing the bridge branch with nodes:", paste(NodeNames, collapse = " ")))
        
        # Update the list of nodes to update
        AllNodes_InternalBranches <- union(AllNodes_InternalBranches, NodeNames)
        
      }
      
      # print(i)
      # print(nrow(TargetPG_New$NodePositions))
      # print(dim(TargetPG_New$ElasticMatrix))
      
    }
    
  }
  
  # Create the network that will contain the final filtered network
  Ret_Net <- Net
  
  # Get a net with all the groups of bridges to remove
  tNet <- igraph::induced.subgraph(graph = Net, vids = AllNodes_InternalBranches)
  
  if(igraph::vcount(tNet)>0){
    # Get the different connected components
    CC <- igraph::components(tNet)
    
    # Get the nodes associated with the connected components
    Vertex_Comps <- split(names(CC$membership), CC$membership)
    
    # Get the centroid of the different connected components
    Centroids <- sapply(Vertex_Comps, function(x){
      colMeans(TargetPG$NodePositions[as.integer(x),])
    })
    
    # Prepare a vector that will be used to contract vertices
    CVet <- 1:igraph::vcount(Net)
    
    # For each centroid
    for(i in 1:length(Vertex_Comps)){
      # Add a new vertex
      Ret_Net <- igraph::add.vertices(
        graph = Ret_Net,
        nv = 1,
        attr = list("name" = paste(igraph::vcount(Ret_Net) + 1))
      )
      # Add a new element to the contraction vector
      CVet <- c(CVet, length(CVet)+1)
      #specify the nodes that will collapse on the new node
      CVet[as.integer(Vertex_Comps[[i]])] <- length(CVet)
    }
    
    # collapse the network
    Ret_Net <- igraph::contract(graph = Ret_Net, mapping = CVet)
  }
  
  # delete edges belonging to the terminal branches
  Ret_Net <- igraph::delete.edges(graph = Ret_Net,
                                  edges = igraph::E(Ret_Net)[igraph::E(Ret_Net)$status == "remove"])
  
  # remove loops that may have been introduced because of the collapse
  Ret_Net <- igraph::simplify(Ret_Net, remove.loops = TRUE)
  
  # Remove empty nodes
  Ret_Net <- igraph::induced_subgraph(Ret_Net, igraph::degree(Ret_Net)>0)
  
  # Use the largest index as name of the node
  igraph::V(Ret_Net)$name <- lapply(igraph::V(Ret_Net)$name, function(x){
    max(as.integer(x))
  })
  
  if(igraph::vcount(tNet)>0){
    NodeMat <- rbind(TargetPG$NodePositions, t(Centroids))
  } else {
    NodeMat <- TargetPG$NodePositions
  }
  rownames(NodeMat) <- NULL
  
  NodeMat <- NodeMat[unlist(igraph::V(Ret_Net)$name), ]
  
  return(
    list(
      Edges = igraph::get.edgelist(graph = Ret_Net, names = FALSE),
      Nodes = NodeMat
    )
  )
  
  # if(PlotSelected){
  #   
  #   if(Mode == "QuantCentroid"){
  #     Cats <- rep("Unused", nrow(X))
  #     if(!is.null(UsedNodes)){
  #       Cats[UsedNodes] <- "Used"
  #     }
  #     
  #     p <- PlotPG(X = X, TargetPG = TargetPG, GroupsLab = Cats)
  #     print(p)
  #   }
  #   
  #   if(Mode == "WeigthedCentroid"){
  #     Cats <- rep(0, nrow(X))
  #     if(!is.null(UsedNodes)){
  #       Cats[UsedNodes] <- WeiVal
  #     }
  #     
  #     p <- PlotPG(X = X[Cats>0, ], TargetPG = TargetPG, GroupsLab = Cats[Cats>0])
  #     print(p)
  #     
  #     p1 <- PlotPG(X = X, TargetPG = TargetPG, GroupsLab = Cats)
  #     print(p1)
  #   }
  #   
  #   
  # }
  
}
















#' Title
#'
#' @param TargetPG 
#' @param NodesToRemove 
#'
#' @return
#'
#' @examples
RemoveNodesbyIDs <- function(TargetPG, NodesToRemove) {
  
  RemapNodeID <- cbind(
    1:nrow(TargetPG$NodePositions),
    1:nrow(TargetPG$NodePositions)
  )
  
  TargetPG_New <- TargetPG
  
  # Remove nodes and edges
  TargetPG_New$NodePositions <- TargetPG_New$NodePositions[-NodesToRemove, ]
  TargetPG_New$ElasticMatrix <- TargetPG_New$ElasticMatrix[-NodesToRemove, -NodesToRemove]
  
  # tEdges <- which(TargetPG_New_New$ElasticMatrix > 0, arr.ind = TRUE)
  # tEdges <- tEdges[tEdges[,2] > tEdges[,1],]
  
  # Remap Nodes IDs 
  RemapNodeID[RemapNodeID[,2] %in% NodesToRemove,2] <- 0
  for(j in 1:nrow(RemapNodeID)){
    if(RemapNodeID[j,2] == 0){
      # the node has been removed. Remapping
      RemapNodeID[RemapNodeID[,2] >= j, 2] <- RemapNodeID[RemapNodeID[,2] >= j, 2] - 1
    }
  }
  
  tEdges <- TargetPG_New$Edges$Edges
  for(j in 1:nrow(RemapNodeID)){
    tEdges[TargetPG_New$Edges$Edges == RemapNodeID[j,1]] <- RemapNodeID[j,2]
  }
  EdgesToRemove <- which(rowSums(tEdges == 0) > 0)
  tEdges <- tEdges[-EdgesToRemove, ]
  
  TargetPG_New$Edges$Edges <- tEdges
  TargetPG_New$Edges$Lambdas <- TargetPG_New$Edges$Lambdas[-EdgesToRemove]
  TargetPG_New$Edges$Mus <- TargetPG_New$Edges$Mus[-NodesToRemove]
  
  return(TargetPG_New)
}

















#' Move branching nodes to areas with higher point density
#'
#' @param X numeric matrix, the data matrix
#' @param TargetPG list, the ElPiGraph structure to extend
#' @param TrimmingRadius positive numeric, the trimming radius used to control distance 
#' @param SelectionMode string, the mode to use to shift the branching points. The "NodePoints" and "NodeDensity" modes are currently supported
#' @param DensityRadius positive numeric, the radius to be used when computing point density if SelectionMode = "NodeDensity"
#' @param MaxShift positive integer, the maxium distance (as number of edges) to consider when exploring the branching point neighborhood
#' @param Compensate booelan, should new points be included to compensate for olter one being removed (currently not implemented)
#' @param BrIds integer vector, the id of the branching points to consider. Id not associted with node possessing degree > 2 will be ignored
#'
#' @return a list with two components: NodePositions (Containing the new nodes positions) and Edges (containing the new edges)
#'
#' The function explore the neighborhood of branching point for nodes with higher point density. It such point is found, to graph will be
#' modified so that the new found node will be the new branching point of the neighborhood. 
#'
#' @examples
#' @export
ShiftBranching <- function(X,
                           TargetPG,
                           SelectionMode = "NodePoints",
                           DensityRadius = NA,
                           MaxShift = 3,
                           Compensate = FALSE,
                           BrIds = NULL,
                           TrimmingRadius = Inf) {
  
  Net <- ConstructGraph(PrintGraph = TargetPG)
  BrPoints <- which(igraph::degree(Net)>2)
  
  if(is.null(BrIds)){
    BrIds <- BrPoints
  } else {
    BrIds <- intersect(BrIds, BrIds)
  }
  
  PD <- ElPiGraph.R::PartitionData(X = X, NodePositions = TargetPG$NodePositions,
                                   TrimmingRadius = TrimmingRadius)
  
  
  for (br in BrIds) {
    
    Neis <- igraph::neighborhood(graph = Net, order = MaxShift, nodes = br)[[1]]
    # Neis <- setdiff(as.integer(Neis), br)
    
    if(SelectionMode == "NodePoints"){
      Neival <- sapply(Neis, function(x){
        return(sum(PD$Partition==x))
      })
    }
    
    if(SelectionMode == "NodeDensity"){
      Dists <- distutils::PartialDistance(Ar = X, Br = TargetPG$NodePositions[Neis,])
      
      if(is.na(DensityRadius)){
        stop("DensityRadius need to be specified when SelectionMode = 'NodeDensity'")
      } else {
        Neival <- colSums(Dists < DensityRadius)
      }
    }
    
    names(Neival) <- Neis
    
    NeiDist <- igraph::distances(graph = Net, v = br, to = Neis)
    Neival <- Neival[order(NeiDist)]
    
    NewBR <- as.integer(Neis[min(which(Neival == max(Neival)))])
    
    EdgToCompensate <- NULL
    
    if(NewBR != br){
      
      print(paste("Moving the branching point at node", br))
      
      ToReconnect <- as.integer(igraph::adjacent_vertices(Net, br)[[1]])
      
      # delete the edges forming the old branching point
      Net <- igraph::delete.edges(graph = Net, edges = igraph::incident_edges(Net, br)[[1]])
      
      # get paths from the new branching point to the old nodes
      suppressWarnings(
        AllPath <- igraph::get.shortest.paths(graph = Net, from = NewBR, to = ToReconnect)
      )
      
      # delete these extra nodes
      for(i in 1:length(AllPath$vpath)){
        if(length(AllPath$vpath[[i]])>0){
          Net <- Net - igraph::path(AllPath$vpath[[i]])
        }
      }
      
      # reconnect the old nodes to the new branching points, excep for any node found in the previuos operation
      ToReconnect <- setdiff(ToReconnect, unlist(AllPath$vpath))
      Net <- igraph::add.edges(graph = Net, edges = as.vector(rbind(NewBR, ToReconnect)))
      
      EdgToCompensate <- rbind(EdgToCompensate, cbind(NewBR, ToReconnect))
      
    }

  }
  
  if(Compensate){
    warnings("Node compensation is not implemented yet")
  }
  
  NewNodePositions = TargetPG$NodePositions[igraph::degree(Net)>0, ]
  
  Net <- igraph::delete.vertices(graph = Net, v = which(igraph::degree(Net)==0))
  
  EdgSeq <- 1:igraph::vcount(Net) 
  names(EdgSeq) <- igraph::V(Net)$name
  
  NewEdges = matrix(EdgSeq[igraph::get.edgelist(Net)], ncol = 2)
  
  return(
    list(
      NodePositions = NewNodePositions,
      Edges = NewEdges
    )
  )
  
}





















#' Filter cliques
#'
#' @param TargetPG 
#' @param MaxClZize 
#' @param DistThr 
#'
#' @return
#' @export
#'
#' @examples
CollapseCliques <- function(TargetPG, MaxClZize = NULL, DistThr = NULL, Compensate = 3) {
  
  Net <- ConstructGraph(TargetPG)
  
  Nodes <- TargetPG$NodePositions
  
  Cliques <- igraph::cliques(Net, min = 3, max = MaxClZize)
  
  ClSize <- sapply(Cliques, length)
  
  print(paste(length(ClSize), "cliques detected"))
  
  Tries <- 0
  
  while (TRUE) {
    
    if(Tries > 100 | length(ClSize) == 0){
      return(list(
        Nodes = TargetPG$NodePositions,
        Edges = TargetPG$Edges$Edges
      ))
    }
    
    Tries <- Tries + 1
    
    ClToCollapse <- sample(x = which(ClSize == max(ClSize)), size = 1)
    NodesToCollapse <- as.integer(Cliques[[ClToCollapse]])
    
    NewNode <- colMeans(Nodes[NodesToCollapse, ])
    
    if(!is.null(DistThr)){
      if(mean(distutils::PartialDistance(matrix(NewNode, nrow = 1), Nodes[NodesToCollapse, ])) < DistThr){
        break()
      }
    } else {
      break()
    }
    
  }
  
  Net <- igraph::add.vertices(Net, 1, attr = list(name = paste(igraph::vcount(Net)+1)))
  
  ContractNet <- 1:igraph::vcount(Net)
  ContractNet[NodesToCollapse] <- igraph::vcount(Net)
  
  ContrNet <- igraph::contract.vertices(Net, ContractNet)
  igraph::V(ContrNet)$name <- sapply(igraph::V(ContrNet)$name, function(x){
    if(length(x)>0){
      max(as.numeric(x))
    } else {
      0
    }
  })
  ContrNet <- igraph::delete.vertices(ContrNet, NodesToCollapse)
  ContrNet <- igraph::simplify(ContrNet, remove.loops = TRUE, remove.multiple = TRUE)
  # igraph::V(ContrNet)$name <- paste(1:igraph::vcount(ContrNet))
  
  UpdateNodes <- rbind(Nodes, NewNode)[as.integer(igraph::V(ContrNet)$name),]
  rownames(UpdateNodes) <- NULL
  
  if(Compensate <= max(ClSize)){
    Neis <- unlist((igraph::adjacent_vertices(graph = ContrNet, v = paste(igraph::vcount(Net)))[[1]])$name)
      
    NNodes <- t((t(Nodes[Neis, ]) + NewNode)/2)
    
    ContrNet <- igraph::add.vertices(ContrNet, length(Neis), attr = list(name = paste0("Ext_", Neis)))
    ContrNet <- igraph::delete_edges(ContrNet, igraph::incident_edges(graph = ContrNet, v = paste(igraph::vcount(Net)))[[1]])
    ContrNet <- igraph::add.edges(graph = ContrNet, edges = rbind(paste(igraph::vcount(Net)), paste0("Ext_", Neis)))
    ContrNet <- igraph::add.edges(graph = ContrNet, edges = rbind(paste(Neis), paste0("Ext_", Neis)))

    UpdateNodes <- rbind(UpdateNodes, NNodes)
    
  }
  
  return(list(
    Nodes = UpdateNodes,
    Edges = igraph::get.edgelist(ContrNet, names = FALSE)
  ))
  
}


















#' 
#' 
#' #' Title
#' #'
#' #' @param variables
#' #'
#' #' @return
#' #' @export
#' #'
#' #' @examples
#' RewireBranches <- function(X,
#'                        TargetPG,
#'                        MaxDist = 3,
#'                        Lambda,
#'                        Mu,
#'                        MaxNumberOfIterations = 10,
#'                        eps = 0.01,
#'                        FinalEnergy = "Base",
#'                        alpha = 0,
#'                        beta = 0,
#'                        Mode = 1,
#'                        TrimmingRadius = Inf,
#'                        FastSolve = FALSE,
#'                        prob = 1) {
#' 
#'   TargetPG1 <- TargetPG
#' 
#'   NodeDist <- distutils::PartialDistance(TargetPG$NodePositions, TargetPG$NodePositions)
#' 
#'   Net <- ConstructGraph(PrintGraph = TargetPG1)
#'   BrPoint <- which(igraph::degree(Net)>2)
#' 
#'   for(i in 1:length(BrPoint)){
#' 
#'     Net <- ConstructGraph(PrintGraph = TargetPG1)
#' 
#'     NeiBr <- as.integer(names(igraph::neighborhood(graph = Net, order = 1, nodes = BrPoint[i])[[1]]))
#'     NeiBr <- setdiff(NeiBr, BrPoint[i])
#' 
#'     for(j in 1:length(NeiBr)){
#'       TargetPG1$NodePositions <- rbind(
#'         TargetPG1$NodePositions,
#'         colMeans(
#'           rbind(
#'             TargetPG$NodePositions[BrPoint[i], ],
#'             TargetPG$NodePositions[NeiBr[j], ]
#'           )
#'         )
#'       )
#'       OldEdg <- TargetPG1$Edges$Edges[,1] %in% c(BrPoint[i], NeiBr[j]) &
#'         TargetPG1$Edges$Edges[,2] %in% c(BrPoint[i], NeiBr[j])
#'       TargetPG1$Edges$Edges <- TargetPG1$Edges$Edges[!OldEdg,]
#'       TargetPG1$Edges$Edges <- rbind(TargetPG1$Edges$Edges,
#'                                      rbind(
#'                                        c(BrPoint[i], nrow(TargetPG1$NodePositions)),
#'                                        c(NeiBr[j], nrow(TargetPG1$NodePositions))
#'                                      )
#'       )
#' 
#'     }
#' 
#'     Net <- ConstructGraph(PrintGraph = TargetPG1)
#'     NeiBr <- as.integer(names(igraph::neighborhood(graph = Net, order = 1, nodes = BrPoint[i])[[1]]))
#'     NeiBr <- setdiff(NeiBr, BrPoint[i])
#' 
#'     StarEdes <- igraph::get.edge.ids(graph = Net, vp = rbind(rep(BrPoint[i], length(NeiBr)), NeiBr), directed = FALSE)
#' 
#'     tNet <- igraph::delete.edges(graph = Net, edges = StarEdes)
#'     Neigh <- igraph::neighborhood(graph = tNet, order = igraph::vcount(tNet), nodes = NeiBr)
#'     NeighDist <- lapply(Neigh, function(NeiVect){
#'       sapply(igraph::shortest_paths(graph = Net, from = BrPoint[i], to = as.vector(NeiVect))$vpath, length)
#'     })
#' 
#'     Mats <- list()
#' 
#'     for(j in 1:length(Neigh)){
#' 
#'       tNet <- igraph::delete.edges(graph = Net, igraph::E(Net)[igraph::`%--%`(BrPoint[i], NeiBr[j])])
#' 
#'       VertexToTest <- Neigh[-j]
#'       VertexToTest.Dist <- NeighDist[-j]
#' 
#'       VertexToTest <- lapply(1:length(VertexToTest), function(i){
#'         (VertexToTest[[i]])[VertexToTest.Dist[[i]] <= MaxDist]
#'       })
#'       VertexToTest <- unlist(VertexToTest)
#' 
#'       for(k in 1:length(VertexToTest)){
#'         TestNet <- igraph::add.edges(graph = tNet, edges = c(NeiBr[j], VertexToTest[k]))
#'         Mats[[length(Mats)+1]] <- apply(igraph::get.edgelist(TestNet), 2, as.numeric)
#'       }
#' 
#'     }
#' 
#'     SquaredX <- rowSums(X^2)
#' 
#'     Embed <- lapply(Mats, function(mat){
#'       ElPiGraph.R:::PrimitiveElasticGraphEmbedment(X = X,
#'                                                    NodePositions = TargetPG1$NodePositions,
#'                                                    ElasticMatrix = ElPiGraph.R::Encode2ElasticMatrix(mat, Lambda, Mu),
#'                                                    SquaredX = SquaredX,
#'                                                    verbose = FALSE,
#'                                                    MaxNumberOfIterations = MaxNumberOfIterations,
#'                                                    eps = eps,
#'                                                    FinalEnergy = FinalEnergy,
#'                                                    alpha = alpha,
#'                                                    beta = beta,
#'                                                    Mode = Mode,
#'                                                    TrimmingRadius = TrimmingRadius,
#'                                                    FastSolve = FastSolve,
#'                                                    prob = prob)
#'     })
#' 
#' 
#'     # SumDists <- sapply(Mats, function(EdgMat){
#'     #   ProjStruct <- ElPiGraph.R::project_point_onto_graph(X, NodePositions = TargetPG$NodePositions, Edges = EdgMat)
#'     #   OnEdes <- ProjStruct$ProjectionValues > 0 & ProjStruct$ProjectionValues < 1
#'     #   DistFromEdge <- rowSums((ProjStruct$X_projected - X)^2)
#'     #   c(sum(DistFromEdge[OnEdes]), sum(ProjStruct$EdgeLen))
#'     # })
#' 
#'     # order(colSums(SumDists))
#'     # which.min(SumDists[2,])
#' 
#' 
#'     # TargetPG2 <- TargetPG1
#' 
#'     TargetPG1$Edges$Edges <- Mats[[which.min(sapply(Embed, "[[", "ElasticEnergy"))]]
#' 
#'     PlotPG(X, TargetPG1, DimToPlot = 1:3, NodeLabels = 1:nrow(TargetPG1$NodePositions), LabMult = 3)
#' 
#'     which(igraph::degree(ConstructGraph(TargetPG1))>2)
#' 
#'   }
#' 
#'   #
#'   #
#'   #
#'   # MaxByEdg <- aggregate(DistFromEdge, by=list(ProjStruct$EdgeID), max)
#'   # ToMove <- MaxByEdg[which.max(MaxByEdg[,2]),1]
#'   #
#'   # Ends <- TargetPG$Edges$Edges[ToMove,]
#'   #
#'   #
#'   # Net <-
#'   # igraph::neighborhood(graph = Net, order = igraph::vcount(Net), nodes = Ends)
#' 
#'   return(TargetPG1)
#' 
#' }
#' 
#' 
#' 
#' 
