#' Compute the pseudotime associted with a path
#'
#' @param ProjStruct A projection structure list as obtained by the project_point_onto_graph function
#' @param NodeSeq string, a sequence of nodes that forms a path in the graph.
#'
#' @description Compute the pseudotime associated to the points over the specified path.
#' Note that the pseudotime of points not associted with any edges of the specified path 
#' will be set to NA.
#'
#' @return a list containing three elements:
#' \itemize{
#'  \item{Pt:}{ numerical vector, the pseudotime associted with each points in the specified path}
#'  \item{PathLen:}{ The total length of the path}
#'  \item{NodePos:}{ The pseudotime associated with the of the nodes of the graph}
#' }
#' @export
#'
#' @examples
#' 
getPseudotime <- function(ProjStruct, NodeSeq){
  
  Pt <- rep(NA, nrow(ProjStruct$X_projected))
  tLen <- 0
  NodePos <- 0
  
  for(i in 2:length(NodeSeq)){
    SelEdgID <- which(
      apply(
        apply(ProjStruct$Edges, 1, function(x) {
          x %in% NodeSeq[(i-1):i]
        }), 2, all)
    )
    
    # print(paste(i, SelEdgID, tLen))
    
    if(length(SelEdgID) != 1){
      stop("Path not found in the graph")
    }
    
    Selected <- ProjStruct$EdgeID == SelEdgID
    if(all(ProjStruct$Edges[SelEdgID,] == NodeSeq[(i-1):i])){
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
    PtOnPath <- getPseudotime(ProjStruct = PrjStr, NodeSeq = Paths[[i]])
    
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
#' @param TargetPG 
#' @param Partition 
#' @param PrjStr 
#' @param Main 
#' @param genes 
#' @param Group 
#' @param Path 
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
  
  PtOnPath <- getPseudotime(ProjStruct = PrjStr, NodeSeq = Path)
  
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


