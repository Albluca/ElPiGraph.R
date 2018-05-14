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
    
    SubIsoProjList <- SubIsoProjList[!duplicated(sapply(SubIsoProjList, function(x){x[1]}))]

    names(SubIsoProjList) <- paste("Circle", 1:length(SubIsoProjList), sep = "_")
    
    if(Circular){
      return(lapply(SubIsoProjList, function(x) {c(x, x[1])}))
    } else {
      return(SubIsoProjList)
    }

  }
  
  
  
  if(Structure == 'branches'){
    
    if(any(igraph::degree(Net)>2) & any(igraph::degree(Net)==1)){
      
      BrPoints <- which(igraph::degree(Net)>2)
      EndPoints <- which(igraph::degree(Net)==1)
      
      Allbr <- list()
      SelEp <- union(BrPoints, EndPoints)
      
      for(i in BrPoints){
        
        SelEp <- setdiff(SelEp, i)
        
        DistVect <- igraph::distances(graph = Net, v = i)
        
        for(j in SelEp){
          if(is.finite(DistVect[j])){
            Path <- igraph::get.shortest.paths(graph = Net, from = i, to = j)$vpath[[1]]
            if(!any(Path %in% setdiff(BrPoints, c(i,j)))){
              Allbr[[length(Allbr)+1]] <- Path
            }
          }
        }
      }
      
      if(!KeepEnds){
        Allbr <- lapply(Allbr, function(x){
          setdiff(x, BrPoints)
        })
      }
      
      names(Allbr) <- paste("Branch", 1:length(Allbr), sep = "_")
      
      return(Allbr)
      
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

