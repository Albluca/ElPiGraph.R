# 
# StudyBranching <- function(X, TargetPG, GroupsLab = NULL, Partition = NULL, MaxNodes = Inf,
#                            nReps = 100, Prob = .9, PInf = 1, MaxNodeDist = 4, DiagPlot = FALSE){
# 
#   if(MaxNodeDist < 1){
#     stop(paste("MaxNodeDist must be at least 1"))
#   }
# 
#   Net <- rpgraph2::ConstructGraph(PrintGraph = TargetPG)
# 
#   AllBr <- rpgraph2::GetSubGraph(Net = Net, Structure = "branching")
#   AllBrId <- list()
#   InitNodesPos <- list()
#   InitEdgesMat <- list()
# 
#   print(paste(length(AllBr), "branched found"))
# 
#   BrVect <- rep("", nrow(TargetPG$NodePositions))
# 
#   for(i in 1:length(AllBr)){
# 
#     tNet <- igraph::induced.subgraph(graph = Net, vids = AllBr[[i]])
#     BrId <- as.integer(names(which(igraph::degree(tNet) > 2)))
# 
#     AllBr[[i]] <- as.integer(names(which(igraph::distances(tNet)[paste(BrId), ] <= MaxNodeDist)))
#     AllBrId[[i]] <- BrId
# 
#     InitNodesPos[[i]] <- TargetPG$NodePositions[c(BrId, as.integer(names(which(igraph::degree(tNet) == 1)))), ]
#     InitEdgesMat[[i]] <- cbind(1, 2:nrow(InitNodesPos[[i]]))
# 
#     TVevt <- BrVect[AllBr[[i]]]
#     TVevt[TVevt != ""] <- "Multi"
#     TVevt[TVevt == ""] <- paste("Br", i)
#     BrVect[AllBr[[i]]] <- TVevt
# 
#   }
# 
#   BrVect[BrVect == ""] <- "None"
# 
#   p <- PlotPG(X = X, TargetPG = TargetPG, GroupsLab = GroupsLab, PGCol = BrVect)
#   print(p)
# 
#   if(is.null(Partition)){
#     Partition <- rpgraph2::PartitionData(X, NodePositions = TargetPG$NodePositions, SquaredX = rowSums(X^2))$Partition
#   }
# 
#   PVVect.WT.FVE <- list()
#   PVVect.WT.FVEP <- list()
#   PVVect.TT.FVE <- list()
#   PVVect.TT.FVEP <- list()
# 
#   BinVect <- list()
# 
#   # PVVect.TT.FVE.Glob <- list()
#   # PVVect.TT.FVEP.Glob <- list()
#   # PVVect.WT.FVE.Glob <- list()
#   # PVVect.WT.FVEP.Glob <- list()
# 
#   for(i in 1:length(AllBr)){
#     SubX <- X[Partition %in% AllBr[[i]],]
# 
#     Trees <- list()
#     Curves <- list()
#     # GlobTree <- list()
# 
#     # TargetPG$ElasticMatrix[AllBr[[i]], AllBr[[i]]]
# 
#     for(j in 1:nReps){
# 
#       ToUse <- runif(nrow(SubX)) < Prob
# 
#       SampX <- SubX[ToUse,]
# 
#       if(sum(ToUse)>1){
#         Trees[[length(Trees)+1]] <- computeElasticPrincipalTree(X = SampX, NumNodes = length(AllBr[[i]])*PInf, ComputeMSEP = TRUE, Do_PCA = TRUE, CenterData = TRUE,
#                                                                 # verbose = FALSE, InitNodePositions = InitNodesPos[[i]], InitEdges = InitEdgesMat[[i]],
#                                                                 drawAccuracyComplexity = FALSE, drawPCAView = FALSE, drawEnergy = FALSE, nReps = 1, ProbPoint = 1)[[1]]
# 
#         Curves[[length(Curves)+1]] <- computeElasticPrincipalCurve(X = SampX, NumNodes = length(AllBr[[i]])*PInf,
#                                                                    NumEdges = nrow(Trees[[length(Trees)]]$Edges$Edges),
#                                                                    ComputeMSEP = TRUE, Do_PCA = TRUE, CenterData = TRUE,
#                                                                    # verbose = FALSE, InitNodePositions = InitNodesPos[[i]][1:2,],
#                                                                    InitEdges = matrix(InitEdgesMat[[i]][1,], nrow = 1),
#                                                                    drawAccuracyComplexity = FALSE, drawPCAView = FALSE, drawEnergy = FALSE, nReps = 1, ProbPoint = 1)[[1]]
# 
#         # GlobTree[[length(GlobTree)+1]] <- ReportOnPrimitiveGraphEmbedment(X = SampX, NodePositions = TargetPG$NodePositions[AllBr[[i]],], ElasticMatrix = TargetPG$ElasticMatrix[AllBr[[i]], AllBr[[i]]], ComputeMSEP = TRUE)
# 
#       }
# 
# 
#     }
# 
#     tBrVect <- rep("EPG", length(BrVect))
#     tBrVect[AllBr[[i]]] <- paste("Branching", i)
# 
# 
#     if(DiagPlot){
# 
#       p <- PlotPG(X, TargetPG = TargetPG, BootPG = Curves[1:nReps], PGCol = tBrVect)
#       print(p)
# 
#       tTargetPG <- TargetPG
#       tTargetPG$NodePositions <- tTargetPG$NodePositions[sort(AllBr[[i]]), ]
# 
#       EdgeMat <- tTargetPG$Edges$Edges
#       tTargetPG$Edges$Edges <- EdgeMat[apply(apply(EdgeMat, 1, "%in%", AllBr[[i]]), 2, all), ]
# 
#       EdgeMat <- tTargetPG$Edges$Edges
#       Recode <- 1:length(unique(as.vector(EdgeMat)))
#       names(Recode) <- sort(unique(as.vector(EdgeMat)))
#       EdgeMat <- matrix(Recode[paste(EdgeMat)], ncol = 2)
# 
#       tTargetPG$Edges$Edges <- EdgeMat
# 
#       p <- PlotPG(SubX, TargetPG = tTargetPG, BootPG = Curves[1:nReps], PGCol = paste("Branching", i))
#       print(p)
# 
#     }
# 
# 
# 
# 
# 
#     # SubXSq <- rowSums(SubX^2)
#     #
#     # Dists_Cur <- lapply(1:nReps, function(j){
#     #   PartitionData(X = SubX, NodePositions = Curves[[j]]$NodePositions, SquaredX = SubXSq, TrimmingRadius = Inf, nCores = 1)$Dist
#     # })
#     #
#     # Dists_Tre <- lapply(1:nReps, function(j){
#     #   PartitionData(X = SubX, NodePositions = Trees[[j]]$NodePositions, SquaredX = SubXSq, TrimmingRadius = Inf, nCores = 1)$Dist
#     # })
#     #
#     # boxplot(list(sapply(Dists_Cur, mean), sapply(Dists_Tre, mean)))
# 
# 
# 
# 
#     # PlotPG(SubX, TargetPG = Trees[[nReps+1]], BootPG = Curves[1:nReps])
# 
# 
#     CurveData.FVE <- sapply(
#       lapply(Curves[1:nReps], "[[", "FinalReport"),
#       "[[", "FVE")
# 
#     TreeData.FVE <- sapply(
#       lapply(Trees[1:nReps], "[[", "FinalReport"),
#       "[[", "FVE")
# 
#     # TreeData.FVE.Global <- sapply(GlobTree[1:nReps], "[[", "FVE")
# 
#     CurveData.FVEP <- sapply(
#       lapply(Curves[1:nReps], "[[", "FinalReport"),
#       "[[", "FVEP")
# 
#     TreeData.FVEP <- sapply(
#       lapply(Trees[1:nReps], "[[", "FinalReport"),
#       "[[", "FVEP")
# 
#     # TreeData.FVEP.Global <- sapply(GlobTree[1:nReps], "[[", "FVEP")
# 
#     PVVect.WT.FVE[[i]] <- wilcox.test(CurveData.FVE, TreeData.FVE)
#     PVVect.WT.FVEP[[i]] <- wilcox.test(CurveData.FVEP, TreeData.FVEP)
#     PVVect.TT.FVE[[i]] <- t.test(CurveData.FVE, TreeData.FVE)
#     PVVect.TT.FVEP[[i]] <- t.test(CurveData.FVEP, TreeData.FVEP)
# 
#     # PVVect.TT.FVE.Glob[[i]] <- t.test(CurveData.FVE, TreeData.FVE.Global)
#     # PVVect.TT.FVEP.Glob[[i]] <- t.test(CurveData.FVEP, -TreeData.FVEP.Global)
#     # PVVect.WT.FVE.Glob[[i]] <- wilcox.test(CurveData.FVE, TreeData.FVE.Global)
#     # PVVect.WT.FVEP.Glob[[i]] <- wilcox.test(CurveData.FVEP, -TreeData.FVEP.Global)
# 
# 
#     BinVect[[i]] <- c(FVE = sum(TreeData.FVE > CurveData.FVE)/length(TreeData.FVE),
#                       FVEP = sum(TreeData.FVEP > CurveData.FVEP)/length(TreeData.FVEP),
#                       Median.Dif.FVE = median(TreeData.FVE-CurveData.FVE),
#                       Median.Dif.FVEP = median(TreeData.FVEP-CurveData.FVEP),
#                       Median.Rat.FVE = median(TreeData.FVE/CurveData.FVE),
#                       Median.Rat.FVEP = median(TreeData.FVEP/CurveData.FVEP)
#                       )
# 
#     par(mfcol = c(1,4))
# 
#     boxplot(list(Curve=CurveData.FVE, Tree=TreeData.FVE), main=paste(i, "of", length(AllBr)), ylab="FVE", las=2, at=c(1,2))
#     # text(x=1.5, y = mean(c(CurveData.FVE, TreeData.FVE)), labels = paste("t test pv =", signif(PVVect.TT.FVE[[i]]$p.value, 3),
#     #                                                                      "wil test pv =", signif(PVVect.WT.FVE[[i]]$p.value, 3)),
#     #      srt = 90, cex = 2)
# 
#     boxplot(list(Curve=CurveData.FVEP, Tree=TreeData.FVEP), main=paste(i, "of", length(AllBr)), ylab="FVEP", las=2)
#     # text(x=1.5, y = mean(c(CurveData.FVEP, TreeData.FVEP)), labels = paste("t test pv =", signif(PVVect.TT.FVEP[[i]]$p.value, 3),
#     #                                                                      "wil test pv =", signif(PVVect.WT.FVEP[[i]]$p.value, 3)),
#     #      srt = 90, cex = 2)
# 
#     # boxplot(list(Curve=CurveData.FVEP, Tree.Glob=TreeData.FVEP.Global), main=paste(i, "of", length(AllBr)), ylab="FVEP", las=2)
#     # text(x=1.5, y = mean(c(CurveData.FVEP, TreeData.FVEP.Global)), labels = paste("t test pv =", signif(PVVect.TT.FVEP.Glob[[i]]$p.value, 3),
#     #                                                                        "wil test pv =", signif(PVVect.WT.FVEP.Glob[[i]]$p.value, 3)),
#     #      srt = 90, cex = 2)
#     #
#     #
#     # boxplot(list(Curve=CurveData.FVE, Tree.Glob=TreeData.FVE.Global), main=paste(i, "of", length(AllBr)), ylab="FVE", las=2)
#     # text(x=1.5, y = mean(c(CurveData.FVE, TreeData.FVE.Global)), labels = paste("t test pv =", signif(PVVect.TT.FVE.Glob[[i]]$p.value, 3),
#     #                                                                               "wil test pv =", signif(PVVect.WT.FVE.Glob[[i]]$p.value, 3)),
#     #      srt = 90, cex = 2)
# 
# 
# 
#     boxplot(list(FVE = TreeData.FVE-CurveData.FVE, FVEP = TreeData.FVEP-CurveData.FVEP), main=paste(i, "of", length(AllBr)),
#             ylab = "Difference (Tree - Curve)", las=2)
#     abline(h=0)
# 
# 
#     boxplot(list(FVE = log2(TreeData.FVE/CurveData.FVE), FVEP = log2(TreeData.FVEP/CurveData.FVEP)), main=paste(i, "of", length(AllBr)),
#             ylab = "Log2 Ratio (Tree / Curve)", las=2)
#     abline(h=0)
# 
# 
#     par(mfcol = c(1,1))
# 
#   }
# 
#   return(list(
#     PVVect.WT.FVE = PVVect.WT.FVE, PVVect.WT.FVEP = PVVect.WT.FVEP,
#     PVVect.TT.FVE = PVVect.TT.FVE, PVVect.TT.FVEP = PVVect.TT.FVEP,
#     BinVect = BinVect, Branches = AllBr, BranchingPoints = AllBrId
#       # PVVect.TT.FVE.Glob = PVVect.TT.FVE.Glob, PVVect.TT.FVEP.Glob = PVVect.TT.FVEP.Glob,
#       # PVVect.WT.FVE.Glob = PVVect.WT.FVE.Glob, PVVect.WT.FVEP.Glob = PVVect.WT.FVEP.Glob
#     )
#   )
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
# 
# 
# 
# 
# 
# 
# #
# #
# # ExploreLocalVariance <- function(X, TargetPG, Squares = c(20, 20), GroupsLab = NULL){
# #
# #   # Get projections
# #   PartData <- rpgraph2::PartitionData(X = X, NodePositions = TargetPG$NodePositions,
# #                                        SquaredX = rowSums(X^2))
# #
# #   PrjVal <- rpgraph2::project_point_onto_graph(X = X, NodePositions = TargetPG$NodePositions,
# #                                                Edges = TargetPG$Edges$Edges,
# #                                                Partition = PartData$Partition)
# #
# #   # Get projection plane and rotate data
# #
# #   CombPCA <- irlba::prcomp_irlba(TargetPG$NodePositions, n = 2, retx = TRUE, center = TRUE)
# #
# #   BaseData <- t(t(X) - CombPCA$center) %*% CombPCA$rotation
# #
# #   # Construct the grid
# #
# #   XSeps <- seq(from=min(BaseData[,1]) - sign(min(BaseData[,1]))*min(BaseData[,1])*0.01,
# #                to=max(BaseData[,1]) + sign(max(BaseData[,1]))*max(BaseData[,1])*0.01,
# #                length.out = Squares[1])
# #   YSeps <- seq(from=min(BaseData[,2]) - sign(min(BaseData[,2]))*min(BaseData[,2])*0.01,
# #                to=max(BaseData[,2]) + sign(max(BaseData[,2]))*max(BaseData[,2])*0.01,
# #                length.out = Squares[2])
# #
# #   IdxMat <- matrix(1:prod(Squares), nrow = Squares[1])
# #
# #   XCut <- as.integer(cut(BaseData[,1], breaks = XSeps))
# #   YCut <- as.integer(cut(BaseData[,2], breaks = YSeps))
# #   PointsAssociation <- sapply(1:length(XCut), function(i){IdxMat[XCut[i], YCut[i]]})
# #
# #
# #   XCut <- as.integer(cut(CombPCA$x[,1], breaks = XSeps))
# #   YCut <- as.integer(cut(CombPCA$x[,2], breaks = YSeps))
# #   NodesAssociation <- sapply(1:length(XCut), function(i){IdxMat[XCut[i], YCut[i]]})
# #
# #   RotProj <- t(t(PrjVal$X_projected) - CombPCA$center) %*% CombPCA$rotation
# #
# #   XCut <- as.integer(cut(RotProj[,1], breaks = XSeps))
# #   YCut <- as.integer(cut(RotProj[,2], breaks = YSeps))
# #   ProjAssociation <- sapply(1:length(XCut), function(i){IdxMat[XCut[i], YCut[i]]})
# #
# #   GetVar <- function(SqId) {
# #     # SelNodes_byPoints <- PartData$Partition[SelPointIds]
# #     Selnodes_bySquare <- which(NodesAssociation %in% SqId)
# #
# #     SelPointIds <- which(PartData$Partition %in% Selnodes_bySquare & PointsAssociation %in% SqId)
# #
# #     if(length(SelPointIds)){
# #       PVar <- sum(apply(matrix(X[SelPointIds, ], nrow = length(SelPointIds)), 1, var))
# #       Nvar <- mean(PartData$Dists[SelPointIds])
# #       FEV <- (PVar - Nvar)/PVar
# #     } else {
# #       FEV <- NA
# #     }
# #
# #     Selporj_bySquare <- which(ProjAssociation %in% SqId)
# #     SelPointIds <- Selporj_bySquare[PointsAssociation[Selporj_bySquare] %in% SqId]
# #
# #     if(length(SelPointIds)){
# #       PVar <- sum(apply(matrix(X[SelPointIds, ], nrow = length(SelPointIds)), 1, var))
# #       Rvar <- mean(
# #         rowSums(
# #           (matrix(X[SelPointIds, ], nrow = length(SelPointIds)) -
# #             matrix(PrjVal$X_projected[SelPointIds,], nrow = length(SelPointIds)))^2
# #           )
# #       )
# #       FEVP <- (PVar - Rvar)/PVar
# #     } else {
# #       FEVP <- NA
# #     }
# #
# #     return(c(FEV = FEV, FEVP = FEVP))
# #
# #   }
# #
# #   VE <- sapply(as.vector(IdxMat), GetVar)
# #
# #
# #
# #   image(matrix(VE[1,], nrow = Squares[1]), col = heat.colors(10))
# #
# #   image(matrix(VE[2,], nrow = Squares[1]), col = heat.colors(10))
# #
# #
# #
# #
# #   # Net <- rpgraph2::ConstructGraph(PrintGraph = TargetPG)
# #   #
# #   # AllBr <- rpgraph2::GetSubGraph(Net = Net, Structure = "branching")
# #   # InitNodesPos <- list()
# #   # InitEdgesMat <- list()
# #   #
# #   # print(paste(length(AllBr), "branched found"))
# #   #
# #   # BrVect <- rep("", nrow(TargetPG$NodePositions))
# #   #
# #   # for(i in 1:length(AllBr)){
# #   #
# #   #   tNet <- igraph::induced.subgraph(graph = Net, vids = AllBr[[i]])
# #   #   BrId <- as.integer(names(which(igraph::degree(tNet) > 2)))
# #   #
# #   #   AllBr[[i]] <- as.integer(names(which(igraph::distances(tNet)[paste(BrId), ] <= MaxNodeDist)))
# #   #
# #   #   InitNodesPos[[i]] <- TargetPG$NodePositions[c(BrId, as.integer(names(which(igraph::degree(tNet) == 1)))), ]
# #   #   InitEdgesMat[[i]] <- cbind(1, 2:nrow(InitNodesPos[[i]]))
# #   #
# #   #   TVevt <- BrVect[AllBr[[i]]]
# #   #   TVevt[TVevt != ""] <- "Multi"
# #   #   TVevt[TVevt == ""] <- paste("Br", i)
# #   #   BrVect[AllBr[[i]]] <- TVevt
# #   #
# #   # }
# #   #
# #   # BrVect[BrVect == ""] <- "None"
# #   #
# #   # PlotPG(X = X, TargetPG = TargetPG, GroupsLab = GroupsLab, PGCol = BrVect)
# #   #
# #   #
# #   #
# #   #
# #   # PVVect.FVE <- list()
# #   # PVVect.FVEP <- list()
# #   # BinVect <- list()
# #   #
# #   # for(i in 1:length(AllBr)){
# #   #   SubX <- X[Partition %in% AllBr[[i]],]
# #   #
# #   #   Trees <- list()
# #   #   Curves <- list()
# #   #
# #   #   for(j in 1:nReps){
# #   #
# #   #     SampX <- SubX[runif(nrow(SubX)) < Prob,]
# #   #
# #   #     Trees[[length(Trees)+1]] <- computeElasticPrincipalTree(X = SampX, NumNodes = length(AllBr[[i]])*PInf, ComputeMSEP = TRUE, Do_PCA = TRUE, CenterData = TRUE,
# #   #                                                             # verbose = FALSE, InitNodePositions = InitNodesPos[[i]], InitEdges = InitEdgesMat[[i]],
# #   #                                                             drawAccuracyComplexity = FALSE, drawPCAView = FALSE, drawEnergy = FALSE, nReps = 1, ProbPoint = 1)[[1]]
# #   #
# #   #     Curves[[length(Curves)+1]] <- computeElasticPrincipalCurve(X = SampX, NumNodes = length(AllBr[[i]])*PInf, ComputeMSEP = TRUE, Do_PCA = TRUE, CenterData = TRUE,
# #   #                                                                # verbose = FALSE, InitNodePositions = InitNodesPos[[i]][1:2,],
# #   #                                                                InitEdges = matrix(InitEdgesMat[[i]][1,], nrow = 1),
# #   #                                                                drawAccuracyComplexity = FALSE, drawPCAView = FALSE, drawEnergy = FALSE, nReps = 1, ProbPoint = 1)[[1]]
# #   #   }
# #   #
# #   #   tBrVect <- rep("EPG", length(BrVect))
# #   #   tBrVect[AllBr[[i]]] <- paste("Branching", i)
# #   #
# #   #   PlotPG(X, TargetPG = TargetPG, BootPG = Curves[1:nReps], PGCol = tBrVect)
# #   #
# #   #   tTargetPG <- TargetPG
# #   #   tTargetPG$NodePositions <- tTargetPG$NodePositions[sort(AllBr[[i]]), ]
# #   #
# #   #   EdgeMat <- tTargetPG$Edges$Edges
# #   #   tTargetPG$Edges$Edges <- EdgeMat[apply(apply(EdgeMat, 1, "%in%", AllBr[[i]]), 2, all), ]
# #   #
# #   #   EdgeMat <- tTargetPG$Edges$Edges
# #   #   Recode <- 1:length(unique(as.vector(EdgeMat)))
# #   #   names(Recode) <- sort(unique(as.vector(EdgeMat)))
# #   #   EdgeMat <- matrix(Recode[paste(EdgeMat)], ncol = 2)
# #   #
# #   #   tTargetPG$Edges$Edges <- EdgeMat
# #   #
# #   #   PlotPG(SubX, TargetPG = tTargetPG, BootPG = Curves[1:nReps], PGCol = paste("Branching", i))
# #   #
# #   #   # SubXSq <- rowSums(SubX^2)
# #   #   #
# #   #   # Dists_Cur <- lapply(1:nReps, function(j){
# #   #   #   PartitionData(X = SubX, NodePositions = Curves[[j]]$NodePositions, SquaredX = SubXSq, TrimmingRadius = Inf, nCores = 1)$Dist
# #   #   # })
# #   #   #
# #   #   # Dists_Tre <- lapply(1:nReps, function(j){
# #   #   #   PartitionData(X = SubX, NodePositions = Trees[[j]]$NodePositions, SquaredX = SubXSq, TrimmingRadius = Inf, nCores = 1)$Dist
# #   #   # })
# #   #   #
# #   #   # boxplot(list(sapply(Dists_Cur, mean), sapply(Dists_Tre, mean)))
# #   #
# #   #
# #   #
# #   #
# #   #   # PlotPG(SubX, TargetPG = Trees[[nReps+1]], BootPG = Curves[1:nReps])
# #   #
# #   #
# #   #   CurveData.FVE <- sapply(
# #   #     lapply(Curves[1:nReps], "[[", "FinalReport"),
# #   #     "[[", "FVE")
# #   #
# #   #   TreeData.FVE <- sapply(
# #   #     lapply(Trees[1:nReps], "[[", "FinalReport"),
# #   #     "[[", "FVE")
# #   #
# #   #   CurveData.FVEP <- sapply(
# #   #     lapply(Curves[1:nReps], "[[", "FinalReport"),
# #   #     "[[", "FVEP")
# #   #
# #   #   TreeData.FVEP <- sapply(
# #   #     lapply(Trees[1:nReps], "[[", "FinalReport"),
# #   #     "[[", "FVEP")
# #   #
# #   #   PVVect.FVE[[i]] <- wilcox.test(CurveData.FVE, TreeData.FVE)
# #   #   PVVect.FVEP[[i]] <- wilcox.test(CurveData.FVEP, TreeData.FVEP)
# #   #   BinVect[[i]] <- c(FVE = sum(TreeData.FVE > CurveData.FVE)/length(TreeData.FVE),
# #   #                     FVEP = sum(TreeData.FVEP > CurveData.FVEP)/length(TreeData.FVEP))
# #   #
# #   #   par(mfcol = c(1,4))
# #   #   boxplot(list(Curve=CurveData.FVE, Tree=TreeData.FVE), main=paste(i, "of", length(AllBr)), ylab="FVE", las=2)
# #   #   boxplot(list(Curve=CurveData.FVEP, Tree=TreeData.FVEP), main=paste(i, "of", length(AllBr)), ylab="FVEP", las=2)
# #   #   boxplot(list(FVE=TreeData.FVE/CurveData.FVE, FVEP=TreeData.FVEP/CurveData.FVEP), main=paste(i, "of", length(AllBr)),
# #   #           ylab="Ratio", las=2)
# #   #   boxplot(list(FVE=TreeData.FVE-CurveData.FVE, FVEP=TreeData.FVEP-CurveData.FVEP), main=paste(i, "of", length(AllBr)),
# #   #           ylab="Difference", las=2)
# #   #   par(mfcol = c(1,1))
# #   #
# #   # }
# #   #
# #   # return(list(PVVect.FVE = PVVect.FVE, PVVect.FVEP = PVVect.FVEP))
# #
# # }
# #
# #
# #
# #
# # #
# # #
# # #
# # # Moving
# # #
# # #
# 
# 
# 
# 
# 
# NodeDimensionality <- function(X, TargetPG, Partition = NULL, MaxNodeDist = 4, nReps = 100, Prob = .9){
# 
#   Net <- rpgraph2::ConstructGraph(PrintGraph = TargetPG)
# 
#   if(is.null(Partition)){
#     Partition <- rpgraph2::PartitionData(X, NodePositions = TargetPG$NodePositions, SquaredX = rowSums(X^2))$Partition
#   }
# 
# 
#   GetStats <- function(i) {
#     Idx = as.numeric(igraph::neighborhood(graph = Net, order = MaxNodeDist, nodes = paste(i))[[1]])
# 
#     SubX <- matrix(X[Partition %in% Idx, ], ncol = ncol(X))
# 
#     if(nrow(SubX) < 3){
#       return(c(L1 = NA, L1oL2 = NA))
#     }
# 
#     VarData <- NULL
# 
#     for(j in 1:nReps){
#       SubX.Samp <- matrix(SubX[runif(nrow(SubX)) < Prob, ], ncol = ncol(SubX))
# 
#       if(nrow(SubX.Samp) < 3){
#         return(c(L1 = NA, L1oL2 = NA))
#       }
# 
#       PCAData <- suppressWarnings(irlba::prcomp_irlba(SubX.Samp, n = 2, center = TRUE, scale. = FALSE))
#       VarVect <- (PCAData$sdev^2)/sum(apply(SubX.Samp, 2, var))
# 
#       VarData <- rbind(VarData, c(L1 = VarVect[1], L1oL2 = VarVect[1]/VarVect[2]))
#     }
# 
#     apply(VarData, 2, median, na.rm = TRUE)
#   }
# 
#   t(sapply(1:nrow(TargetPG$NodePositions), GetStats))
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
# 
# 
# 
# 
# ExploreBranching <- function(X, TargetPG, GroupsLab = NULL, Partition = NULL, MaxNodes = Inf,
#                           nReps = 100, Prob = .9, PInf = 1, MaxNodeDist = 2, LabMult=.5) {
#   
#   tictoc::tic()
#   Stats_1 <- StudyBranching(X = X, TargetPG = TargetPG, MaxNodeDist = MaxNodeDist, nReps = nReps, Prob = Prob)
#   
#   Stats_2 <- NodeDimensionality(X = X, TargetPG = TargetPG, MaxNodeDist = MaxNodeDist, nReps = nReps, Prob = Prob)
#   tictoc::toc()
#   
#   p1 <- PlotPG(X = X, TargetPG = PG1a[[length(PG1a)]], PGCol = "EpG", PlotProjections = "none", GroupsLab = GroupsLab,
#          PointViz = "points", PointSize = Stats_2[,1], Main = paste("Nei =", MaxNodeDist, "/ PointSize = L1"))
#   p2 <- PlotPG(X = X, TargetPG = PG1a[[length(PG1a)]], PGCol = "EpG", PlotProjections = "none", GroupsLab = GroupsLab,
#          PointViz = "points", PointSize = log2(Stats_2[,2]), Main = paste("Nei =", MaxNodeDist, "/PointSize = log2(L1/L2)"))
#   
#   p3 <- cowplot::plot_grid(p1, p2, ncol = 1)
#   
#   plot(p3)
#   
#   BrPoints <- lapply(Stats_1$Branches, function(x){
#     igraph::induced.subgraph(graph = ConstructGraph(PrintGraph = PG1a[[length(PG1a)]]), vids = x)
#   }) %>%
#     lapply(., igraph::degree) %>%
#     lapply(., function(x){which(x>2)}) %>%
#     lapply(., names) %>%
#     unlist
#   
#   
#   # Info <- lapply(1:length(Stats_1$BranchingPoints), function(i){
#   #   if(!(Stats_1$BranchingPoints[[i]] %in% Stats_1$Branches[[i]])){
#   #     stop("Inconsistent branching information")
#   #   } else {
#   #     t(Stats_2[setdiff(Stats_1$Branches[[i]], Stats_1$BranchingPoints[[i]]), ]) - Stats_2[Stats_1$BranchingPoints[[i]], ]
#   #   }
#   #   
#   # })
#   
#   par(mfcol=c(1,2))
#   
#   boxplot(Stats_2[- unlist(Stats_1$BranchingPoints), 1], at = 1, ylab = "L1")
#   points(x=rep(1, length(Stats_1$BranchingPoints)),
#          Stats_2[unlist(Stats_1$BranchingPoints), 1], pch = 20, col="red")
#   
#   boxplot(Stats_2[- unlist(Stats_1$BranchingPoints), 2], at = 1, ylab = "L1/L2")
#   points(x=rep(1, length(Stats_1$BranchingPoints)),
#          Stats_2[unlist(Stats_1$BranchingPoints), 2], pch = 20, col="red")
#   
#   par(mfcol=c(1,1))
#   
#   
#   MadFormData <- apply(Stats_2[-unlist(Stats_1$BranchingPoints), ], 2, mad, na.rm = TRUE)
#   MedianFromData <- apply(Stats_2[-unlist(Stats_1$BranchingPoints), ], 2, median, na.rm = TRUE)
#   
#   
#   MadAway <- (t(Stats_2[unlist(Stats_1$BranchingPoints), ]) - MedianFromData)/MadFormData
#   
#   
#   Data.fr <- data.frame(id =1:length(Stats_1$BinVect),
#                         do.call(rbind, Stats_1$BinVect)[,-c(1:2)],
#                         t(MadAway))
#   
#   NodeLabels <- rep(NA, nrow(TargetPG$NodePositions))
#   NodeLabels[unlist(Stats_1$BranchingPoints)] <- 1:length(Stats_1$BranchingPoints)
#   
#   
#   p1 <- PlotPG(X = X, TargetPG = PG1a[[length(PG1a)]], PGCol = "EpG", PlotProjections = "none", GroupsLab = GroupsLab,
#          PointViz = "points", PointSize = NULL, Main = paste("Nei =", MaxNodeDist, "/ PointSize = L1"),
#          NodeLabels = NodeLabels, LabMult = LabMult)
#   
#   p2 <- ggplot2::ggplot(Data.fr, ggplot2::aes(x = Median.Dif.FVEP, y = L1, label = id)) +
#     ggplot2::geom_text(check_overlap = TRUE) + 
#     ggplot2::geom_hline(yintercept = 0, linetype = "dotted") + 
#     ggplot2::geom_hline(yintercept = -1, linetype = "dotted") +
#     ggplot2::labs(y = "MAD away from the median of L1", x = "Median difference (Tree-Curve) of FEVP")
#   
#   p3 <- cowplot::plot_grid(p1, p2, ncol = 1)
#   
#   print(p3)
#   
#   # plot(Data.fr$Median.Dif.FVEP, Data.fr$L1, type = "n")
#   # text(Data.fr$Median.Dif.FVEP, Data.fr$L1, Data.fr$id)
#   # abline(h=c(0, -1))
#   
#   # library(GGally)
#   # ggpairs(Data.fr, columns = 2:7, mapping = ggplot2::aes(color = id))
#   # ggpairs(Data.fr, columns = 2:7)
#   
#   return(list(NodesID = Stats_1$Branches, CombInfo = Data.fr))
#   
# }
# 
# 
# 





