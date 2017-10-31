#' Title
#'
#' @param X 
#' @param NumNodes 
#' @param Subset 
#' @param Samples 
#' @param Type 
#' @param Exclusive 
#' @param ... 
#'
#' @return
#' @export
#'
#' @examples
StudyOverDispersion <- function(X, NumNodes, Subset, Samples = 100, Type = "Curve", Exclusive = FALSE, ...) {
  
  # X = t(SelData)
  # NumNodes = 30
  # Samples = 100
  # Exclusive = FALSE
  # Subset <- sample(colnames(X), 30)
  
  Subset <- Subset[Subset %in% colnames(X)]
  
  if(Exclusive){
    Selectionable <- setdiff(colnames(X), Subset)
  } else {
    Selectionable <- colnames(X)
  }
  
  Subsets <- lapply(1:Samples, function(i){
    sample(Selectionable, length(Subset))
  })
  Subsets <- append(list(Subset), Subsets)
  
  if(Type == "Curve"){
    
    tictoc::tic()
    Base <- computeElasticPrincipalCurve(X = X, NumNodes = NumNodes, drawAccuracyComplexity = FALSE,
                                        drawEnergy = FALSE, drawPCAView = FALSE, Subsets = Subsets, ...)
    tictoc::toc()
    
  }
  
  
  if(Type == "Tree"){
    
    tictoc::tic()
    Base <- computeElasticPrincipalTree(X = X, NumNodes = NumNodes, drawAccuracyComplexity = FALSE,
                                        drawEnergy = FALSE, drawPCAView = FALSE, Subsets = Subsets, ...)
    tictoc::toc()
    
  }
  
  
  if(Type == "Circle"){
    
    tictoc::tic()
    Base <- computeElasticPrincipalCircle(X = X, NumNodes = NumNodes, drawAccuracyComplexity = FALSE,
                                        drawEnergy = FALSE, drawPCAView = FALSE, Subsets = Subsets, ...)
    tictoc::toc()
    
  }
  
  ReportData <- sapply(Base, "[[", "FinalReport")
  FVE.Sampled <- unlist(ReportData["FVE",])
  FVEP.Sampled <- unlist(ReportData["FVEP",])
  
  par(mfcol = c(1,2))
  
  boxplot(FVE.Sampled[-1], at = 1, main = "FVE")
  points(x = 1, FVE.Sampled[1], col="red", pch = 20)
  
  boxplot(FVEP.Sampled[-1], at = 1, main = "FVEP")
  points(x = 1, FVEP.Sampled[1], col="red", pch = 20)
  
  par(mfcol = c(1,1))
     
  return(list(Data = Base,
           FVE = wilcox.test(FVE.Sampled[-1] - FVE.Sampled[1], alternative = "less")$p.value,
           FVEP = wilcox.test(FVEP.Sampled[-1] - FVEP.Sampled[1], alternative = "less")$p.value))
  
}