

#' Core function to construct a principal elestic graph
#' 
#' The core function that takes the n m-dimensional points and construct a principal elastic graph using the
#' grammars provided. 
#'
#' @param X numerical 2D matrix, the n-by-m matrix with the position of n m-dimensional points
#' @param NumNodes integer, the number of nodes of the principal graph
#' @param Lambda real, the lambda parameter used the compute the elastic energy
#' @param Mu real, the lambda parameter used the compute the elastic energy
#' @param verbose boolean, should debugging information be reported?
#' @param CompileReport boolean, should a step-by-step report with various information on the
#' contruction of the principal graph be compiled?
#' @param ShowTimer boolean, should the time to construct the graph be computed and reported for each step?
#' @param ComputeMSEP boolean, should MSEP be computed when building the report?
#' @param GrowGrammars list of strings, the grammar to be used in the growth step
#' @param ShrinkGrammars list of strings, the grammar to be used in the shrink step
#' @param NodesPositions numerical 2D matrix, the k-by-m matrix with k m-dimensional positions of the nodes
#' in the initial step
#' @param ElasticMatrix numerical 2D matrix, the k-by-k elastic matrix
#' @param n.cores either an integer (indicating the number of cores to used for the creation of a cluster) or 
#' cluster structure returned, e.g., by makeCluster. If a cluster structure is used, all the nodes must contains X
#' (this is done using clusterExport)
#' @param MaxNumberOfIterations integer, maximum number of steps to embed the nodes in the data
#' @param eps real, minimal relative change in the position of the nodes to stop embedment 
#' @param TrimmingRadius real, maximal distance of point from a node to affect its embedment
#' @param NumEdges integer, the maximum nulber of edges
#' @param Mode integer, the energy computation mode
#' @param FastSolve boolean, should FastSolve be used when fitting the points to the data?
#' @param ClusType string, the type of cluster to use. It can gbe either "Sock" or "Fork".
#' Currently fork clustering only works in Linux
#' @param AvoidSolitary 
#' @param MinimizingEnergy 
#' @param FinalEnergy 
#' @param alpha 
#' @param beta 
#'
#' @return a named list with a number of elements:
#' \describe{
#'   \item{NodePositions}{A numeric matrix containing the positions of the nodes}
#'   \item{ElasticMatrix}{The elastic matrix of the graph}
#'   \item{ReportTable}{The report table for the graph construction}
#'   \item{FinalReport}{The report table associated with the final graph configuration}
#'   \item{Lambda}{The lambda parameter used during the graph construction}
#'   \item{Mu}{The mu parameter used during the graph construction}
#'   \item{FastSolve}{was FastSolve being used?}
#' }
#' 
#' @export
#'
#' @examples
#' 
#' This is a low level function. See  \code{\link{computeElasticPrincipalCircle}},
#' \code{\link{computeElasticPrincipalCurve}}, or \code{\link{computeElasticPrincipalTree}}
#' for examples
#' 
ElPrincGraph <- function(X, NumNodes = 100, NumEdges = Inf, Lambda, Mu, ElasticMatrix, NodesPositions,
                         verbose = FALSE, n.cores = 1, ClusType = "Sock", CompileReport = FALSE,
                         ShowTimer = FALSE, ComputeMSEP = TRUE,
                         MinimizingEnergy = "Base",
                         FinalEnergy = "Base",
                         alpha = 0,
                         beta = 0,
                         Mode = 1,
                         MaxNumberOfIterations = 10, eps = .01, TrimmingRadius = Inf,
                         GrowGrammars = list(),
                         ShrinkGrammars = list(),
                         FastSolve = FALSE,
                         AvoidSolitary = FALSE) {
  
  if(is.list(X)){
    warning("Data matrix must be a numeric matrix. It will be converted automatically. This can introduce inconsistencies")
    X <- data.matrix(X)
  }
  
  if(!CompileReport){
    verbose = FALSE
  }
  
  if(!is.null(ElasticMatrix)){
    if(any(ElasticMatrix != t(ElasticMatrix))){
      stop('ERROR: Elastic matrix must be square and symmetric')
    }
  }
  
  if(verbose){
    cat('BARCODE\tENERGY\tNNODES\tNEDGES\tNRIBS\tNSTARS\tNRAYS\tNRAYS2\tMSE\tMSEP\tFVE\tFVEP\tUE\tUR\tURN\tURN2\tURSD\n')
  }
  
  InitNodePositions <- PrimitiveElasticGraphEmbedment(
    X = X, NodePositions = NodesPositions,
    MaxNumberOfIterations = MaxNumberOfIterations, TrimmingRadius = TrimmingRadius, eps = eps,
    ElasticMatrix = ElasticMatrix, Mode = Mode)$EmbeddedNodePositions
  
  UpdatedPG <- list(ElasticMatrix = ElasticMatrix, NodePositions = InitNodePositions)
  
  ReportTable <- NULL
  ToSrink <- c(2, 9, 10, 11, 12, 13, 14, 15, 16, 17)
  
  SquaredX = rowSums(X^2)
  
  # now we grow the graph up to NumNodes
  
  GlobalCluster <- TRUE
  
  if(all(class(n.cores) %in% c("numeric", "integer"))){
    if(n.cores > 1){
      if(ClusType == "Fork"){
        print(paste("Creating a fork cluster with", n.cores, "nodes"))
        cl <- parallel::makeCluster(n.cores, type="FORK")
        GlobalCluster <- FALSE
      } else {
        print(paste("Creating a sock cluster with", n.cores, "nodes"))
        cl <- parallel::makeCluster(n.cores)
        GlobalCluster <- FALSE
        parallel::clusterExport(cl, varlist = c("X", "SquaredX", "MaxNumberOfIterations", "TrimmingRadius", "eps", "verbose"), envir=environment())
      }
    } else {
      print("Using a single core")
      cl <- NULL
    }
  } else {
    if(all(c("SOCKcluster", "cluster") %in% class(n.cores))){
      print("Using a user supplied cluster. It must contains the data points in a matrix X")
      cl <- n.cores
      CheckX <- unlist(parallel::clusterCall(cl, function(){exists("X")}))
      if(all(CheckX)){
        GlobalCluster <- TRUE
        if(ClusType != "Fork"){
          print("Exporting the additional variables to the cluster")
          parallel::clusterExport(cl, varlist = c("SquaredX", "MaxNumberOfIterations", "TrimmingRadius", "eps", "verbose"), envir=environment())
        }
        n.cores = length(CheckX)
        
      } else {
        print("Unable to find X on the cluster. Single processor computation will be used")
        n.cores = 1
      }
    }
  }
  
  if(nrow(UpdatedPG$NodePositions) >= NumNodes){
    
    FinalReport <- ReportOnPrimitiveGraphEmbedment(X = X, NodePositions = UpdatedPG$NodePositions,
                                                   ElasticMatrix = UpdatedPG$ElasticMatrix,
                                                   PartData = PartitionData(X = X,
                                                                            NodePositions = UpdatedPG$NodePositions,
                                                                            SquaredX = SquaredX,
                                                                            TrimmingRadius = TrimmingRadius,
                                                                            nCores = 1),
                                                   ComputeMSEP = ComputeMSEP)
    
    return(
      list(NodePositions = UpdatedPG$NodePositions, ElasticMatrix = UpdatedPG$ElasticMatrix,
           ReportTable = unlist(FinalReport), FinalReport = FinalReport, Lambda = Lambda, Mu = Mu,
           FastSolve = FastSolve)
    )
  }
  
  StartNodes <- nrow(UpdatedPG$NodePositions)
  
  # print(FinalReport)
  
  for(i in StartNodes:(NumNodes-1)){
    
    if(nrow(UpdatedPG$NodePositions) < i){
      break()
    }
    
    nEdges <- sum(UpdatedPG$ElasticMatrix[lower.tri(UpdatedPG$ElasticMatrix, diag = FALSE)] > 0)
    
    if(nrow(UpdatedPG$NodePositions) >= NumNodes
       | nEdges >= NumEdges){
      break()
    }
    
    if(!verbose & ShowTimer){
      print(paste("Nodes = ", i))
    }
    
    if(!verbose & !ShowTimer){
      if(i == StartNodes){
        cat("Nodes = ")
      }
      cat(i)
      cat(" ")
    }
    
    ContinueOperation = TRUE
    
    OldPG <- UpdatedPG
    
    if(length(GrowGrammars)>0){
      for(k in 1:length(GrowGrammars)){
        if(ShowTimer){
          print("Growing")
          tictoc::tic()
        }
        
        UpdatedPG <- ApplyOptimalGraphGrammarOpeation(X = X, NodePositions = UpdatedPG$NodePositions,
                                                      ElasticMatrix = UpdatedPG$ElasticMatrix,
                                                      operationtypes = GrowGrammars[[k]],
                                                      SquaredX = SquaredX,
                                                      MinimizingEnergy = MinimizingEnergy,
                                                      FinalEnergy = FinalEnergy,
                                                      alpha = alpha,
                                                      beta = beta,
                                                      Mode = Mode,
                                                      MaxNumberOfIterations = MaxNumberOfIterations,
                                                      eps = eps,
                                                      TrimmingRadius = TrimmingRadius,
                                                      verbose = FALSE,
                                                      n.cores = n.cores,
                                                      EnvCl = cl,
                                                      FastSolve = FastSolve,
                                                      AvoidSolitary = AvoidSolitary)
        
        if(!is.list(UpdatedPG)){
          
          ContinueOperation <- FALSE
          UpdatedPG <- OldPG
          break()
          
        } else {
          
          if(i == 3){
            # % this is needed to erase the star elasticity coefficient which was initially assigned to both leaf nodes,
            # % one can erase this information after the number of nodes in the graph is > 2
            
            inds = which(colSums(UpdatedPG$ElasticMatrix-diag(diag(UpdatedPG$ElasticMatrix))>0)==1)
            
            UpdatedPG$ElasticMatrix[inds, inds] <- 0
          }
          
        }
        
        
        
        if(ShowTimer){
          tictoc::toc()
        }
        
      }
    }
    
    if(length(ShrinkGrammars)>0 & ContinueOperation){
      for(k in 1:length(ShrinkGrammars)){
        
        if(ShowTimer){
          print("Shrinking")
          tictoc::tic()
        }
        
        UpdatedPG <- ApplyOptimalGraphGrammarOpeation(X = X, NodePositions = UpdatedPG$NodePositions,
                                                      ElasticMatrix = UpdatedPG$ElasticMatrix,
                                                      operationtypes = ShrinkGrammars[[k]],
                                                      SquaredX = SquaredX,
                                                      Mode = Mode,
                                                      MinimizingEnergy = MinimizingEnergy,
                                                      FinalEnergy = FinalEnergy,
                                                      alpha = alpha,
                                                      beta = beta,
                                                      MaxNumberOfIterations = MaxNumberOfIterations, eps = eps, TrimmingRadius = TrimmingRadius,
                                                      verbose = FALSE, n.cores, EnvCl = cl, FastSolve = FastSolve, AvoidSolitary = AvoidSolitary)
        
        if(!is.list(UpdatedPG)){
          
          ContinueOperation <- FALSE
          UpdatedPG <- OldPG
          break()
          
        }
        
        
        if(ShowTimer){
          tictoc::toc()
        }
        
      }
    }
    
    if(CompileReport){
      tReport <- ReportOnPrimitiveGraphEmbedment(X = X, NodePositions = UpdatedPG$NodePositions,
                                                 ElasticMatrix = UpdatedPG$ElasticMatrix,
                                                 PartData = PartitionData(X = X,
                                                                          NodePositions = UpdatedPG$NodePositions,
                                                                          SquaredX = SquaredX,
                                                                          TrimmingRadius = TrimmingRadius,
                                                                          nCores = 1),
                                                 ComputeMSEP = ComputeMSEP)
      FinalReport <- tReport
      tReport <- unlist(tReport)
      tReport[ToSrink] <- sapply(tReport[ToSrink], function(x) {
        signif(as.numeric(x), 4)
      })
      
      ReportTable <- rbind(ReportTable, tReport)
      
      if(verbose){
        cat(ReportTable[nrow(ReportTable), ], sep = "\t")
        cat("\n")
      }
    }
    
  }
  
  if(!verbose){
    if(!CompileReport){
      tReport <- ReportOnPrimitiveGraphEmbedment(X = X, NodePositions = UpdatedPG$NodePositions,
                                                 ElasticMatrix = UpdatedPG$ElasticMatrix,
                                                 PartData = PartitionData(X = X,
                                                                          NodePositions = UpdatedPG$NodePositions,
                                                                          SquaredX = SquaredX,
                                                                          TrimmingRadius = TrimmingRadius,
                                                                          nCores = 1),
                                                 ComputeMSEP = ComputeMSEP)
      FinalReport <- tReport
      tReport <- unlist(tReport)
      tReport[ToSrink] <- sapply(tReport[ToSrink], function(x) {
        signif(as.numeric(x), 4)
      })
    } else {
      tReport <- ReportTable[nrow(ReportTable),]
      tReport <- unlist(tReport)
    }
    
    cat("\n")
    cat('BARCODE\tENERGY\tNNODES\tNEDGES\tNRIBS\tNSTARS\tNRAYS\tNRAYS2\tMSE\tMSEP\tFVE\tFVEP\tUE\tUR\tURN\tURN2\tURSD\n')
    cat(tReport, sep = "\t")
    cat("\n")
  }
  
  # ReportTable <- rbind(ReportTable, tReport)
  
  if(!GlobalCluster){
    print("Stopping the cluster")
    parallel::stopCluster(cl)
  }
  
  # print(ReportTable)
  
  if(is.list(ReportTable)){
    ReportTable <- unlist(ReportTable)
  }
  
  # print(ReportTable)
  
  if(is.null(dim(ReportTable))){
    RPNames <- names(ReportTable)
    ReportTable <- matrix(ReportTable, nrow = 1)
    colnames(ReportTable) <- RPNames
  }
  
  # print(ReportTable)
  
  return(list(NodePositions = UpdatedPG$NodePositions, ElasticMatrix = UpdatedPG$ElasticMatrix,
              ReportTable = ReportTable, FinalReport = FinalReport, Lambda = Lambda, Mu = Mu,
              FastSolve = FastSolve, Mode = Mode, MaxNumberOfIterations = MaxNumberOfIterations,
              eps = eps))
  
}
