#' Produce a multidimensional dimension matrix
#'
#' @param X a data matrix
#' @param PrintGraph an ElPiGraph object
#' @param Start the Starting node. If NULL (the default), a random end point will be selected
#'
#' @return a list with two elements
#' \itemize{
#'  \item Branches, a list containing the (ordered) nodes composing the different branches
#'  \item DimMatrix, a matrix contianing the normalized position of points acoross branches. The columns
#'  correpsond to the different branches definezd by Branches. If a points is not assigned to a branch NA is reported.
#' }
#' @export
#'
#' @examples
BranchingDimension <- function(X, PrintGraph, Start = NULL) {
 
  # Define supporting structures
  Net <- ElPiGraph.R::ConstructGraph(PrintGraph = PrintGraph)
  ProjStruct <- project_point_onto_graph(X = X, NodePositions = PrintGraph$NodePositions, Edges = PrintGraph$Edges$Edges)
  
  # Fix starting point if needed
  if(is.null(Start)){
    Start <- sample(which(igraph::degree(Net)==1), 1)
  }
  
  # Get the branches
  AllBr <- GetSubGraph(Net = Net, Structure = 'branches')
  FixedBr <- list()
  
  RetStruct <- matrix(NA, nrow = nrow(X), ncol = length(AllBr))
  colnames(RetStruct) <- names(AllBr)
  
  for(i in 1:length(AllBr)){
    
    Paths <- igraph::get.shortest.paths(graph = Net, from = Start,
                                        to = names(AllBr[[i]][c(1, length(AllBr[[i]]))]))$vpath
    
    if( length(Paths[[1]]) < length(Paths[[2]]) ){
      FixedBr[[i]] <- AllBr[[i]]
    } else {
      FixedBr[[i]] <- rev(AllBr[[i]])
    }
    Pt <- getPseudotime(ProjStruct = ProjStruct, NodeSeq = FixedBr[[i]])

    RetStruct[which(!is.na(Pt$Pt)), i] <- Pt$Pt[!is.na(Pt$Pt)]/Pt$PathLen
    
  }
  
  return(list(Branches = FixedBr, DimMatrix = RetStruct))
   
}



