# Generate an igraph from the pringicical graph ---------------------------

#' Title
#'
#' @param Results
#' @param DirectionMat
#' @param Thr
#'
#' @return
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






















#
# # CompareNets -------------------------------------------------------------
#
#
# CompareNet <- function(G1, G2, RemNodes = 2, Tries = 10000, DoIso = FALSE) {
#
#   if(DoIso){
#     Full_Iso <- graph.get.isomorphisms.vf2(graph1 = G1, graph2 = G2)
#
#     if(length(Full_Iso)>0){
#       return(0)
#     }
#   }
#
#   pb <- txtProgressBar(min = 1, max = Tries, initial = 1, style = 3)
#
#   for (Retries in 1:Tries) {
#     setTxtProgressBar(pb, Retries)
#     RemVert <- sample(x = V(G1), size = RemNodes, replace = FALSE)
#     tNet <- delete_vertices(G1, RemVert)
#     Part_Iso <- graph.get.subisomorphisms.vf2(graph1 = G2, graph2 = tNet)
#     if(length(Part_Iso)>0){
#       RetVal <- list(rem)
#       close(pb)
#       return(list(SubIso = Part_Iso, RemVert = RemVert))
#     }
#   }
#
#   close(pb)
#   return(NULL)
#
# }





# Extract a subpath from the graph ----------------------------------------


#' Title
#'
#' @param Net
#' @param Structure
#' @param Circular
#'
#' @return
#' @export
#'
#' @examples
GetSubGraph <- function(Net, Structure = 'auto', Nodes = NULL, Circular = TRUE) {

  if(Structure == 'auto'){

    print('Structure autodetection is not implemented yet')
    return(NULL)

  }

  if(Structure == 'circle'){

    if(is.null(Nodes)){
      print("Looking for the largest cycle")
      
      for(i in rev(1:igraph::vcount(Net))){
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

    if(Circular){
      return(lapply(SubIsoProjList, function(x) {c(x, x[1])}))
    } else {
      return(SubIsoProjList)
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
      
      Allbr[[length(Allbr) + 1]] <- union(Points, Terminal.Branching)
      
    }
    
    return(Allbr)
    
  }
  
  
  
  
  
  # if(Structure == 'Lasso'){
  #
  #   # The largest
  #
  #   RefNet <- igraph::graph.ring(n = igraph::vcount(Net), directed = FALSE, circular = FALSE)
  #   SubIsoProjList <- igraph::graph.get.subisomorphisms.vf2(Net, RefNet)
  #
  #   StartNode <- which(igraph::degree(Net)==1)
  #
  #   WayNode <- which(igraph::degree(Net)==3)
  #
  #   VerNumMat <- t(sapply(1:length(SubIsoProjList), FUN = function(i){unlist(lapply(strsplit(SubIsoProjList[[i]]$name, split = "V_"), "[[", 2))}))
  #   VerNumMat <- VerNumMat[VerNumMat[,1] == StartNode_Numb,]
  #
  #   VerNameMat <- t(sapply(SubIsoProjList, names))
  #   VerNameMat <- VerNameMat[VerNameMat[,1] == StartNode_Name,]
  #
  #   if(Circular){
  #     return(list(VertPath = cbind(VerNameMat, WayNode_Name),
  #               VertNumb = cbind(VerNumMat, WayNode_Numb)))
  #   } else {
  #     return(list(VertPath = VerNameMat,
  #                 VertNumb = VerNumMat))
  #   }
  #
  # }
  #
  # if(Structure == 'Tail'){
  #
  #   # The largest
  #
  #   if(all(igraph::degree(Net)!=1) & all(igraph::degree(Net)!=3)){
  #     return(NULL)
  #   }
  #
  #   StartNode_Name <- names(which(igraph::degree(Net)==1))
  #   StartNode_Numb <- strsplit(StartNode_Name, "V_", TRUE)[[1]][2]
  #
  #   EndNode_Name <- names(which(igraph::degree(Net)==3))
  #   EndNode_Numb <- strsplit(EndNode_Name, "V_", TRUE)[[1]][2]
  #
  #   VerNameMat <- names(igraph::get.shortest.paths(graph = Net, from = StartNode_Name, to = EndNode_Name)$vpath[[1]])
  #   VerNumMat <- unlist(lapply(strsplit(VerNameMat, "V_", TRUE), "[[", 2), use.names = FALSE)
  #
  #   return(list(VertPath = VerNameMat, VertNumb = VerNumMat))
  #
  # }
  #
  # if(Structure == 'Line'){
  #
  #   # The largest
  #
  #   if(any(igraph::degree(Net)>2)){
  #     return(NULL)
  #   }
  #
  #   RefNet <- igraph::graph.ring(n = igraph::vcount(Net), directed = FALSE, circular = FALSE)
  #
  #   SubIsoProjList <- igraph::graph.get.subisomorphisms.vf2(Net, RefNet)
  #
  #   VerNumMat <- t(sapply(1:length(SubIsoProjList), FUN = function(i){unlist(lapply(strsplit(SubIsoProjList[[i]]$name, split = "V_"), "[[", 2))}))
  #   VerNumMat <- VerNumMat[!duplicated(VerNumMat[,1]),]
  #
  #   VerNameMat <- t(sapply(SubIsoProjList, names))
  #   VerNameMat <- VerNameMat[!duplicated(VerNameMat[,1]),]
  #
  #   return(list(VertPath = VerNameMat, VertNumb = VerNumMat))
  #
  # }

}



#' Title
#'
#' @param Net 
#' @param StartingPoint 
#'
#' @return
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
  
  
  return(data.frame(VName = Vertices, Branches = Branches, DiffPoints = DiffPoints))
  
}

