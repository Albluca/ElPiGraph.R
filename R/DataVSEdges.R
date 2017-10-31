#' Title
#'
#' @param X 
#' @param TargetPG 
#' @param GroupsLab 
#'
#' @return
#' @export
#'
#' @examples
EdgeCatAssociation <- function(X, TargetPG, GroupsLab = NULL) {
  
  PartData <- PartitionData(X = X, NodePositions = TargetPG$NodePositions, SquaredX = rowSums(X^2))
  
  Prj <- project_point_onto_graph(X = X, NodePositions = TargetPG$NodePositions,
                           Edges = TargetPG$Edges$Edges, Partition = PartData$Patition)
  
  OnNode <- (Prj$ProjectionValues <= 0 | Prj$ProjectionValues >= 1)
  OnEdge <- (Prj$ProjectionValues > 0 & Prj$ProjectionValues < 1)
  
  Association <- rep(NA, nrow(X))
  
  Association[OnEdge] <- paste("Edge =", Prj$EdgeID[OnEdge])
  Association[OnNode] <- paste("Node =", PartData$Partition[OnNode])
  
  TB_E <- table(Association, GroupsLab)
  TB_N <- table(paste("Node =", PartData$Partition), GroupsLab)
  
  return(
    list(
      OnEdges = list(Table = TB_E, ChiTest = chisq.test(TB_E, simulate.p.value = TRUE)),
      OnNodes = list(Table = TB_N, ChiTest = chisq.test(TB_N, simulate.p.value = TRUE))
    )
  )
  
}
