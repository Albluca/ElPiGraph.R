#' Title
#'
#' @param X
#' @param nPoints
#' @param plotCurves
#' @param nInt 
#' @param n.cores 
#' @param ClusType 
#'
#' @return
#' @export
#'
#' @examples
InferTrimRadius <- function(X, nPoints = NULL, nInt = 100, plotCurves = FALSE, n.cores = 1, ClusType = "FORK"){

  if(is.null(nPoints)){
    nPoints <- nrow(X)
  }
  
  if(nPoints > nrow(X)){
    nPoints <- nrow(X)
  }

  # Get Distances between points

  SquaredX <- rowSums(X^2)
  Dist <- distutils::PartialDistance(Ar = X, Br = X)
  
  RealDists <- Dist[upper.tri(Dist, diag = FALSE)]
  boxplot(RealDists)

  Dist.l <- min(RealDists)
  Dist.m <- max(RealDists)

  DVect <- Dist.m*(2^seq(from=.01, by=10/nInt, to = 10))/512

  RDSMat <- sapply(sample(1:nrow(X), nPoints), function(Idx){
    distutils::RadialCount(X[-Idx, ], X[Idx,], SquaredAr = SquaredX[-Idx],
                           DVect = DVect)$PCount
  })

  par(mfrow =c(3,3))

  ComputeFunction <- function(v, DVect, Dist.m, plotCurves){
    
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
    
  }
  
  
  if(n.cores > 1){
    
    if(ClusType == "FORK"){
      cl <- parallel::makeForkCluster(n.cores)
    } else {
      cl <- parallel::makePSOCKcluster(n.cores)
    }
    
    PTs <- parallel::parApply(cl, RDSMat, 2, ComputeFunction, DVect=DVect, Dist.m=Dist.m, plotCurves=FALSE)
    
    parallel::stopCluster(cl)
    
  } else {
    
    PTs <- apply(RDSMat, 2, ComputeFunction, DVect=DVect, Dist.m=Dist.m, plotCurves=plotCurves)
    
  } 
  
  
  

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
