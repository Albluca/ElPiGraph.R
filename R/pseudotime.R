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









#' Compare feature values over different branches
#'
#' @param X the data matrix, note that features must be names, i.e. column names must be non-empty
#' @param Paths a list of paths used to construct the pseudotime. Note that the beginning of the pseudotime
#' will be placed in correspondence of the fisrst node for each path. Hence the comparison is meaningfull
#' only if all the path begin from the same node (Although, this will not be enforced by the function) 
#' @param TargetPG the ElPiGraph structure to be used
#' @param Partition A partition vactor attributing each point to at most one node
#' @param PrjStr A projecturion structure, as produced by project_point_onto_graph
#' @param Main string, the main title of the plot
#' @param Features either a string vector or a positive integer. If a string vector, it will be interpreted as
#' the name of the features to plot (matched to the colnames of X). If positive integer, it will be interpreted
#' as the number of the topmost interesting features according to the metric specified by Mode
#' @param ylab string, the label of the y axis
#' @param alpha numeric between 0 and 1, the trasparency of the points
#' @param ScalePT boolean, should the pseudotime be normalized across the branches?
#' @param Mode string, the feature seletion mode used to determine the most interesting genes. It can be
#'  \itemize{
#'  \item{'Var'}{ The genes with the largest variance across the points associated to the paths}
#'  \item{'Fano'}{ The genes with the largest Fano factor (variance over mean) across the points associated to the paths}
#'  \item{'Mad'}{ The genes with the largest median absolute deviation across the points associated to the paths}
#'  \item{'Mad/Median'}{ The genes with the largest ratio of median absolute deviation to median across the points associated to the paths}
#'  \item{'MI'}{ The genes with the largest mutual information (across all the paths)}
#'  \item{'MI.DB'}{ The genes with the largest mutual inforlation (across differential paths)}
#'  \item{'KW'}{ The genes with the largest difference, as computed by the Kruskal-Wallis test (across differential paths)}
#'  \item{'Cor.DB'}{ The genes whose product of Spearman correlation (w.r.t. the pseudotime ordering) is the largest}
#' }
#' @param Log boolean, should a log scale be used on the y axis
#' @param BootPG if not NULL, a list of resampled ElPiGraph structures that will be used to compute confidence intervals
#' @param GroupsLab character of factor, category information for the cells present in the matrix.
#' @param TrajCol boolean, should the points be colored by trajectory? If FALSE GroupsLab will be used.
#' @param Conf the confidence level.
#' @param AllBP boolean. If TRUE, the confidence level be displayed for all the branching points present on the selected branches.
#' If FALSE, the confidence level will be displayed only for the branching points 
#' @param facet_rows integer, the number of rows per panel
#' @param facet_cols integer, the number of cols per panel
#' @param Span the span parameter of the loess fitter
#' @param PlotOrg boolean, should the original gene expression be reported. If false oly the smooth will be plotted.
#' @param ModePar additional parameters for the feature selection mode used
#' @param n.cores integer, the number of parallel processes to use.
#' @param ClusType string, the type of cluster to use if n.cores is larger than 1
#' @param ReturnGenes boolean, should the list of genes be returned instead of the plots?
#' @param OnlyIsomorphicBoot boolean. If TRUE only reampled ElPiGraph structures with the same number of branching points of the target
#' structure will be used to compute confidence intervals. If FALSE, all of the structures will be used.
#' @param TrimmingRadius numeric, the trimming radius used to project the position of the branching points of the resampled trees on the
#' pseudotime
#'
#' @return
#' @export
#'
#' @examples
CompareOnBranches <- function(X,
                              Paths,
                              TargetPG,
                              BootPG = NULL,
                              OnlyIsomorphicBoot = TRUE,
                              GroupsLab = NULL,
                              PlotOrg = TRUE,
                              TrajCol = FALSE,
                              Conf = .95,
                              AllBP = FALSE,
                              TrimmingRadius = Inf,
                              Partition,
                              PrjStr,
                              Main = "",
                              ylab = "Feature value",
                              alpha = .3,
                              ScalePT = FALSE,
                              Features = 4,
                              facet_rows = 3,
                              facet_cols = 3,
                              Mode = "Var",
                              ModePar = NULL,
                              Log = FALSE,
                              Span = .1,
                              n.cores = 1,
                              ClusType = "SOCK",
                              ReturnGenes = FALSE) {
  
  if(is.null(GroupsLab)){
    GroupsLab = factor(rep("N/A", nrow(X)))
  }
  
  if(is.null(names(GroupsLab))){
    names(GroupsLab) = rownames(X)
  }
  
  CombDF <- NULL
  
  if(is.numeric(Features) & (Mode == "Var" | Mode == "Fano")){
    
    SharedPath <- unique(unlist(Paths, use.names = FALSE))
    tX <- X[Partition %in% as.integer(SharedPath), ]
    
    if(n.cores == 1){
      GenesByVar <- apply(tX, 2, var)
    } else {
      if(ClusType == "FORK"){
        cl <- parallel::makeForkCluster(n.cores)
        GenesByVar <- parallel::parApply(cl, tX, 2, var)
      } else {
        cl <- parallel::makePSOCKcluster(n.cores)
        parallel::clusterExport(cl, "tX")
        GenesByVar <- parallel::parApply(cl, tX, 2, var)
      }
      parallel::stopCluster(cl)
    }
    
    if(length(GenesByVar) <= Features){
      Features = length(GenesByVar)
    }
    
    if(Mode == "Fano"){
      print("Feature selection by Fano factor")
      GenesByVar <- GenesByVar/colMeans(tX)
      if(any(!is.finite(GenesByVar))){
        GenesByVar[!is.finite(GenesByVar)] <- 0
      }
    } else {
      print("Feature selection by variance")
    }
    
    if(ReturnGenes){
      return(sort(GenesByVar, decreasing = TRUE))
    }
    
    Features <- names(sort(GenesByVar, decreasing = TRUE))[1:Features]
    
  }
  
  if(is.numeric(Features) & (Mode == "Mad" | Mode == "Mad/Median")){
    
    SharedPath <- unique(unlist(Paths, use.names = FALSE))
    tX <- X[Partition %in% as.integer(SharedPath), ]
    
    if(n.cores == 1){
      GenesByVar <- apply(tX, 2, mad)
    } else {
      if(ClusType == "FORK"){
        cl <- parallel::makeForkCluster(n.cores)
        GenesByVar <- parallel::parApply(cl, tX, 2, mad)
      } else {
        cl <- parallel::makePSOCKcluster(n.cores)
        parallel::clusterExport(cl, "tX")
        GenesByVar <- parallel::parApply(cl, tX, 2, mad)
      }
      parallel::stopCluster(cl)
    }
    
    if(length(GenesByVar) <= Features){
      Features = length(GenesByVar)
    }
    
    if(Mode == "Mad/Median"){
      
      print("Feature selection by Mad / Median")
      
      GenesByVar <- GenesByVar/apply(tX, 2, median)
      if(any(!is.finite(GenesByVar))){
        GenesByVar[!is.finite(GenesByVar)] <- 0
      }
      
    } else {
      print("Feature selection by Mad")
    }
    
    if(ReturnGenes){
      return(sort(GenesByVar, decreasing = TRUE))
    }
    
    Features <- names(sort(GenesByVar, decreasing = TRUE))[1:Features]
    
  }
  
  if(is.numeric(Features) & Mode == "MI"){
    
    print("Feature selection by mutual information")
    
    Path_MI <- sapply(Paths, function(x){
      PtOnPath <- getPseudotime(ProjStruct = PrjStr, NodeSeq = x)
      
      PtVect <- PtOnPath$Pt
      Seleced <- !is.na(PtVect)
      
      FactoredPT <- factor(PtVect[Seleced])
      
      if(n.cores == 1){
        AllMI <- sapply(1:ncol(X), function(j) {
          infotheo::mutinformation(X = factor(X[Seleced,j]), FactoredPT)
        })
      } else {
        if(ClusType == "FORK"){
          cl <- parallel::makeForkCluster(n.cores)
          AllMI <- parallel::parSapply(cl, 1:ncol(X), function(j) {
            infotheo::mutinformation(X = factor(X[Seleced,j]), FactoredPT)
          })
        } else {
          cl <- parallel::makePSOCKcluster(n.cores)
          parallel::clusterExport(cl, c("X", "Selected", "FactoredPT"))
          AllMI <- parallel::parSapply(cl, 1:ncol(X), function(j) {
            infotheo::mutinformation(X = factor(X[Seleced,j]), FactoredPT)
          })
        }
        parallel::stopCluster(cl)
      }
      
      return(AllMI)
      
    })
    
    if(is.null(ModePar)){
      ModePar = "max"
    }
    
    if(!any(ModePar %in% c("min", "max"))){
      ModePar = "max"
    }
    
    if(ModePar == "max"){
      MiVect <- apply(Path_MI, 1, max)
    }
    if(ModePar == "min"){
      MiVect <- apply(Path_MI, 1, min)
    }
    
    names(MiVect) <- colnames(X)
    OrdMI <- order(MiVect, decreasing = TRUE)
    
    if(ReturnGenes){
      RetVect <- MiVect[OrdMI]
      return(RetVect)
    }
    
    Features <- colnames(X)[OrdMI[1:Features]]
    
  }
  
  if(is.numeric(Features) & Mode == "MI.DB"){
    
    print("Feature selection by mutual information on differential branches")
    
    SharedPath <- unique(unlist(Paths, use.names = FALSE))
    for(i in 1:length(Paths)){
      SharedPath <- intersect(SharedPath, Paths[[i]])
    }
    
    DiffPath <- list()
    for(i in 1:length(Paths)){
      DiffPath[[i]] <- (Paths[[i]])[!(Paths[[i]] %in% SharedPath)]
    }
    
    Path_MI <- sapply(DiffPath, function(x){
      PtOnPath <- getPseudotime(ProjStruct = PrjStr, NodeSeq = x)
      
      PtVect <- PtOnPath$Pt
      Seleced <- !is.na(PtVect)
      
      FactoredPT <- factor(PtVect[Seleced])
      
      
      if(n.cores == 1){
        AllMI <- sapply(1:ncol(X), function(j) {
          infotheo::mutinformation(X = factor(X[Seleced,j]), FactoredPT)
        })
      } else {
        if(ClusType == "FORK"){
          cl <- parallel::makeForkCluster(n.cores)
          AllMI <- parallel::parSapply(cl, 1:ncol(X), function(j) {
            infotheo::mutinformation(X = factor(X[Seleced,j]), FactoredPT)
          })
        } else {
          cl <- parallel::makePSOCKcluster(n.cores)
          parallel::clusterExport(cl, c("X", "Selected", "FactoredPT"))
          AllMI <- parallel::parSapply(cl, 1:ncol(X), function(j) {
            infotheo::mutinformation(X = factor(X[Seleced,j]), FactoredPT)
          })
        }
        parallel::stopCluster(cl)
      }
      
      return(AllMI)
      
    })
    
    if(is.null(ModePar)){
      ModePar = "max"
    }
    
    if(!any(ModePar %in% c("min", "max"))){
      ModePar = "max"
    }
    
    if(ModePar == "max"){
      MiVect <- apply(Path_MI, 1, max)
    }
    if(ModePar == "min"){
      MiVect <- apply(Path_MI, 1, min)
    }
    
    names(MiVect) <- colnames(X)
    OrdMI <- order(MiVect, decreasing = TRUE)
    
    if(ReturnGenes){
      RetVect <- MiVect[OrdMI]
      return(RetVect)
    }
    
    Features <- colnames(X)[OrdMI[1:Features]]
    
  }
  
  if(is.numeric(Features) & Mode == "KW"){
    
    print("Feature selection by Kruskal-Wallis rank sum test on differential branches")
    
    SharedPath <- unique(unlist(Paths, use.names = FALSE))
    for(i in 1:length(Paths)){
      SharedPath <- intersect(SharedPath, Paths[[i]])
    }
    
    DiffPath <- list()
    for(i in 1:length(Paths)){
      DiffPath[[i]] <- (Paths[[i]])[!(Paths[[i]] %in% SharedPath)]
    }
    
    FilPart <- Partition
    FilPart[] <- 0
    
    for(i in 1:length(DiffPath)){
      if(is.null(ModePar)){
        FilPart[Partition %in% as.integer(DiffPath[[i]])] <- i
      } else {
        SelNodes <- c(
          max(1, length(DiffPath[[i]]) - ModePar),
          length(DiffPath[[i]])
        )
        FilPart[Partition %in% as.integer(DiffPath[[i]])[SelNodes]] <- i
      }
    }
    
    tX <- X[FilPart != 0, ]
    FilPart <- FilPart[FilPart != 0]
    
    if(n.cores == 1){
      PVVect <- apply(tX, 2, function(x){
        kruskal.test(x, FilPart)$p.val
      })
    } else {
      if(ClusType == "FORK"){
        cl <- parallel::makeForkCluster(n.cores)
        PVVect <- parallel::parApply(cl, tX, 2, function(x){
          kruskal.test(x, FilPart)$p.val
        })
      } else {
        cl <- parallel::makePSOCKcluster(n.cores)
        parallel::clusterExport(cl, c("tX", "FilPart"))
        PVVect <- parallel::parApply(cl, tX, 2, function(x){
          kruskal.test(x, FilPart)$p.val
        })
      }
      parallel::stopCluster(cl)
    }
    
    if(ReturnGenes){
      RetVect <- sort(PVVect)
      return(RetVect)
    }
    
    Features <- colnames(X)[order(PVVect, decreasing = FALSE)[1:Features]]
    
  }
  
  if(is.numeric(Features) & Mode == "Cor.DB"){
    
    print("Feature selection by diverging correlation on differential branches")
    
    SharedPath <- unique(unlist(Paths, use.names = FALSE))
    for(i in 1:length(Paths)){
      SharedPath <- intersect(SharedPath, Paths[[i]])
    }
    
    DiffPath <- list()
    for(i in 1:length(Paths)){
      DiffPath[[i]] <- (Paths[[i]])[!(Paths[[i]] %in% SharedPath)]
    }
    
    Path_MI <- sapply(DiffPath, function(x){
      PtOnPath <- getPseudotime(ProjStruct = PrjStr, NodeSeq = x)
      
      PtVect <- PtOnPath$Pt
      Seleced <- !is.na(PtVect)

      suppressWarnings(
        sapply(1:ncol(X), function(j) {
          cor(X[Seleced,j], PtVect[Seleced], method = "spe")
        })
      )
      
    })
    
    MiVect <- apply(Path_MI, 1, function(x){sign(prod(x, na.rm = TRUE))*max(abs(x), na.rm = TRUE)})
    
    OrdMI <- order(MiVect, decreasing = FALSE, na.last = TRUE)
    
    if(ReturnGenes){
      names(MiVect) <- colnames(X)
      RetVect <- sort(PVVect)
      return(RetVect)
    }
    
    Features <- colnames(X)[OrdMI[1:Features]]
    
  }
  
  
  tX <- X[, colnames(X) %in% Features]
  if(is.null(dim(tX))){
    dim(tX) <- c(length(tX), 1)
    rownames(tX) <- rownames(X)
    colnames(tX) <- Features
  }
  
  if(!is.null(BootPG)){
    BrPos <- lapply(BootPG, function(x){
      TB <- table(as.vector(x$Edges$Edges))
      return(x$NodePositions[as.integer(names(TB[TB>2])),])
    })
    
    TB <- table(as.vector(TargetPG$Edges$Edges))
    TargetBP <- as.integer(names(TB[TB>2]))
    
    BPMat <- TargetPG$NodePositions[TargetBP,]
    if(is.null(dim(BPMat))){
      dim(BPMat) <- c(1, length(BPMat))
    }
    
    NodeIdx <- lapply(BrPos, function(x){
      if(is.null(dim(x))){
        dim(x) <- c(1, length(x))
      }
      DMat <- distutils::PartialDistance(x, BPMat)
      
      if(OnlyIsomorphicBoot){
        if(ncol(DMat) != nrow(DMat)){
          return(NA)
        } else {
          apply(DMat, 1, which.min)
        }
      } else {
        apply(DMat, 1, which.min)
      }
      
    })
    
    BrPos <- BrPos[sapply(NodeIdx, function(x){all(!is.na(x))})]
    BrPos.Ass <- NodeIdx[sapply(NodeIdx, function(x){all(!is.na(x))})]
    BrPos.Ass <- unlist(BrPos.Ass)
    
    BrPos.Mat <- do.call(rbind, BrPos)
    
    tPart <- PartitionData(X = BrPos.Mat, NodePositions = TargetPG$NodePositions, TrimmingRadius = TrimmingRadius)
    
    tProj <- project_point_onto_graph(X = BrPos.Mat,
                                           NodePositions = TargetPG$NodePositions,
                                           Edges = TargetPG$Edges$Edges,
                                           Partition = tPart$Partition)
    
  }
  
  
  if(ScalePT){
    
    # Get the end point for each branch
    BP <- sapply(Paths, function(x){
      c(x[1], x[length(x)])
    })
    
    # Get the unique end points
    BP <- unique(as.vector(BP))
    
    # for each pair of paths
    for(i in 1:length(Paths)){
      for(j in 1:length(Paths)){
        if(i == j){
          next()
        }
        Range <- range(which(Paths[[i]] %in% Paths[[j]]))
        if(Range[1] == Range[2]){
          Range <- Range[1]
        }
        BP <- union(BP, (Paths[[i]])[Range])
      }
    }
    
    BPxPath <- sapply(Paths, function(x){
      sum(x %in% BP)
    })
    
    NormStep <- 1/(max(BPxPath)-1)
    
  }
  
  for(i in 1:length(Paths)){
    PtOnPath <- getPseudotime(ProjStruct = PrjStr, NodeSeq = Paths[[i]])
    
    PtVect <- PtOnPath$Pt
    names(PtVect) <- rownames(tX)
    MetlExp <- reshape::melt(tX)
    
    MetlExp$X1 <- as.character(MetlExp$X1)
    
    if(!is.null(names(Paths)[i])){
      TrjName <- names(Paths)[i]
    } else {
      TrjName <- i
    }
    
    PtCI <- NULL
    
    if(!is.null(BootPG)){
      PtOnPath.Boot <- getPseudotime(ProjStruct = tProj, NodeSeq = Paths[[i]])
      
      # PtVect.Boot <- PtOnPath.Boot$Pt
      
      # OrgBR <- names(which(table(TargetPG$Edges$Edges)>2))
      
      # BrPos <- PtOnPath.Boot$NodePos[which(Paths[[i]] %in% OrgBR)]
      # 
      # BrDist <- sapply(as.list(BrPos), function(x){
      #   abs(x - PtVect.Boot)
      # })
      # 
      # Associated <- apply(BrDist, 1, function(x){
      #   if(any(is.na(x))){
      #     return(0)
      #   } else {
      #     return(which.min(x))
      #   }
      # })
      
      Split.Pt <- split(PtOnPath.Boot$Pt, BrPos.Ass)
      
      PtCI <- do.call(rbind,
              lapply(Split.Pt, function(x){
                quantile(x, c(1-Conf/2, Conf/2), na.rm = TRUE)
              })
      )
      
    }
    
    CIDf <- NULL
    
    if(ScalePT){
      
      RenormPoints <- PtOnPath$NodePos[which(Paths[[i]] %in% BP)]
      
      if(RenormPoints[1] == 0 & length(RenormPoints) == 2){
        RenormPoints <- RenormPoints[-1]
      } else {
        RenormPoints[1] <- -1
      }
      
      if(!is.null(BootPG)){
        PtVect <- c(PtVect, as.vector(PtCI))
      }
      
      RenormPt <- PtVect
      
      if(length(RenormPoints) > 1){
        for(j in 1:(length(RenormPoints)-1)){
          
          ToRenorm <- RenormPt[PtVect>RenormPoints[j] &
                                 PtVect<=RenormPoints[j+1] &
                                 !is.na(PtVect)]
          
          if(RenormPoints[j] != -1){
            ToRenorm <- ToRenorm - RenormPoints[j]
            ToRenorm <- ToRenorm/(RenormPoints[j+1]  - RenormPoints[j])
          } else {
            ToRenorm <- ToRenorm/(RenormPoints[j+1])
          }
          
          if(j == (length(RenormPoints)-1) ){
            ToRenorm <- ToRenorm*(1-NormStep*(j-1)) + NormStep*(j-1)
          } else {
            ToRenorm <- ToRenorm*NormStep + NormStep*(j-1)
          }
          
          RenormPt[PtVect>RenormPoints[j] &
                     PtVect<=RenormPoints[j+1] &
                     !is.na(PtVect)] <- ToRenorm
        }
      } else {
        
        ToRenorm <- RenormPt[!is.na(PtVect)]
        ToRenorm <- ToRenorm/RenormPoints
        
        RenormPt[!is.na(PtVect)] <- ToRenorm
      }
      
      names(RenormPt) <- names(PtVect)
      
      if(!is.null(BootPG)){
        CIRenorm <- RenormPt[
          (length(RenormPt)-length(PtCI)+1):length(RenormPt)
          ]
        
        RenormPt <- RenormPt[1:(length(RenormPt)-length(PtCI))]
        
        CIDf <- rbind(
          CIDf, data.frame(Pt.low = CIRenorm[1:(length(CIRenorm)/2)],
                           Pt.high = CIRenorm[(length(CIRenorm)/2+1):length(CIRenorm)],
                           Bp = TargetBP)
        )
        
      }
      
      CombDF <- rbind(
        CombDF, data.frame(Pt = RenormPt[MetlExp$X1],
                           gene = MetlExp$X2,
                           exp = MetlExp$value,
                           traj = TrjName,
                           pop = GroupsLab[MetlExp$X1])
      )
      
    } else {
      CombDF <- rbind(
        CombDF, data.frame(Pt = PtVect[MetlExp$X1],
                           gene = MetlExp$X2,
                           exp = MetlExp$value,
                           traj = TrjName,
                           pop = GroupsLab[MetlExp$X1])
      )
      
      if(!is.null(BootPG)){
        CIDf <- rbind(
          CIDf, data.frame(Pt.low = PtCI[,1],
                           Pt.high = PtCI[,2],
                           Bp = TargetBP
          )
        )
      }
      
    }
    
  }
  
  CombDF$traj <- factor(CombDF$traj)
  
  CombDF <- CombDF[!is.na(CombDF$Pt), ]
  
  if(nrow(CombDF)>0){
    if(TrajCol){
      p <- ggplot2::ggplot(CombDF,
                           ggplot2::aes(x=Pt, y=exp, color = traj)) +
        ggplot2::scale_color_discrete("Branch")
    } else {
      p <- ggplot2::ggplot(CombDF,
                           ggplot2::aes(x=Pt, y=exp, color = pop))
    }
    
    if(PlotOrg){
      p <- p + ggplot2::geom_point(alpha = alpha)
    }
      
    
    if(ScalePT){
      p <- p + ggplot2::geom_smooth(ggplot2::aes(color = traj), method = "loess", span = Span) + 
        ggplot2::geom_vline(xintercept = seq(from=0, to=1, by=NormStep), linetype = 'dotted') +
        ggplot2::labs(title = Main, y = ylab, x = "Normalized pseudotime")
    } else {
      p <- p + ggplot2::geom_smooth(ggplot2::aes(color = traj), method = "loess", span = Span) +
        ggplot2::labs(title = Main, y = ylab, x = "Pseudotime")
    }
    
    if(Log){
      p <- p + ggplot2::scale_y_log10()
    }
    
    if(!is.null(BootPG)){
      
      if(!AllBP){
        
        TB.1 <- table(TargetPG$Edges$Edges)
        AllBr <- names(TB.1[TB.1>2])
        
        ToUse <- NULL
        
        for(i in AllBr){
          TT <- lapply(Paths, function(sel){
            
            id <- which(sel == i)
            
            if(length(id)==0){
              return(NULL)
            }
            
            if(id==0){
              id_low <- id
            } else {
              id_low <- id-1
            }
            
            if(id==length(sel)){
              id_high <- id
            } else {
              id_high <- id+1
            }
            
            return(
              sel[id_low:id_high]
            )
          })
          
          if(length(unique(unlist(TT)))>3){
            ToUse <- c(ToUse, i)
          }
          
        }
        
        CIDf <- CIDf[CIDf$Bp %in% ToUse,]
        
      }
      
      
      if(nrow(CIDf)>0){
        p <- p + ggplot2::geom_rect(data = CIDf,
                                    mapping = ggplot2::aes(xmin = Pt.low, xmax = Pt.high, ymin=-Inf, ymax=Inf), fill = "black",
                                    inherit.aes = FALSE, alpha = .25) + ggplot2::guides(fill = "none")
      }
      
    }
    
    Pages <- ceiling(length(Features) / (facet_rows*facet_cols))
    
    # print(length(Features))
    print(paste(Pages, "pages will be plotted"))
    
    if(Pages > 1){
      p <- lapply(as.list(1:Pages), function(i){
        p + ggforce::facet_wrap_paginate(~gene, nrow = facet_rows, ncol = facet_cols, scales = "free_y", page = i)
      })
    } else {
      p <- p + ggplot2::facet_wrap(~gene, scales = "free_y", nrow = facet_rows, ncol = facet_cols)
    }
    
    return(p)
    
  } else {
    
    return(NULL)
    
  }
  
}










