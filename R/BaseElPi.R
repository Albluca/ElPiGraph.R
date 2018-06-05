

#' Core function to construct a principal elestic graph
#' 
#' The core function that takes the n m-dimensional points and construct a principal elastic graph using the
#' grammars provided. 
#'
#' @param X numerical 2D matrix, the n-by-m matrix with the position of n m-dimensional points
#' @param NumNodes integer, the number of nodes of the principal graph
#' @param Lambda real, the lambda parameter used the compute the elastic energy
#' @param Mu real, the lambda parameter used the compute the elastic energy
#' @param CompileReport boolean, should a step-by-step report with various information on the
#' contruction of the principal graph be compiled?
#' @param ShowTimer boolean, should the time to construct the graph be computed and reported for each step?
#' @param ComputeMSEP boolean, should MSEP be computed when building the report?
#' @param GrowGrammars list of strings, the grammar to be used in the growth step
#' @param ShrinkGrammars list of strings, the grammar to be used in the shrink step
#' @param GrammarOrder vector of strings, the order of application of the grammars. Can be any combination of "Grow" and "Shrink"
#' @param NodesPositions numerical 2D matrix, the k-by-m matrix with k m-dimensional positions of the nodes
#' in the initial step
#' @param ElasticMatrix numerical 2D matrix, the k-by-k elastic matrix
#' @param n.cores either an integer (indicating the number of cores to used for the creation of a cluster) or 
#' cluster structure returned, e.g., by makeCluster. If a cluster structure is used, all the nodes must contains X
#' (this is done using clusterExport)
#' @param MinParOP integer, the minimum number of operations to use parallel computation
#' @param MaxNumberOfIterations integer, maximum number of steps to embed the nodes in the data
#' @param eps real, minimal relative change in the position of the nodes to stop embedment 
#' @param TrimmingRadius real, maximal distance of point from a node to affect its embedment
#' @param NumEdges integer, the maximum nulber of edges
#' @param Mode integer, the energy computation mode
#' @param FastSolve boolean, should FastSolve be used when fitting the points to the data?
#' @param ClusType string, the type of cluster to use. It can gbe either "Sock" or "Fork".
#' Currently fork clustering only works in Linux
#' @param AvoidSolitary boolean, should configurations with "solitary nodes", i.e., nodes without associted points be discarded?
#' @param FinalEnergy string indicating the final elastic emergy associated with the configuration. Currently it can be "Base" or "Penalized"
#' @param alpha positive numeric, the value of the alpha parameter of the penalized elastic energy
#' @param beta positive numeric, the value of the beta parameter of the penalized elastic energy
#' @param EmbPointProb numeric between 0 and 1. If less than 1 point will be sampled at each iteration.
#' EmbPointProb indicates the probability of using each points. This is an *experimental* feature, which may
#' helps speeding up the computation if a large number of points is present.
#' @param MaxFailedOperations integer, the maximum allowed number of consecutive failed grammar operations,
#' i.e. appplication of the single grammar operations, that did not produce any valid configuration
#' @param MaxSteps integer, the maximum allowed number of steps of the algorithm. Each step is composed by the application of
#' all the specified grammar operations
#' @param GrammarOptimization boolean, should the grammar be used to optimize the graph? If true a number MaxSteps of operations will be applied.
#' @param AdjustElasticMatrix a penalization function to adjust the elastic matrices after a configuration has been chosen (e.g., AdjustByConstant).
#' If NULL (the default), no penalization will be used.
#' @param AdjustVect boolean vector keeping track of the nodes for which the elasticity parameters have been adjusted.
#' When true for a node its elasticity parameters will not be adjusted.
#' @param gamma 
#' @param verbose 
#' @param AdjustElasticMatrix.Initial a penalization function to adjust the elastic matrices of the initial configuration (e.g., AdjustByConstant).
#' If NULL (the default), no penalization will be used.
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
ElPrincGraph <- function(X,
                         NumNodes = 100,
                         NumEdges = Inf,
                         Lambda,
                         Mu,
                         ElasticMatrix,
                         NodesPositions,
                         AdjustVect,
                         verbose = FALSE,
                         n.cores = 1,
                         ClusType = "Sock",
                         MinParOP = 20,
                         CompileReport = FALSE,
                         ShowTimer = FALSE,
                         ComputeMSEP = TRUE,
                         FinalEnergy = "Base",
                         alpha = 0,
                         beta = 0,
                         gamma = 0,
                         Mode = 1,
                         MaxNumberOfIterations = 10,
                         MaxFailedOperations = Inf,
                         MaxSteps = Inf,
                         GrammarOptimization = FALSE,
                         eps = .01,
                         TrimmingRadius = Inf,
                         GrowGrammars = list(),
                         ShrinkGrammars = list(),
                         GrammarOrder = c("Grow", "Shrink"),
                         FastSolve = FALSE,
                         AvoidSolitary = FALSE,
                         EmbPointProb = 1,
                         AdjustElasticMatrix = NULL,
                         AdjustElasticMatrix.Initial = NULL,
                         ...) {
  
  if(GrammarOptimization){
    print("Using grammar optimization")
    if(is.infinite(MaxSteps)){
      warning("When setting GrammarOptimization to TRUE, MaxSteps must be finite. Using MaxSteps = 1")
      MaxSteps = 1
    }
  }
  
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
  
  if(!is.null(AdjustElasticMatrix.Initial)){
    tGraphInfo <- list(ElasticMatrix = ElasticMatrix, AdjustVect = AdjustVect)
    ElasticMatrix <- AdjustElasticMatrix.Initial(tGraphInfo, ...)$ElasticMatrix
    
    print(paste(sum(ElasticMatrix != tGraphInfo$ElasticMatrix), "values of the elastic matrix have been updated"))
  }
  
  InitNodePositions <- PrimitiveElasticGraphEmbedment(
    X = X, NodePositions = NodesPositions,
    MaxNumberOfIterations = MaxNumberOfIterations, TrimmingRadius = TrimmingRadius, eps = eps,
    ElasticMatrix = ElasticMatrix, Mode = Mode)$EmbeddedNodePositions
  
  UpdatedPG <- list(ElasticMatrix = ElasticMatrix, NodePositions = InitNodePositions, AdjustVect = AdjustVect)
  
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
        parallel::clusterExport(cl, varlist = c("X", "SquaredX", "MaxNumberOfIterations", "TrimmingRadius", "eps", "verbose",
                                                "EmbPointProb", "alpha", "beta", "FinalEnergy"), envir=environment())
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
          parallel::clusterExport(cl, varlist = c("SquaredX", "MaxNumberOfIterations", "TrimmingRadius", "eps", "verbose",
                                                  "EmbPointProb", "alpha", "beta", "FinalEnergy"), envir=environment())
        }
        n.cores = length(CheckX)
        
      } else {
        print("Unable to find X on the cluster. Single processor computation will be used")
        n.cores = 1
      }
    }
  }
  
  if(nrow(UpdatedPG$NodePositions) >= NumNodes & !GrammarOptimization){
    
    FinalReport <- ElPiGraph.R:::ReportOnPrimitiveGraphEmbedment(X = X, NodePositions = UpdatedPG$NodePositions,
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
  
  FailedOperations <- 0
  Steps <- 0
  FirstPrint <- TRUE
  
  while((nrow(UpdatedPG$NodePositions) < NumNodes) | GrammarOptimization){
    
    nEdges <- sum(UpdatedPG$ElasticMatrix[lower.tri(UpdatedPG$ElasticMatrix, diag = FALSE)] > 0)
    
    if((nrow(UpdatedPG$NodePositions) >= NumNodes | nEdges >= NumEdges) & !GrammarOptimization){
      break()
    }
    
    if(!verbose & ShowTimer){
      print(paste("Nodes = ", nrow(UpdatedPG$NodePositions)))
    }
    
    if(!verbose & !ShowTimer){
      if(FirstPrint){
        cat("Nodes = ")
        FirstPrint <- FALSE
      }
      cat(nrow(UpdatedPG$NodePositions))
      cat(" ")
    }
    
    OldPG <- UpdatedPG
    
    for(OpType in GrammarOrder){
      
      if(OpType == "Grow" & length(GrowGrammars)>0){
        for(k in 1:length(GrowGrammars)){
          if(ShowTimer){
            print("Growing")
            tictoc::tic()
          }
          
          UpdatedPG <- ElPiGraph.R:::ApplyOptimalGraphGrammarOpeation(X = X,
                                                                      NodePositions = UpdatedPG$NodePositions,
                                                                      ElasticMatrix = UpdatedPG$ElasticMatrix,
                                                                      AdjustVect = UpdatedPG$AdjustVect,
                                                                      operationtypes = GrowGrammars[[k]],
                                                                      SquaredX = SquaredX,
                                                                      FinalEnergy = FinalEnergy,
                                                                      alpha = alpha,
                                                                      beta = beta,
                                                                      gamma = gamma,
                                                                      Mode = Mode,
                                                                      MaxNumberOfIterations = MaxNumberOfIterations,
                                                                      eps = eps,
                                                                      TrimmingRadius = TrimmingRadius,
                                                                      verbose = FALSE,
                                                                      n.cores = n.cores,
                                                                      EnvCl = cl,
                                                                      MinParOP = MinParOP,
                                                                      FastSolve = FastSolve,
                                                                      AvoidSolitary = AvoidSolitary,
                                                                      EmbPointProb = EmbPointProb,
                                                                      AdjustElasticMatrix = AdjustElasticMatrix,
                                                                      ...)
                                                        
          
          if(!is.list(UpdatedPG)){
            
            FailedOperations <- FailedOperations + 1
            UpdatedPG <- OldPG
            break()
            
          } else {
            
            FailedOperations <- 0
            
            if(nrow(UpdatedPG$NodePositions) == 3){
              # this is needed to erase the star elasticity coefficient which was initially assigned to both leaf nodes,
              # one can erase this information after the number of nodes in the graph is > 2
              
              inds = which(colSums(UpdatedPG$ElasticMatrix-diag(diag(UpdatedPG$ElasticMatrix))>0)==1)
              
              UpdatedPG$ElasticMatrix[inds, inds] <- 0
            }
            
          }
          
          if(ShowTimer){
            tictoc::toc()
          }
          
        }
      }
      
      
      if(OpType == "Shrink" & length(ShrinkGrammars)>0){
        for(k in 1:length(ShrinkGrammars)){
          
          if(ShowTimer){
            print("Shrinking")
            tictoc::tic()
          }
          
          UpdatedPG <- ElPiGraph.R:::ApplyOptimalGraphGrammarOpeation(X = X,
                                                                      NodePositions = UpdatedPG$NodePositions,
                                                                      ElasticMatrix = UpdatedPG$ElasticMatrix,
                                                                      AdjustVect = UpdatedPG$AdjustVect,
                                                                      operationtypes = ShrinkGrammars[[k]],
                                                                      SquaredX = SquaredX,
                                                                      Mode = Mode,
                                                                      FinalEnergy = FinalEnergy,
                                                                      alpha = alpha,
                                                                      beta = beta,
                                                                      gamma = gamma,
                                                                      MaxNumberOfIterations = MaxNumberOfIterations,
                                                                      eps = eps,
                                                                      TrimmingRadius = TrimmingRadius,
                                                                      verbose = FALSE,
                                                                      n.cores = n.cores,
                                                                      MinParOP = MinParOP,
                                                                      EnvCl = cl,
                                                                      FastSolve = FastSolve,
                                                                      AvoidSolitary = AvoidSolitary,
                                                                      EmbPointProb = EmbPointProb,
                                                                      AdjustElasticMatrix = AdjustElasticMatrix,
                                                                      ...)
                                                        
          
          if(!is.list(UpdatedPG)){
            
            FailedOperations <- FailedOperations + 1
            UpdatedPG <- OldPG
            break()
            
          } else {
            
            FailedOperations <- 0
            
          }
          
          
          if(ShowTimer){
            tictoc::toc()
          }
          
        }
      }
      
    }
    
    if(CompileReport){
      tReport <- ElPiGraph.R:::ReportOnPrimitiveGraphEmbedment(X = X, NodePositions = UpdatedPG$NodePositions,
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
   
    # Count the execution steps
    Steps <- Steps + 1
    
    # If the number of execution steps is larger than MaxSteps stop the algorithm
    if(Steps > MaxSteps | FailedOperations > MaxFailedOperations){
      break()
    }
     
  }
  
  # FinalReport <- NULL
  
  if(!verbose){
    if(!CompileReport){
      tReport <- ElPiGraph.R:::ReportOnPrimitiveGraphEmbedment(X = X, NodePositions = UpdatedPG$NodePositions,
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
  
  if(is.null(dim(ReportTable)) & !is.null(ReportTable)){
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
#' @param ElasticMatrix numerical 2D matrix, the e-by-e matrix containing the elasticity parameters of the edges
#' @param MaxNumberOfIterations integer, maximum number of steps to embed the nodes in the data
#' @param eps real, minimal relative change in the position of the nodes to stop embedment 
#' @param TrimmingRadius real, maximal distance of point from a node to affect its embedment
#' @param verbose boolean, should debugging information be reported?
#' @param ShowTimer boolean, should the time to construct the graph be computed and reported for each step?
#' @param n.cores either an integer (indicating the number of cores to used for the creation of a cluster) or 
#' cluster structure returned, e.g., by makeCluster. If a cluster structure is used, all the nodes must contains X
#' (this is done using clusterExport)
#' @param MinParOP integer, the minimum number of operations to use parallel computation
#' @param GrowGrammars list of strings, the grammar to be used in the growth step
#' @param ShrinkGrammars list of strings, the grammar to be used in the shrink step
#' @param NumEdges integer, the maximum nulber of edges
#' @param Mode integer, the energy computation mode
#' @param FastSolve boolean, should FastSolve be used when fitting the points to the data?
#' @param ClusType string, the type of cluster to use. It can gbe either "Sock" or "Fork".
#' Currently fork clustering only works in Linux
#' @param AvoidSolitary boolean, should configurations with "solitary nodes", i.e., nodes without associated points be discarded?
#' @param EmbPointProb numeric between 0 and 1. If less than 1 point will be sampled at each iteration.
#' EmbPointProb indicates the probability of using each points. This is an *experimental* feature, which may
#' helps speeding up the computation if a large number of points is present.
#' @param FinalEnergy string indicating the final elastic emergy associated with the configuration. Currently it can be "Base" or "Penalized"
#' @param alpha positive numeric, the value of the alpha parameter of the penalized elastic energy
#' @param beta positive numeric, the value of the beta parameter of the penalized elastic energy 
#' @param ... optional parameter that will be passed to the AdjustHOS function
#' @param AdjustVect boolean vector keeping track of the nodes for which the elasticity parameters have been adjusted.
#' When true for a node its elasticity parameters will not be adjusted.
#' @param gamma 
#' @param AdjustElasticMatrix a penalization function to adjust the elastic matrices after a configuration has been chosen (e.g., AdjustByConstant).
#' If NULL (the default), no penalization will be used.
#' @param AdjustElasticMatrix.Initial a penalization function to adjust the elastic matrices of the initial configuration (e.g., AdjustByConstant).
#' If NULL (the default), no penalization will be used.
#' @param Lambda.Initial 
#' @param Mu.Initial 
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
                                         AdjustVect,
                                         InitEdges,
                                         ElasticMatrix = NULL,
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
                                         MinParOP = 20,
                                         Mode = 1,
                                         FinalEnergy = "Base",
                                         alpha = 0,
                                         beta = 0,
                                         gamma = 0,
                                         GrowGrammars = list(),
                                         ShrinkGrammars = list(),
                                         GrammarOptimization = FALSE,
                                         MaxSteps = Inf,
                                         GrammarOrder = c("Grow", "Shrink"),
                                         FastSolve = FALSE,
                                         AvoidSolitary = FALSE,
                                         EmbPointProb = 1,
                                         AdjustElasticMatrix = NULL,
                                         AdjustElasticMatrix.Initial = NULL, 
                                         Lambda.Initial = NULL, Mu.Initial = NULL,
                                         ...) {
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
  
  if(is.null(Lambda.Initial)){
    Lambda.Initial <- Lambda
  }
  
  if(is.null(Mu.Initial)){
    Mu.Initial <- Mu
  } 
  
  if(is.null(ElasticMatrix)){
    InitElasticMatrix = ElPiGraph.R:::Encode2ElasticMatrix(Edges = InitEdges, Lambdas = Lambda.Initial, Mus = Mu.Initial)
  } else {
    print("The elastic matrix is being used. Edge configuration will be ignored")
    InitElasticMatrix = ElasticMatrix
  }
  
  if(nrow(InitElasticMatrix) != nrow(InitNodePositions) | ncol(InitElasticMatrix) != nrow(InitNodePositions)){
    stop("Elastic matrix incompatible with the node number. Impossible to proceed.")
  }
  
  
  
  # Computing the graph
  
  print(paste("Computing EPG with", NumNodes, "nodes on", nrow(X), "points and", ncol(X), "dimensions"))
  
  ElData <- ElPiGraph.R:::ElPrincGraph(X = X, NumNodes = NumNodes, NumEdges = NumEdges, Lambda = Lambda, Mu = Mu,
                         MaxNumberOfIterations = MaxNumberOfIterations, eps = eps, TrimmingRadius = TrimmingRadius,
                         NodesPositions = InitNodePositions, ElasticMatrix = InitElasticMatrix, AdjustVect = AdjustVect,
                         CompileReport = TRUE, ShowTimer = ShowTimer,
                         FinalEnergy = FinalEnergy, alpha = alpha, beta = beta, gamma = gamma, Mode = Mode,
                         GrowGrammars = GrowGrammars, ShrinkGrammars = ShrinkGrammars,
                         GrammarOptimization = GrammarOptimization, MaxSteps = MaxSteps, GrammarOrder = GrammarOrder,
                         ComputeMSEP = ComputeMSEP, n.cores = n.cores, ClusType = ClusType, MinParOP = MinParOP,
                         verbose = verbose, FastSolve = FastSolve, AvoidSolitary = AvoidSolitary,
                         EmbPointProb = EmbPointProb, AdjustElasticMatrix = AdjustElasticMatrix,
                         AdjustElasticMatrix.Initial = AdjustElasticMatrix.Initial, ...)
  
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


