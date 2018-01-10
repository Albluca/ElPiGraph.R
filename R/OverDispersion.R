# StudyOverDispersion <- function(X, NumNodes, Subset, Samples = 100, Type = "Curve", Exclusive = FALSE, ...) {
#   
#   # X = t(SelData)
#   # NumNodes = 30
#   # Samples = 100
#   # Exclusive = FALSE
#   # Subset <- sample(colnames(X), 30)
#   
#   Subset <- Subset[Subset %in% colnames(X)]
#   
#   if(Exclusive){
#     Selectionable <- setdiff(colnames(X), Subset)
#   } else {
#     Selectionable <- colnames(X)
#   }
#   
#   Subsets <- lapply(1:Samples, function(i){
#     sample(Selectionable, length(Subset))
#   })
#   Subsets <- append(list(Subset), Subsets)
#   
#   if(Type == "Curve"){
#     
#     tictoc::tic()
#     Base <- computeElasticPrincipalCurve(X = X, NumNodes = NumNodes, drawAccuracyComplexity = FALSE,
#                                         drawEnergy = FALSE, drawPCAView = FALSE, Subsets = Subsets, ...)
#     tictoc::toc()
#     
#   }
#   
#   
#   if(Type == "Tree"){
#     
#     tictoc::tic()
#     Base <- computeElasticPrincipalTree(X = X, NumNodes = NumNodes, drawAccuracyComplexity = FALSE,
#                                         drawEnergy = FALSE, drawPCAView = FALSE, Subsets = Subsets, ...)
#     tictoc::toc()
#     
#   }
#   
#   
#   if(Type == "Circle"){
#     
#     tictoc::tic()
#     Base <- computeElasticPrincipalCircle(X = X, NumNodes = NumNodes, drawAccuracyComplexity = FALSE,
#                                         drawEnergy = FALSE, drawPCAView = FALSE, Subsets = Subsets, ...)
#     tictoc::toc()
#     
#   }
#   
#   ReportData <- sapply(Base, "[[", "FinalReport")
#   FVE.Sampled <- unlist(ReportData["FVE",])
#   FVEP.Sampled <- unlist(ReportData["FVEP",])
#   
#   par(mfcol = c(1,2))
#   
#   boxplot(FVE.Sampled[-1], at = 1, main = "FVE")
#   points(x = 1, FVE.Sampled[1], col="red", pch = 20)
#   
#   boxplot(FVEP.Sampled[-1], at = 1, main = "FVEP")
#   points(x = 1, FVEP.Sampled[1], col="red", pch = 20)
#   
#   par(mfcol = c(1,1))
#      
#   return(list(Data = Base,
#            FVE = wilcox.test(FVE.Sampled[-1] - FVE.Sampled[1], alternative = "less")$p.value,
#            FVEP = wilcox.test(FVEP.Sampled[-1] - FVEP.Sampled[1], alternative = "less")$p.value))
#   
# }























# 
# ExploreVarianceOverCurve <- function(X, NumNodes, Type = "Curve",
#                                              nReps = 100, ProbPoint = .9, ...) {
#   
#   if(Type == "Curve"){
#     TargetStruct <- computeElasticPrincipalCurve(X = X, NumNodes = NumNodes,
#                                                  nReps = nReps, ProbPoint = ProbPoint,
#                                                  ...)
#   }
#   
#   if(Type == "Tree"){
#     TargetStruct <- computeElasticPrincipalTree(X = X, NumNodes = NumNodes,
#                                                  nReps = nReps, ProbPoint = ProbPoint,
#                                                  ...)
#   }
#   
#   if(Type == "Circle"){
#     TargetStruct <- computeElasticPrincipalCircle(X = X, NumNodes = NumNodes,
#                                                 nReps = nReps, ProbPoint = ProbPoint,
#                                                 ...)
#   }
#   
#   
#   
#   PointProj <- lapply(TargetStruct[1:nReps], function(TS){
#      project_point_onto_graph(X = X, NodePositions = TS$NodePositions,
#                                           Edges = TS$Edges$Edges, Partition = NULL)
#   })
#   
#   FVE <- sapply(TargetStruct[1:nReps], function(TS){
#     c(TS$FinalReport$FVEP, TS$FinalReport$FVE)
#   })
#   rownames(FVE) <- c("FVEP", "FVE")
#   
#   
#   
#   PCAData <- irlba::prcomp_irlba(x = X, n = 1, retx = FALSE)
#   PC1_FVE <- (PCAData$sdev^2)/sum(apply(X, 2, var))
#   
#   
#   
#   p <- ggplot2::ggplot(data = reshape::melt(data.frame(t(FVE))),
#                   mapping = ggplot2::aes(x = variable, y = value, fill = variable)) +
#     ggplot2::geom_boxplot() +
#     ggplot2::labs(y = "Fraction of explained variance", x = "Calculation mode") +
#     ggplot2::guides(fill = "none")
#     
#   p1 <- ggplot2::ggplot(data = reshape::melt(data.frame(t(FVE))),
#                        mapping = ggplot2::aes(x = variable, y = value/PC1_FVE, fill = variable)) +
#     # ggplot2::scale_y_log10() +
#     ggplot2::geom_boxplot() +
#     ggplot2::labs(y = "Ratio of fractions of explained variance (ElPiGr/PC1)", x = "Calculation mode")  +
#     ggplot2::guides(fill = "none")
#     
#   ggpubr::ggarrange(p, p1, ncol=2)
#   
#   if(nReps > 1){
#     PointProj <- project_point_onto_graph(X = X,
#                              NodePositions = TargetStruct[[nReps+1]]$NodePositions,
#                              Edges = TargetStruct[[nReps+1]]$Edges$Edges,
#                              Partition = NULL)
#   } else {
#     PointProj <- project_point_onto_graph(X = X,
#                              NodePositions = TargetStruct[[1]]$NodePositions,
#                              Edges = TargetStruct[[1]]$Edges$Edges,
#                              Partition = NULL)
#   }
#   
#   
#   
#   
#   
#   # 
#   # PointProj$
#   # 
#   # 
#   # 
#   # X_Corrected <- X - PointProj$X_projected
#   # Distances <- rowSums(X_Corrected^2)
#   # 
#   # 
#   # 
#   # var(PointProj$X_projected)/ sum(apply(X_Corrected, 2, var))
#   # 
#   # boxplot(Distances)
#   # boxplot(Distances ~ PointProj$EdgeID, las = 2)
#   
#   
#   
# }
# 
# 
# 
# 
# 
# 
# 
# 
# # 
# # 
# # 
# # ElPiROMA <- function(X) {
# #   
# # }
# # 
