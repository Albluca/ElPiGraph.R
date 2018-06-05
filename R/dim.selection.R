# 
# SelectDimensions <- function(X,
#                              Partition,
#                              Edges,
#                              ProjStruct,
#                              EdgeSeq,
#                              Mode = "CV",
#                              AggFun = min,
#                              Span = .75,
#                              nCores = 1) {
# 
# 
#   # Check that path is present in the data and extract pseudotime
# 
#   Pt <- getPseudotime(X = X, Edges = Edges, ProjStruct = ProjStruct, EdgeSeq = EdgeSeq)
# 
#   if(Mode == "CV"){
# 
#     # Subset data
# 
#     SubX <- X[Partition %in% unique(EdgeSeq),]
#     SubPart <- Partition[Partition %in% unique(EdgeSeq)]
# 
#     print(paste("Computing coefficient of variation on", ncol(X), "dimensions and",
#                 length(unique(Partition)), "pseudotime points on a single processor."))
# 
#     GeneExprMat.DF.Split <- split(data.frame(SubX), SubPart)
# 
#     GeneExprMat.DF.Split.Mean <- lapply(GeneExprMat.DF.Split, colMeans)
#     GeneExprMat.DF.Split.Sd <- lapply(GeneExprMat.DF.Split, function(x){apply(x, 2, sd)})
# 
#     GeneExprMat.DF.MeanRemoved <-
#       lapply(as.list(1:length(GeneExprMat.DF.Split)), function(i){
#         GeneExprMat.DF.Split.Sd[[i]]/GeneExprMat.DF.Split.Mean[[i]]
#       })
# 
#     GeneExprMat.DF.MeanRemoved.All <- do.call(rbind, GeneExprMat.DF.MeanRemoved)
#     colnames(GeneExprMat.DF.MeanRemoved.All) <- colnames(X)
# 
#     RetVal <- apply(abs(GeneExprMat.DF.MeanRemoved.All), 2, AggFun, na.rm = TRUE)
# 
#     return(RetVal)
# 
#   }
# 
#   if(Mode == "SmoothOnPath"){
# 
#     Sorted <- sort(Pt$Pt[Partition %in% unique(EdgeSeq)], index.return=TRUE)
#     SortedPointID <- which(Partition %in% unique(EdgeSeq))[Sorted$ix]
# 
#     FitFun <- function(x){
# 
#       LocDF <- data.frame(Exp = x[SortedPointID], PT = Sorted$x)
# 
#       LOE <- loess(Exp ~ PT, LocDF, span = Span)
#       predict(LOE, data.frame(PT = Pt$NodePos), se = TRUE)
# 
#     }
# 
#     if(nCores <= 1){
# 
#       print(paste("Computing loess smoothers on", ncol(X), "dimensions and",
#                   length(EdgeSeq) - 1, "pseudotime segments on a single processor. This may take a while ..."))
#       AllFit <- apply(X[Partition %in% unique(EdgeSeq),], 2, FitFun)
# 
#     } else {
# 
#       no_cores <- parallel::detectCores()
# 
#       if(nCores > no_cores){
#         nCores <- no_cores
#         print(paste("Too many cores selected!", nCores, "will be used"))
#       }
# 
#       if(nCores == no_cores){
#         print("Using all the cores available. This will likely render the system unresponsive untill the operation has concluded ...")
#       }
# 
#       print(paste("Computing loess smoothers on", ncol(X), "dimensions and", length(EdgeSeq) - 1,
#                   "pseudotime segments using", nCores, "processors. This may take a while ..."))
# 
#       cl <- parallel::makeCluster(nCores)
# 
#       parallel::clusterExport(cl=cl, varlist=c("SortedPointID", "Sorted", "Span", "Pt"),
#                               envir = environment())
# 
#       AllFit <- parallel::parApply(cl, SubX, 2, FitFun)
# 
#       parallel::stopCluster(cl)
# 
#     }
# 
#     RetVal <- lapply(AllFit, function(x){x$se.fit/abs(x$fit)}) %>%
#       sapply(., AggFun)
# 
#     names(RetVal) <- colnames(SubX)
# 
#     return(RetVal)
# 
#   }
# 
#   if(Mode == "LinearOnPath"){
# 
#     print(paste("Computing correlations on", ncol(X), "dimesions and", length(EdgeSeq) - 1, "pseudotime segments."))
# 
#     AllFit <- apply(X, 2, function(x){
# 
#       sapply(2:length(EdgeSeq), function(i){
# 
#         ToUse <- (Pt$Pt <= Pt$NodePos[i] & Pt$Pt >= Pt$NodePos[i-1])
#         ToUse[is.na(ToUse)] <- FALSE
# 
#         tX <- Pt$Pt[ToUse]
#         tY <- x[ToUse]
# 
#         if( sum(ToUse)>3 & length(unique(tX))>1 & length(unique(tY))>1 ){
#           cor.test(tY, tX, method = "spe")$p.value
#           } else {
#           return(1)
#         }
# 
#       }) %>% AggFun
# 
#     })
# 
#     names(AllFit) <- colnames(X)
# 
#     return(AllFit)
# 
#   }
# 
# }





