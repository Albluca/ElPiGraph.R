# Construct igraph objects -------------------------------------------------------------

#' Generate an igraph object from a ElPiGraph structure
#'
#' @param PrintGraph A principal graph object
#'
#' @return An igraph network
#' @export
#'
#' @examples
ConstructGraph <- function(PrintGraph) {

  # Generate An Igraph net

  Net <- igraph::graph.empty(n = max(PrintGraph$Edges$Edges), directed = FALSE)
  igraph::V(Net)$name <- paste(1:max(PrintGraph$Edges$Edges))

  Net <- igraph::add.edges(graph = Net, as.character(t(PrintGraph$Edges$Edges)))

  return(Net)

}





# Extract a subpath from the graph ----------------------------------------


#' Extract a subgraph with a given topology from a graph
#'
#' @param Net an igraph network object
#' @param Structure a string specifying the structure to return. The following options are
#' available:
#' \itemize{
#'  \item 'circle', all the circles of a given length (specified by Nodes) present in the data.
#'  If Nodes is unspecified the algorithm will look for the largest circle avaialble.
#'  \item 'branches', all the linear path connecting the branching points
#'  \item 'branches&bpoints', all the linear path connecting the branching points and all of
#'  the branching points
#'  \item 'branching', all the subtree associted with a branching point (i.e., a tree encompassing
#' the branching points and the closests branching points and end points)
#' \item 'end2end', all linear paths connecting end points (or leaf)
#' }
#' @param Circular a boolean indicating whether the circle should contain the initial points at the
#' beginning and at the end
#' @param Nodes the number of nodes (for cycle detection)
#' @param KeepEnds boolean, should the end points (overlapping between structures) be included when
#' Structure = 'branches' or 'branching'
#'
#' @description
#' 
#' Note that all subgraph are returned only once. So, for example, if A and B are two end leaves of a tree
#' and 'end2end' is being used, only the path for A to B or the path from Bt o A will be returned.
#'
#' @return a list of nodes defining the structures under consideration
#' @export
#'
#'
#'
#' @examples
GetSubGraph <- function(Net, Structure, Nodes = NULL, Circular = TRUE, KeepEnds = TRUE) {

  if(Structure == 'auto'){

    print('Structure autodetection is not implemented yet')
    return(NULL)

  }

  if(Structure == 'circle'){
    
    if(is.null(Nodes)){
      print("Looking for the largest cycle")
      
      for(i in rev(3:igraph::vcount(Net))){
        RefNet <- igraph::graph.ring(n = i, directed = FALSE, circular = TRUE)
        if(igraph::graph.subisomorphic.lad(target = Net, pattern = RefNet)$iso){
          print(paste("A cycle of lenght", i, "has been found"))
          break
        }
      }
    } else {
      i <- Nodes
    }
    
    RefNet <- igraph::graph.ring(n = i, directed = FALSE, circular = TRUE)

    SubIsoProjList <- igraph::graph.get.subisomorphisms.vf2(Net, RefNet)
    
    SubIsoProjList <- SubIsoProjList[!duplicated(
      data.frame(t(sapply(SubIsoProjList, function(x){sort(x)})))
      )]

    names(SubIsoProjList) <- paste("Circle", 1:length(SubIsoProjList), sep = "_")
    
    if(Circular){
      return(lapply(SubIsoProjList, function(x) {c(x, x[1])}))
    } else {
      return(SubIsoProjList)
    }

  }
  
  
  if(Structure == 'branches'){
    
    if(any(igraph::degree(Net)>2) & any(igraph::degree(Net)==1)){
      
      # Obtain the branching/end point
      BrPoints <- which(igraph::degree(Net)>2)
      EndPoints <- which(igraph::degree(Net)==1)
      
      AllPaths <- list()
      
      # Keep track of the interesting nodes
      SelEp <- union(BrPoints, EndPoints)
      
      suppressWarnings(
        for(i in 1:(length(SelEp)-1)){
          AllPaths <- append(
            AllPaths,
            igraph::get.shortest.paths(graph = Net,
                                       from = SelEp[i],
                                       to = SelEp[(i+1):length(SelEp)])$vpath
            )
        }
      )
      
      Valid <- sapply(AllPaths, function(x){
        sum(igraph::degree(graph = Net, v = x) != 2)
      }) == 2
      
      AllPaths <- lapply(AllPaths[Valid], function(x){
        as.integer(x)
      })
      
      if(!KeepEnds){
        AllPaths <- lapply(AllPaths, function(x){
          setdiff(x, BrPoints)
        })
      }
      
      names(AllPaths) <- paste("Branch", 1:length(AllPaths), sep = "_")
      
      CapturedNodes <- unlist(AllPaths, use.names = FALSE)
      
      StillToCapture <- setdiff(1:igraph::vcount(Net), CapturedNodes)
      
      # plot(induced_subgraph(Net, neighborhood(Net, paste(StillToCapture), 1)[[1]]))
      # plot(induced_subgraph(Net, paste(StillToCapture)))
      
      if(length(StillToCapture)>0){
        print("Unassigned nodes detected. This is due to the presence of loops. Additional branching assignement will be performed.")
        
        # computing all the distances between the unassigned points and the interesting points
        AllDists <- igraph::distances(graph = Net, v = paste(StillToCapture), to = paste(SelEp))
        
        # get the closest interesting point
        EndPoint_1 <- colnames(AllDists)[apply(AllDists, 1, which.min)]
        
        EndPoint_2 <- EndPoint_1
        EndPoint_2[] <- NA
        
        # to get the second we have to avoid passing trough the first one
        for(i in 1:length(StillToCapture)){
          tNet <- igraph::delete_vertices(graph = Net, EndPoint_1[i])
          PointDists <- igraph::distances(graph = tNet, v = paste(StillToCapture[i]),
                                          to = intersect(paste(SelEp), igraph::V(graph = tNet)$name))
          EndPoint_2[i] <- colnames(PointDists)[which.min(PointDists)]
        }
        
        
        EndPoints <- rbind(as.integer(EndPoint_1), as.integer(EndPoint_2))
        EndPoints <- apply(EndPoints, 2, sort)
        
        NewBrEP <- EndPoints[,!duplicated(data.frame(t(EndPoints)))]
        
        for(i in 1:ncol(NewBrEP)){
          # for each pair of interesting points
          
          # print(i)
          
          # Create a temporary network by merginig the path with the end points
          tNet <- igraph::induced.subgraph(graph = Net,
                                           vids = union(
                                             StillToCapture[
                                             apply(EndPoints, 2, function(x) {
                                               all(x %in% NewBrEP[,i])
                                             })], NewBrEP[,i]))
          
          if(igraph::are.connected(Net, paste(NewBrEP[1,i]), paste(NewBrEP[2,i]))){
            tNet <- igraph::delete.edges(graph = tNet,
                                         edges = igraph::get.edge.ids(graph = tNet, paste(NewBrEP[,i])))
          }
          
          tNet <- igraph::induced.subgraph(graph = tNet, igraph::degree(tNet)>0)
          
          # plot(tNet)
          
          PotentialEnds <- intersect(NewBrEP[,i], as.integer(igraph::V(tNet)$name))
          
          if(length(PotentialEnds)==1){
            # it's a simple loop
            
            # get all loops
            AllLoops <- igraph::graph.get.isomorphisms.vf2(igraph::make_ring(igraph::vcount(tNet), directed = FALSE, circular = TRUE), tNet)
            
            # select one with the branching point at the beginning
            Sel <- which(sapply(AllLoops, function(x){as.integer(names(x)[1])}) == PotentialEnds)[1]
            
            # Add a new branch
            AllPaths[[length(AllPaths)+1]] <- as.integer(names(AllLoops[[Sel]]))
            names(AllPaths)[length(AllPaths)] <- paste0("Branch_", length(AllPaths))
            
          }
          
          if(length(PotentialEnds) == 2){
            # it's either a line or a line and a loop
            
            LinePath <- igraph::get.shortest.paths(tNet, as.character(PotentialEnds[1]), as.character(PotentialEnds[2]))$vpath[[1]]
            
            # Add a new branch
            AllPaths[[length(AllPaths)+1]] <- as.integer(names(LinePath))
            names(AllPaths)[length(AllPaths)] <- paste0("Branch_", length(AllPaths))
            
            # tNet
            
            if(length(LinePath) < igraph::vcount(tNet)){
              
              
              
              # assuming that the remaining part is a loop do as above
              AllLoops <- igraph::graph.get.subisomorphisms.vf2(tNet, igraph::make_ring(igraph::vcount(tNet)-length(LinePath)+1, directed = FALSE, circular = TRUE))
              
              if(length(AllLoops) == 0){
                stop("Unsupported structure. Contact the package manintainer")
              }
              
              # select one with the branching point at the beginning
              Sel <- which(sapply(AllLoops, function(x){as.integer(names(x)[1])}) %in% PotentialEnds)[1]
              
              if(is.na(Sel)){
                stop("Unsupported structure. Contact the package manintainer")
              }
              
              # Add a new branch
              AllPaths[[length(AllPaths)+1]] <- as.integer(names(AllLoops[[Sel]]))
              names(AllPaths)[length(AllPaths)] <- paste0("Branch_", length(AllPaths))
              
            }
            
          }
          
        }
        
      }
      
      AllPaths <- lapply(AllPaths[sapply(AllPaths, length)>0], function(x){
        names(x) <- x
        return(x)
      })
      
      return(AllPaths)
      
    } else {
      
      Structure == 'end2end'
      
    }
    
    
    
  }
  
  
  
  
  if(Structure == 'branches&bpoints'){
    
    if(any(igraph::degree(Net)>2) & any(igraph::degree(Net)==1)){
      
      BrPoints <- which(igraph::degree(Net)>2)
      EndPoints <- which(igraph::degree(Net)==1)
      
      Allbr <- list()
      SelEp <- union(BrPoints, EndPoints)
      
      for(i in BrPoints){
        
        SelEp <- setdiff(SelEp, i)
        
        for(j in SelEp){
          Path <- igraph::get.shortest.paths(graph = Net, from = i, to = j)$vpath[[1]]
          if(!any(Path %in% setdiff(BrPoints, c(i,j)))){
            Allbr[[length(Allbr)+1]] <- Path
          }
        }
      }
      
      Allbr <- lapply(Allbr, function(x){
        setdiff(x, BrPoints)
      })
      
      BaseNameVect <- paste("Branch", 1:length(Allbr), sep = "_")
      
      BrCount <- 0
      
      for(i in BrPoints){
        BrCount <- BrCount + 1
        Allbr[[length(Allbr)+1]] <- i
        BaseNameVect <- c(BaseNameVect, paste("BrPoint", BrCount, sep = "_"))
      }
      
      names(Allbr) <- BaseNameVect
      
      return(Allbr)
      
    } else {
      Structure == 'end2end'
    }
    
  }
  
  
  
  if(Structure == 'branching'){
    
    BrPoints <- which(igraph::degree(Net)>2)
    
    Allbr <- list()
    
    for(i in BrPoints){
      Points <- i
      DONE <- FALSE
      Terminal.Branching = NULL
      while(!DONE){
        Nei <- unlist(igraph::neighborhood(Net, 1, Points))
        Nei <- setdiff(Nei, Points)
        
        NeiDeg <- igraph::degree(Net, Nei, loops = FALSE)
        NewPoints <- union(Points, Nei[NeiDeg < 3])
        
        Terminal.Branching <- union(Terminal.Branching, Nei[NeiDeg >= 3])
        
        if(length(setdiff(NewPoints, Points)) == 0){
          DONE <- TRUE
        } else {
          Points <- NewPoints
        }
      }
      
      if(KeepEnds){
        Allbr[[length(Allbr) + 1]] <- union(Points, Terminal.Branching)
      } else {
        Allbr[[length(Allbr) + 1]] <- Points
      }
      
    }
    
    names(Allbr) <- paste("Subtree", 1:length(Allbr), sep = "_")
    
    return(Allbr)
    
  }
  
  
  
  if(Structure == 'end2end'){
    
    EndPoints <- which(igraph::degree(Net)==1)
    
    Allbr <- list()
    
    for(i in 1:(length(EndPoints)-1)){
      for(j in (i+1):length(EndPoints)){
        suppressWarnings(
          Path <- igraph::get.shortest.paths(graph = Net, from = EndPoints[i], to = EndPoints[j])$vpath[[1]]
        )
        if(length(Path) > 0){
          Allbr[[length(Allbr)+1]] <- Path
        }
      }
    }
    
    names(Allbr) <- paste("Path", 1:length(Allbr), sep = "_")
    
    return(Allbr)
    
  }
  
  
  
  
  

}



