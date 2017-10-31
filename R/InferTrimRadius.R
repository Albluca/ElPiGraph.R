#' Title
#'
#' @param X
#' @param nPoints 
#' @param plotCurves 
#'
#' @return
#' @export
#'
#' @examples
InferTrimRadius <- function(X, nPoints, nInt = 100, plotCurves = FALSE){

  if(nPoints > nrow(X)){
    nPoints = nrow(X)
  }

  # Get Distances between points

  SquredX <- rowSums(X^2)
  Dist <- distutils::PartialDistance(X, X)

  RealDists <- Dist[upper.tri(Dist)]
  boxplot(RealDists)
  
  Dist.l <- min(RealDists)
  Dist.m <- max(RealDists)
  
  DVect <- Dist.m*(2^seq(from=.01, by=10/nInt, to = 10))/512

  RDSMat <- sapply(sample(1:nrow(X), nPoints), function(Idx){
    distutils::RadialCount(X[-Idx, ], X[Idx,], SquaredAr = SquredX[-Idx],
                           DVect = DVect)$PCount
  })
  
  par(mfrow =c(3,3))

  PTs <- apply(RDSMat, 2, function(v){
    
    t.df <- data.frame(x = log2(512*DVect/Dist.m), y = log2(v+1))
    t.df <- t.df[v>2,]
    # print(df$y)
    
    # print(sum(duplicated(t.df$y))/length(t.df$y))
    # print(quantile(t.df$x, c(.01, .25, .75)))
    
    if(plotCurves){
      plot(t.df$x, t.df$y)
    }
    
    piecewiseModel <- NULL
    
    tryCatch({
      piecewiseModel <- segmented::segmented(lm(y~x, data=t.df),
                                             seg.Z = ~ x,
                                             psi = quantile(t.df$x, c(.01, .25, .75)))
    }, error = function(e) {
      print("Error in segmentation ... skipping")
      return(NULL)
    })
    
    if(!is.null(piecewiseModel)){
      Points <- segmented::confint.segmented(piecewiseModel)$x[,1]
      
      if(plotCurves){
        abline(v=Points)
      }
      
      return(Points)
    }

  })
  
  par(mfrow =c(1,1))
  
  if(is.list(PTs)){
    PTs <- PTs[!sapply(PTs, is.null)]
    PTs <- do.call(rbind, PTs)
    PTs <- t(PTs)
  }
  
  
  
  InfData <- Dist.m*(PTs[1,]^2)/512
  
  boxplot(InfData)
  
  return(InfData)

}