# 
# 
# ExplorePtUnc <- function(X,
#                          Path,
#                          TargetPG,
#                          BootPG = NULL,
#                          Partition,
#                          Partition.Boot = list(),
#                          PrjStr,
#                          PrjStr.Boot = list(),
#                          Feature,
#                          Main = "",
#                          ylab = "Feature value",
#                          alpha = .3,
#                          ScalePT = FALSE,
#                          Log = FALSE) {
#   
#   CombDF <- NULL
#   
#   tX <- X[, colnames(X) %in% Features]
#   MetlExp <- reshape::melt(tX)
#   
#   
#   PtOnPath <- getPseudotime(ProjStruct = PrjStr, NodeSeq = Path)
#   PtVect <- PtOnPath$Pt
#   names(PtVect) <- rownames(tX)
#   
#   CombDF <- rbind(
#     CombDF, data.frame(Pt = PtVect[MetlExp$X1],
#                        gene = MetlExp$X2,
#                        exp = MetlExp$value,
#                        traj = 0)
#   ) 
#     
#   for(i in 1:length(PrjStr.Boot)){
#     
#   }
#   
#     
#     
#   }
#   
#   CombDF$traj <- factor(CombDF$traj)
#   
#   CombDF <- CombDF[!is.na(CombDF$Pt), ]
#   
#   if(nrow(CombDF)>0){
#     p <- ggplot2::ggplot(CombDF,
#                          ggplot2::aes(x=Pt, y=exp, color = traj)) + ggplot2::geom_point(alpha = alpha) +
#       ggplot2::scale_color_discrete("Branch") +
#       ggplot2::facet_wrap(~gene, scales = "free_y")
#     
#     if(ScalePT){
#       p <- p + ggplot2::geom_smooth(method = "loess", span = NormStep/2) + 
#         ggplot2::geom_vline(xintercept = seq(from=0, to=1, by=NormStep), linetype = 'dotted') +
#         ggplot2::labs(title = Main, y = ylab, x = "Normalized pseudotime")
#     } else {
#       p <- p + ggplot2::geom_smooth(method = "loess", span = .25) +
#         ggplot2::labs(title = Main, y = ylab, x = "Pseudotime")
#     }
#     
#     if(Log){
#       p <- p + ggplot2::scale_y_log10()
#     }
#     
#     return(p)
#     
#   } else {
#     
#     return(NULL)
#     
#   }
#   
# }













