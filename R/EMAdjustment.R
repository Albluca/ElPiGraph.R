#' Adjust elastic matrix by dividing the values of lambda and mu of stars
#'
#' @param GraphInfo the elpigraph structure updated
#' @param k the largest orger of strars to leave unadjusted. e.g., if k = 2 only branching points will be adjusted
#' @param divLambda the value used to divide the lambda coefficients
#' @param divMu the value used to divide the mu coefficients
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