#' Regularize data and construct a principal elastic graph
#' 
#' This allow to perform basic data regularization before constructing a principla elastic graph.
#' The function also allows plotting the results.
#'
#' @param Data numerical 2D matrix, the n-by-m matrix with the position of n m-dimensional points
#' @param NumNodes integer, the number of nodes of the principal graph
#' @param Lambda real, the lambda parameter used the compute the elastic energy
#' @param Mu real, the lambda parameter used the compute the elastic energy
#' @param Do_PCA boolean, should data and initial node positions be PCA trnasformed?
#' @param CenterData boolean, should data and initial node positions be centered?
#' @param ComputeMSEP boolean, should MSEP be computed when building the report?
#' @param ReduceDimension integer vector, vector of principal components to retain when performing
#' dimensionality reduction. If NULL all the components will be used
#' @param drawAccuracyComplexity boolean, should the accuracy VS complexity plot be reported?
#' @param drawPCAView boolean, should a 2D plot of the points and pricipal curve be dranw for the final configuration?
#' @param drawEnergy boolean, should changes of evergy VS the number of nodes be reported?
#' @param InitNodePositions numerical 2D matrix, the k-by-m matrix with k m-dimensional positions of the nodes
#' in the initial step
#' @param InitEdges numerical 2D matrix, the e-by-2 matrix with e end-points of the edges connecting the nodes
#' @param MaxNumberOfIterations integer, maximum number of steps to embed the nodes in the data
#' @param eps real, minimal relative change in the position of the nodes to stop embedment 
#' @param TrimmingRadius real, maximal distance of point from a node to affect its embedment
#' @param verbose boolean, should debugging information be reported?
#' @param ShowTimer boolean, should the time to construct the graph be computed and reported for each step?
#' @param n.cores either an integer (indicating the number of cores to used for the creation of a cluster) or 
#' cluster structure returned, e.g., by makeCluster. If a cluster structure is used, all the nodes must contains X
#' (this is done using clusterExport)
#' @param GrowGrammars list of strings, the grammar to be used in the growth step
#' @param ShrinkGrammars list of strings, the grammar to be used in the shrink step
#' @param NumEdges integer, the maximum nulber of edges
#' @param Mode integer, the energy computation mode
#' @param FastSolve boolean, should FastSolve be used when fitting the points to the data?
#' @param ClusType string, the type of cluster to use. It can gbe either "Sock" or "Fork".
#' Currently fork clustering only works in Linux
#' @param AvoidSolitary 
#' 
#' @return a named list with a number of elements:
#' \describe{
#'   \item{NodePositions}{A numeric matrix containing the positions of the nodes}
#'   \item{Edges}{A numeric matrix containing the pairs of nodes connected by edges}
#'   \item{ElasticMatrix}{The elastic matrix of the graph}
#'   \item{ReportTable}{The report table for the graph construction}
#'   \item{FinalReport}{The report table associated with the final graph configuration}
#'   \item{Lambda}{The lambda parameter used during the graph construction}
#'   \item{Mu}{The mu parameter used during the graph construction}
#'   \item{FastSolve}{was FastSolve being used?}
#' }
#' 
#' @export
#'
#' @examples
#' 
#' This is a low level function. See  \code{\link{computeElasticPrincipalCircle}},
#' \code{\link{computeElasticPrincipalCurve}}, or \code{\link{computeElasticPrincipalTree}}
#' for examples
#' 
#' 
computeElasticPrincipalGraph <- function(Data,
                                         NumNodes,
                                         NumEdges = Inf,
                                         InitNodePositions,
                                         InitEdges,
                                         Lambda = 0.01,
                                         Mu = 0.1,
                                         MaxNumberOfIterations = 100,
                                         eps = .01,
                                         TrimmingRadius = Inf,
                                         Do_PCA = TRUE,
                                         CenterData = TRUE,
                                         ComputeMSEP = TRUE,
                                         verbose = FALSE,
                                         ShowTimer = FALSE,
                                         ReduceDimension = NULL,
                                         drawAccuracyComplexity = TRUE,
                                         drawPCAView = TRUE,
                                         drawEnergy = TRUE,
                                         n.cores = 1,
                                         ClusType = "Sock",
                                         Mode = 1,
                                         MinimizingEnergy = "Base",
                                         FinalEnergy = "Base",
                                         alpha = 0,
                                         beta = 0,
                                         GrowGrammars = list(),
                                         ShrinkGrammars = list(),
                                         FastSolve = FALSE,
                                         AvoidSolitary = FALSE) {
  ST <- date()
  tictoc::tic()
  
  if(is.null(ReduceDimension)){
    ReduceDimension <- 1:min(dim(Data))
  } else {
    
    if(!Do_PCA){
      print("Cannot reduce dimensionality witout doing PCA.")
      print("Dimensionality reduction will be ignored.")
      ReduceDimension <- 1:min(dim(Data))
    }
    
  }
  
  if(CenterData){
    DataCenters <- colMeans(Data)
    
    Data <- t(t(Data) - DataCenters)
    InitNodePositions <- t(t(InitNodePositions) - DataCenters)
  }
  
  if(Do_PCA){
    
    print("Performing PCA on the data")
    
    ExpVariance <- sum(apply(Data, 2, var))
    
    if(length(ReduceDimension) == 1){
      if(ReduceDimension < 1){
        print("Dimensionality reduction via ratio of explained variance (full PCA will be computed)")
        PCAData <- prcomp(Data, retx = TRUE, center = FALSE, scale. = FALSE)
        
        ReduceDimension <- 1:min(which(cumsum(PCAData$sdev^2)/ExpVariance >= ReduceDimension))
      } else {
        stop("if ReduceDimension is a single value it must be < 1")
      }
      
    } else {
      
      if(max(ReduceDimension) > min(dim(Data))){
        print("Selected dimensions are outside of the available range. ReduceDimension will be updated")
        ReduceDimension <- intersect(ReduceDimension, 1:min(dim(Data)))
      }
      
      if(max(ReduceDimension) > min(dim(Data))*.75){
        print("Using standard PCA")
        PCAData <- prcomp(Data, retx = TRUE, center = FALSE, scale. = FALSE)
      } else {
        print("Using irlba PCA")
        PCAData <- suppressWarnings(irlba::prcomp_irlba(Data, max(ReduceDimension), retx = TRUE, center = FALSE, scale. = FALSE))
      }
    }
    
    ReduceDimension <- ReduceDimension[ReduceDimension <= ncol(PCAData$x)]
    
    perc <- 100*sum(PCAData$sdev[ReduceDimension]^2)/ExpVariance
    print(paste(length(ReduceDimension), "dimensions are being used"))
    print(paste0(signif(perc), "% of the original variance has been retained"))
    
    X <- PCAData$x[,ReduceDimension]
    InitNodePositions <- (InitNodePositions %*% PCAData$rotation)[,ReduceDimension]
    
  } else {
    X = Data
  }
  
  if(Do_PCA | CenterData){
    if(all(c("SOCKcluster", "cluster") %in% class(n.cores)) & ClusType != "Fork"){
      print("Using a user supplied cluster. Updating the value of X")
      parallel::clusterExport(n.cores, varlist = c("X"), envir=environment())
    }
  }
  
  InitElasticMatrix = Encode2ElasticMatrix(Edges = InitEdges, Lambdas = Lambda, Mus = Mu)
  
  # Computing the graph
  
  print(paste("Computing EPG with", NumNodes, "nodes on", nrow(X), "points and", ncol(X), "dimensions"))
  
  ElData <- ElPrincGraph(X = X, NumNodes = NumNodes, NumEdges = NumEdges, Lambda = Lambda, Mu = Mu,
                         MaxNumberOfIterations = MaxNumberOfIterations, eps = eps, TrimmingRadius = TrimmingRadius,
                         NodesPositions = InitNodePositions, ElasticMatrix = InitElasticMatrix,
                         CompileReport = TRUE, ShowTimer = ShowTimer,
                         MinimizingEnergy = MinimizingEnergy,
                         FinalEnergy = FinalEnergy, alpha = alpha, beta = beta, Mode = Mode,
                         GrowGrammars = GrowGrammars, ShrinkGrammars = ShrinkGrammars,
                         ComputeMSEP = ComputeMSEP, n.cores = n.cores, ClusType = ClusType,
                         verbose = verbose, FastSolve = FastSolve, AvoidSolitary = AvoidSolitary)
  
  NodePositions <- ElData$NodePositions
  Edges <- DecodeElasticMatrix(ElData$ElasticMatrix)
  
  if(drawEnergy & !is.null(dim(ElData$ReportTable))){
    print(plotMSDEnergyPlot(ReportTable = ElData$ReportTable))
  }
  
  if(drawAccuracyComplexity & !is.null(dim(ElData$ReportTable))){
    print(accuracyComplexityPlot(ReportTable = ElData$ReportTable))
  }
  
  if(Do_PCA){
    NodePositions <- NodePositions %*% t(PCAData$rotation[, ReduceDimension])
  }
  
  EndTimer <- tictoc::toc()
  
  FinalPG <- list(NodePositions = NodePositions, Edges = Edges, ReportTable = ElData$ReportTable,
                  FinalReport = ElData$FinalReport, ElasticMatrix = ElData$ElasticMatrix,
                  Lambda = ElData$Lambda, Mu = ElData$Mu, TrimmingRadius = TrimmingRadius,
                  FastSolve = ElData$FastSolve, Mode = ElData$Mode,
                  MaxNumberOfIterations = ElData$MaxNumberOfIterations,
                  eps = ElData$eps, Date = ST, TicToc = EndTimer)
  
  if(drawPCAView){
    
    p <- PlotPG(X = Data, TargetPG = FinalPG)
    print(p)
    
  }
  
  if(CenterData){
    NodePositions <- t(t(NodePositions) + DataCenters)
  }
  
  FinalPG$NodePositions <- NodePositions
  
  return(FinalPG)
  
}