# 
# 
# 
# 
# 
# ExpOnPath <- function(ExpData,
#                       Group = NULL,
#                       Path,
#                       TargetPG,
#                       Partition,
#                       PrjStr,
#                       Main = "",
#                       genes = 4) {
# 
# 
#   if(is.null(Group)){
#     Group <- rep("N/A", ncol(ExpData))
#   }
# 
#   if(is.numeric(genes)){
# 
#     GenesByVar <- apply(ExpData, 1, var)
# 
#     if(length(GenesByVar) <= genes){
#       genes = length(GenesByVar)
#     }
# 
#     genes <- names(GenesByVar[order(GenesByVar, decreasing = TRUE)])[1:genes]
# 
#   }
# 
#   tExpData <- ExpData[genes, ]
# 
#   PtOnPath <- getPseudotime(ProjStruct = PrjStr, NodeSeq = Path)
# 
#   PtVect <- PtOnPath$Pt
#   names(PtVect) <- colnames(tExpData)
#   MetlExp <- reshape::melt(t(tExpData))
# 
#   CombDF <- data.frame(Pt = PtVect[as.character(MetlExp$X1)],
#                        gene = MetlExp$X2, exp = MetlExp$value,
#                        group = Group)
# 
#   CombDF <- CombDF[!is.na(CombDF$Pt), ]
# 
#   if(nrow(CombDF)>0){
#     p <- ggplot2::ggplot(CombDF,
#                          ggplot2::aes(x=Pt, y=exp)) +
#       ggplot2::geom_point(ggplot2::aes(color = group), alpha = .3) +
#       ggplot2::geom_smooth() + ggplot2::scale_color_discrete("Group") +
#       ggplot2::facet_wrap(~gene, scales = "free_y") +
#       ggplot2::labs(title = Main, y = "Gene expression", x = "Pseudotime")
# 
#     return(p)
# 
#   } else {
# 
#     return(NULL)
# 
#   }
# 
# }
# 
# 
