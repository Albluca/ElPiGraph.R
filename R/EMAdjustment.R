#' Title
#'
#' @param GraphInfo 
#' @param k 
#' @param divLambda 
#' @param divMu 
#'
#' @return
#' @export
#'
#' @examples
AdjustByConstant <- function(GraphInfo, k = 2, divMu = 10, divLambda = 10) {
  
  tGraphInfo <- GraphInfo
  
  StarOrder <- rowSums(tGraphInfo$ElasticMatrix>0) - 1
  StarOrder[StarOrder == 0] <- 1
  
  ToAdjust <- which(!tGraphInfo$AdjustVect & StarOrder > k)
  
  if(length(ToAdjust)>0){
    for(i in ToAdjust){
      tGraphInfo$ElasticMatrix[i,] <- GraphInfo$ElasticMatrix[i,]/divLambda
      tGraphInfo$ElasticMatrix[,i] <- GraphInfo$ElasticMatrix[,i]/divLambda
      tGraphInfo$ElasticMatrix[i,i] <- GraphInfo$ElasticMatrix[i,i]/divMu
    }
    tGraphInfo$AdjustVect[i] <- TRUE
  }
  
  return(tGraphInfo)
}


# 
# GraphInfo <- list()
# GraphInfo$ElasticMatrix <- ElPiGraph.R::MakeUniformElasticMatrix(data.matrix(Simulation$InitEdges), .01, .1)