#' Return a data frame summarizing the branching structure
#'
#' @param Net an igraph network
#' @param StartingPoint the starting points
#'
#' @return a data frame with three columns:
#' \itemize{
#'  \item VName contains the vertx names
#'  \item Branch contains the id of the branch (numbering start from the branch
#' containing the starting point) or 0 if a branching point
#'  \item BrPoints the branchhing point id, or 0 if not a branching point
#' }
#' 
#' @export
#'
#' @examples
GetBranches <- function(Net, StartingPoint = NULL) {
  
  if(is.numeric(StartingPoint)){
    StartingPoint <- paste(StartingPoint)
  }
  
  if(is.null(StartingPoint)){
    EndPoints <- names(which(igraph::degree(Net)==1))
    StartingPoint <- sample(EndPoints, 1)
  }
  
  if(igraph::degree(Net, v = StartingPoint) != 1){
    stop("Invalid starting point")
  }
  
  Vertices <- igraph::V(Net)$name
  
  Branches <- rep(0, length(Vertices))
  DiffPoints <- rep(0, length(Vertices))
  
  names(Branches) <- Vertices
  names(DiffPoints) <- Vertices
  
  tNet <- Net
  CurrentEdges <- StartingPoint
  Branches[StartingPoint] <- 1
  NewEdges <- NULL
  
  while (length(igraph::V(tNet))>0) {
    
    for(i in 1:length(CurrentEdges)){
      AllNei <- names(igraph::neighborhood(graph = tNet, order = 1, nodes = CurrentEdges[i])[[1]])
      AllNei <- setdiff(AllNei, CurrentEdges[i])
      
      NewEdges <- union(NewEdges, AllNei)
      
      if(length(AllNei)>0){
        for(j in 1:length(AllNei)){
          if(igraph::degree(tNet, v = AllNei[j])>2){
            DiffPoints[AllNei[j]] <- max(DiffPoints) + 1
          } else {
            if(DiffPoints[CurrentEdges[i]]>0){
              Branches[AllNei[j]] <- max(Branches) +1
            } else {
              Branches[AllNei[j]] <- Branches[CurrentEdges[i]]
            }
          }
        }
      }
      
      tNet <- igraph::delete.vertices(graph = tNet, v = CurrentEdges[i])
      
    }
    
    CurrentEdges <- NewEdges 
    NewEdges <- NULL
    
  }
  
  return(data.frame(VName = Vertices, Branch = Branches, BrPoints = DiffPoints))
  
}