#' Measure smoothness of the differnt feature of the data
#'
#' @param X 
#' @param Paths 
#' @param TargetPG 
#' @param SmoothMode 
#' @param CollMode 
#' @param Partition 
#' @param PrjStr 
#' @param Randomize 
#' @param ... 
#'
#' @return
#' @export
#'
#' @examples
MeasureSmoothness <- function(X,
                              Paths,
                              TargetPG,
                              SmoothMode = "lowess",
                              CollMode = "var",
                              Partition = NULL,
                              PrjStr = NULL,
                              Randomize = 0,
                              ...) {
  
  # X = tree_data
  # Paths = lapply(SelPaths[1:4], function(x){names(x)})
  # TargetPG = TreeEPG[[1]]
  # Partition = PartStruct$Partition
  # PrjStr = ProjStruct
  # Mode = "lowess"
  # Randomize = 0
  
  if(is.null(Partition)){
    Partition <- PartitionData(X = X, NodePositions = TargetPG$NodePositions)$Partition
  }
  
  if(is.null(PrjStr)){
    PrjStr <- project_point_onto_graph(X = X,
                                           NodePositions = TargetPG$NodePositions,
                                           Edges = TargetPG$Edges$Edges,
                                           Partition = Partition)
  }
  
  AllPt <- lapply(Paths, function(x){
    getPseudotime(ProjStruct = PrjStr, NodeSeq = as.integer(x))
  })
  
  
  AllData <- lapply(AllPt, function(x){
    
    Pt_rest <- x$Pt
    X_rest <- X[!is.na(Pt_rest),]
    
    Pt_rest <- Pt_rest[!is.na(Pt_rest)]
    Ordered_Pt <- order(Pt_rest)
    
    X_rest <- X_rest[Ordered_Pt,]
    Pt_rest <- Pt_rest[Ordered_Pt]
    
    
    if(SmoothMode == "lowess"){
      
      Diff <- apply(X_rest, 2, function(y){
        lowess(Pt_rest, y, ...)$y
      })
      
      if(CollMode == "sum"){
        return(apply(abs(Diff), 2, sum))
      }
      
      if(CollMode == "var"){
        return(apply(Diff, 2, var))
      }
      
      if(CollMode == "cv"){
        return(apply(Diff, 2, var)/abs(apply(Diff, 2, mean)))
      }
      
    }
    
    
    
    if(SmoothMode == "akima"){
      
      Diff <- apply(X_rest, 2, function(y){
        akima::aspline(Pt_rest, y, ...)$y
      })
      
      if(CollMode == "sum"){
        return(apply(abs(Diff), 2, sum))
      }
      
      if(CollMode == "var"){
        return(apply(Diff, 2, var))
      }
      
      if(CollMode == "cv"){
        return(apply(Diff, 2, var)/abs(apply(Diff, 2, mean)))
      }
      
    }
    
    
  })
  
  return(do.call(rbind, AllData))

}
