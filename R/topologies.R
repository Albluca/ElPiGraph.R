

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
                         ShowTimer = FALSE, ComputeMSEP = TRUE, Mode = 1,
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
                                                      SquaredX = SquaredX, Mode = Mode,
                                                      MaxNumberOfIterations = MaxNumberOfIterations, eps = eps, TrimmingRadius = TrimmingRadius,
                                                      verbose = FALSE, n.cores = n.cores, EnvCl = cl, FastSolve = FastSolve, AvoidSolitary = AvoidSolitary)
        
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
                                                      SquaredX = SquaredX, Mode = Mode,
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
                         CompileReport = TRUE, ShowTimer = ShowTimer, Mode = Mode,
                         GrowGrammars = GrowGrammars, ShrinkGrammars = ShrinkGrammars,
                         ComputeMSEP = ComputeMSEP, n.cores = n.cores, ClusType = ClusType,
                         verbose = verbose, FastSolve = FastSolve, AvoidSolitary = AvoidSolitary)

  NodePositions <- ElData$NodePositions
  Edges <- DecodeElasticMatrix(ElData$ElasticMatrix)

  if(drawEnergy){
    print(plotMSDEnergyPlot(ReportTable = ElData$ReportTable))
  }

  if(drawAccuracyComplexity){
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


























#' Conscruct a princial elastic circle
#'
#' This function is a wrapper to the computeElasticPrincipalGraph function that construct the appropriate initial graph and grammars
#' when constructing a circle
#'
#' @param X numerical 2D matrix, the n-by-m matrix with the position of n m-dimensional points
#' @param NumNodes integer, the number of nodes of the principal graph
#' @param Lambda real, the lambda parameter used the compute the elastic energy
#' @param Mu real, the lambda parameter used the compute the elastic energy
#' @param InitNodes integer, number of points to include in the initial graph
#' @param MaxNumberOfIterations integer, maximum number of steps to embed the nodes in the data
#' @param TrimmingRadius real, maximal distance of point from a node to affect its embedment
#' @param eps real, minimal relative change in the position of the nodes to stop embedment 
#' @param Do_PCA boolean, should data and initial node positions be PCA trnasformed?
#' @param InitNodePositions numerical 2D matrix, the k-by-m matrix with k m-dimensional positions of the nodes
#' in the initial step
#' @param InitEdges numerical 2D matrix, the e-by-2 matrix with e end-points of the edges connecting the nodes
#' @param CenterData boolean, should data and initial node positions be centered?
#' @param ComputeMSEP boolean, should MSEP be computed when building the report?
#' @param verbose boolean, should debugging information be reported?
#' @param ShowTimer boolean, should the time to construct the graph be computed and reported for each step?
#' @param ReduceDimension integer vector, vector of principal components to retain when performing
#' dimensionality reduction. If NULL all the components will be used
#' @param drawAccuracyComplexity boolean, should the accuracy VS complexity plot be reported?
#' @param drawPCAView boolean, should a 2D plot of the points and pricipal curve be dranw for the final configuration?
#' @param drawEnergy boolean, should changes of evergy VS the number of nodes be reported?
#' @param n.cores either an integer (indicating the number of cores to used for the creation of a cluster) or 
#' cluster structure returned, e.g., by makeCluster. If a cluster structure is used, all the nodes must contains X
#' (this is done using clusterExport)
#' @param nReps integer, number of replica of the construction 
#' @param ProbPoint real between 0 and 1, probability of inclusing of a single point for each computation
#' @param Subsets list of column names (or column number). When specified a principal tree will be computed for each of the subsets specified.
#' @param NumEdges integer, the maximum nulber of edges
#' @param Mode integer, the energy computation mode
#' @param FastSolve boolean, should FastSolve be used when fitting the points to the data?
#' @param ClusType string, the type of cluster to use. It can gbe either "Sock" or "Fork".
#' Currently fork clustering only works in Linux
#' @param AvoidSolitary 
#'
#' @return
#' 
#' A named list 
#' 
#' @export
#'
#' @examples
#' 
#' Elastic circle with different parameters
#' PG <- computeElasticPrincipalCircle(X = circle_data, NumNodes = 30, InitNodes = 3, verbose = TRUE)
#' PG <- computeElasticPrincipalCircle(X = circle_data, NumNodes = 30, InitNodes = 3, verbose = TRUE, Mu = 1, Lambda = .001)
#' 
#' Bootstrapping the construction of the circle
#' PG <- computeElasticPrincipalCircle(X = circle_data, NumNodes = 40, InitNodes = 3,
#' drawAccuracyComplexity = FALSE, drawPCAView = FALSE, drawEnergy = FALSE,
#' verbose = FALSE, nReps = 50, ProbPoint = .8)
#' 
#' PlotPG(X = circle_data, TargetPG = PG[[length(PG)]], BootPG = PG[1:(length(PG)-1)])
#' 
computeElasticPrincipalCircle <- function(X,
                                          NumNodes,
                                          InitNodes = 3,
                                          NumEdges = Inf,
                                          Lambda = 0.01,
                                          Mu = 0.1,
                                          MaxNumberOfIterations = 10,
                                          TrimmingRadius = Inf,
                                          eps = .01,
                                          Do_PCA = TRUE,
                                          InitNodePositions = NULL,
                                          InitEdges = NULL,
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
                                          nReps = 1,
                                          Subsets = list(),
                                          ProbPoint = 1,
                                          Mode = 1,
                                          FastSolve = FALSE,
                                          AvoidSolitary = FALSE) {
  
  if(all(c("SOCKcluster", "cluster") %in% class(n.cores)) & ClusType != "Fork" & length(Subsets) > 0){
    stop("Impossible to use Subsetting with a user supplied cluster not produced by forking")
  }
  
  
  LocalCluster <- FALSE
  
  if(all(class(n.cores) %in% c("numeric", "integer"))){
    if(n.cores > 1){
      if(ClusType == "Fork"){
        print(paste("Creating a fork cluster with", n.cores, "nodes"))
        cl <- parallel::makeCluster(n.cores, type="FORK")
      } else {
        print(paste("Creating a sock cluster with", n.cores, "nodes"))
        cl <- parallel::makeCluster(n.cores)
        parallel::clusterExport(cl, varlist = c("X"), envir=environment())
      }
    } else {
      print("Using a single core")
      cl = 1
    }
  } else {
    if(all(c("SOCKcluster", "cluster") %in% class(n.cores)) & ClusType != "Fork"){
      print("Using a user supplied non-fork cluster. It must contains the data points in a matrix X")
      cl <- n.cores
      CheckX <- unlist(parallel::clusterCall(cl, function(){exists("X")}))
      if(!all(CheckX)){
        print("Unable to find X on the cluster. Single processor computation will be used")
        cl = 1
      }
    }
  }
  
  
  if(length(Subsets) == 0){
    Subsets[[1]] <- 1:ncol(X)
  }
  
  ReturnList <- list()
  
  Base_X <- X
  
  for(j in 1:length(Subsets)){
    
    X <- Base_X[, Subsets[[j]]]
    
    if(LocalCluster & ClusType != "Fork"){
      parallel::clusterExport(cl, varlist = c("X"), envir=environment())
    }
    
    if(is.null(InitNodePositions) | is.null(InitEdges)){
      
      if(InitNodes<3){
        stop("InitNodes must be larger than 2")
      }
      
      InitialConf <- generateInitialConfiguration(X, Nodes = InitNodes, Configuration = "Circle")
      InitEdges <- InitialConf$Edges
      
      EM <- Encode2ElasticMatrix(Edges = InitialConf$Edges, Lambdas = Lambda, Mus = Mu)
      
      InitNodePositions <- PrimitiveElasticGraphEmbedment(
        X = X, NodePositions = InitialConf$NodePositions,
        MaxNumberOfIterations = MaxNumberOfIterations, TrimmingRadius = TrimmingRadius, eps = eps,
        ElasticMatrix = EM, Mode = Mode)$EmbeddedNodePositions
    }
    
    Intermediate.drawPCAView <- drawPCAView
    Intermediate.drawAccuracyComplexity <- drawAccuracyComplexity 
    Intermediate.drawEnergy <- drawEnergy
    
    for(i in 1:nReps){
      
      if(length(ReturnList) == 3){
        print("Graphical output will be suppressed for the remaining replicas")
        Intermediate.drawPCAView <- FALSE
        Intermediate.drawAccuracyComplexity <- FALSE 
        Intermediate.drawEnergy <- FALSE
      }
      
      print(paste("Constructing curve", i, "of", nReps, "/ Subset", j, "of", length(Subsets)))
      
      ReturnList[[length(ReturnList)+1]] <- computeElasticPrincipalGraph(Data = X[runif(nrow(X)) <= ProbPoint, ], NumNodes = NumNodes, NumEdges = NumEdges,
                                                                         GrowGrammars = list('bisectedge'), ShrinkGrammars = list(),
                                                                         InitNodePositions = InitNodePositions, InitEdges = InitEdges,
                                                                         Lambda = Lambda, Mu = Mu, Do_PCA = Do_PCA,
                                                                         MaxNumberOfIterations = MaxNumberOfIterations, TrimmingRadius = TrimmingRadius, eps = eps,
                                                                         CenterData = CenterData, ComputeMSEP = ComputeMSEP,
                                                                         verbose = verbose, ShowTimer = ShowTimer,
                                                                         ReduceDimension = ReduceDimension, Mode = Mode,
                                                                         drawAccuracyComplexity = Intermediate.drawAccuracyComplexity,
                                                                         drawPCAView = Intermediate.drawPCAView, drawEnergy = Intermediate.drawEnergy,
                                                                         n.cores = cl, FastSolve = FastSolve, AvoidSolitary = AvoidSolitary)
      
      ReturnList[[length(ReturnList)]]$SubSetID <- j
      ReturnList[[length(ReturnList)]]$ReplicaID <- i
      ReturnList[[length(ReturnList)]]$ProbPoint <- ProbPoint
      
    }
    
    if(nReps>1){
      
      print("Constructing average tree")
      
      AllPoints <- do.call(rbind, lapply(ReturnList[sapply(ReturnList, "[[", "SubSetID") == j], "[[", "NodePositions"))
      
      ReturnList[[length(ReturnList)+1]] <- computeElasticPrincipalGraph(Data = AllPoints, NumNodes = NumNodes, NumEdges = NumEdges,
                                                                         GrowGrammars = list('bisectedge'), ShrinkGrammars = list(),
                                                                         InitNodePositions = InitNodePositions, InitEdges = InitEdges,
                                                                         Lambda = Lambda, Mu = Mu, Do_PCA = Do_PCA,
                                                                         MaxNumberOfIterations = MaxNumberOfIterations, TrimmingRadius = TrimmingRadius, eps = eps,
                                                                         CenterData = CenterData, ComputeMSEP = ComputeMSEP,
                                                                         verbose = verbose, ShowTimer = ShowTimer,
                                                                         ReduceDimension = NULL, Mode = Mode,
                                                                         drawAccuracyComplexity = Intermediate.drawAccuracyComplexity,
                                                                         drawPCAView = Intermediate.drawPCAView, drawEnergy = Intermediate.drawEnergy,
                                                                         n.cores = cl, FastSolve = FastSolve, AvoidSolitary = AvoidSolitary)
      
      ReturnList[[length(ReturnList)]]$SubSetID <- j
      ReturnList[[length(ReturnList)]]$ReplicaID <- 0
      ReturnList[[length(ReturnList)]]$ProbPoint <- 1
      
    }
    
  }
  
  if(LocalCluster){
    parallel::stopCluster(cl)
  }
  
  return(ReturnList)
  
  
}

























#' Conscruct a princial elastic tree
#'
#' This function is a wrapper to the computeElasticPrincipalGraph function that construct the appropriate initial graph and grammars
#' when constructing a tree
#'
#' @param X numerical 2D matrix, the n-by-m matrix with the position of n m-dimensional points
#' @param NumNodes integer, the number of nodes of the principal graph
#' @param Lambda real, the lambda parameter used the compute the elastic energy
#' @param Mu real, the lambda parameter used the compute the elastic energy
#' @param InitNodes integer, number of points to include in the initial graph
#' @param MaxNumberOfIterations integer, maximum number of steps to embed the nodes in the data
#' @param TrimmingRadius real, maximal distance of point from a node to affect its embedment
#' @param eps real, minimal relative change in the position of the nodes to stop embedment 
#' @param Do_PCA boolean, should data and initial node positions be PCA trnasformed?
#' @param InitNodePositions numerical 2D matrix, the k-by-m matrix with k m-dimensional positions of the nodes
#' in the initial step
#' @param InitEdges numerical 2D matrix, the e-by-2 matrix with e end-points of the edges connecting the nodes
#' @param CenterData boolean, should data and initial node positions be centered?
#' @param ComputeMSEP boolean, should MSEP be computed when building the report?
#' @param verbose boolean, should debugging information be reported?
#' @param ShowTimer boolean, should the time to construct the graph be computed and reported for each step?
#' @param ReduceDimension integer vector, vector of principal components to retain when performing
#' dimensionality reduction. If NULL all the components will be used
#' @param drawAccuracyComplexity boolean, should the accuracy VS complexity plot be reported?
#' @param drawPCAView boolean, should a 2D plot of the points and pricipal curve be dranw for the final configuration?
#' @param drawEnergy boolean, should changes of evergy VS the number of nodes be reported?
#' @param n.cores either an integer (indicating the number of cores to used for the creation of a cluster) or 
#' cluster structure returned, e.g., by makeCluster. If a cluster structure is used, all the nodes must contains X
#' (this is done using clusterExport)
#' @param nReps integer, number of replica of the construction 
#' @param ProbPoint real between 0 and 1, probability of inclusing of a single point for each computation
#' @param Subsets list of column names (or column number). When specified a principal tree will be computed for each of the subsets specified.
#' @param NumEdges integer, the maximum nulber of edges
#' @param Mode integer, the energy computation mode
#' @param FastSolve boolean, should FastSolve be used when fitting the points to the data?
#' @param ClusType string, the type of cluster to use. It can gbe either "Sock" or "Fork".
#' Currently fork clustering only works in Linux
#' @param ICOver string, initial condition overlap mode. This can be used to alter the default behaviour for the initial configuration of the
#' principal tree.
#' @param DensityRadius numeric, the radius used to estimate local density. This need to be set when ICOver is equal to "Density"
#' @param AvoidSolitary 
#'
#' @return A list of principal graph strucutures containing the trees constructed during the different replica of the algorithm.
#' If the number of replicas is larger than 1. The the final element of the list is the "average tree", which is constructed by
#' fitting the coordinates of the nodes of the reconstructed trees
#' @export 
#'
#' @examples
#' 
#' Elastic trees with different parameters
#' PG <- computeElasticPrincipalTree(X = tree_data, NumNodes = 50, InitNodes = 2, verbose = TRUE)
#' 
#' PG <- computeElasticPrincipalTree(X = tree_data, NumNodes = 50, InitNodes = 2, verbose = TRUE, Mu = 1, Lambda = .001)
#' 
#' 
#' Bootstrapping the construction of the tree
#' PG <- computeElasticPrincipalTree(X = tree_data, NumNodes = 40, InitNodes = 2,
#' drawAccuracyComplexity = FALSE, drawPCAView = FALSE, drawEnergy = FALSE,
#' verbose = FALSE, nReps = 25, ProbPoint = .9)
#' 
#' PlotPG(X = tree_data, TargetPG = PG[[length(PG)]], BootPG = PG[1:(length(PG)-1)])
#' 
computeElasticPrincipalTree <- function(X,
                                        NumNodes,
                                        NumEdges = Inf,
                                        InitNodes = 2,
                                        Lambda = 0.01,
                                        Mu = 0.1,
                                        MaxNumberOfIterations = 10,
                                        TrimmingRadius = Inf,
                                        eps = .01,
                                        Do_PCA = TRUE,
                                        InitNodePositions = NULL,
                                        InitEdges = NULL,
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
                                        nReps = 1,
                                        Subsets = list(),
                                        ProbPoint = 1,
                                        Mode = 1,
                                        FastSolve = FALSE,
                                        ICOver = NULL,
                                        DensityRadius = NULL,
                                        AvoidSolitary = FALSE) {
  
  
  # Create a cluster if requested
  
  if(n.cores > 1){
    if(ClusType == "Fork"){
      print(paste("Creating a fork cluster with", n.cores, "nodes"))
      cl <- parallel::makeCluster(n.cores, type="FORK")
    } else {
      print(paste("Creating a sock cluster with", n.cores, "nodes"))
      cl <- parallel::makeCluster(n.cores)
      parallel::clusterExport(cl, varlist = c("X"), envir=environment())
    }
  } else {
    cl = 1
  }
  
  # Be default we are using a predefined initial configuration
  ComputeIC <- FALSE
  
  # Generate a dummy subset is not specified
  if(length(Subsets) == 0){
    Subsets[[1]] <- 1:ncol(X)
  }
  
  # Prepare the list to be returned
  ReturnList <- list()
  
  # Copy the original matrix, this is need in case of subsetting
  Base_X <- X
  
  # For each subset
  for(j in 1:length(Subsets)){
    
    # Generate the appropriate matrix
    X <- Base_X[, Subsets[[j]]]
    
    # Export the data matrix to the cluster is needed
    if(n.cores > 1 & ClusType != "Fork"){
      parallel::clusterExport(cl, varlist = c("X"), envir=environment())
    }
    
    # Define temporary variable to avoid excessing plotting
    Intermediate.drawPCAView <- drawPCAView
    Intermediate.drawAccuracyComplexity <- drawAccuracyComplexity 
    Intermediate.drawEnergy <- drawEnergy
    
    # print(Subsets[[j]])
    # print(Subsets[[j]] %in% colnames(Base_X))
    # print(dim(Base_X))
    
    # For each repetition
    for(i in 1:nReps){
      
      # De we need to compute the initial conditions?
      if(is.null(InitNodePositions) | is.null(InitEdges)){
        
        # We are computing the initial conditions. InitNodePositions need to be reset after each step!
        ComputeIC <- TRUE
        
        # are we using an user-defined configuration for the initial configuration?
        if(is.null(ICOver)){
          InitialConf <- generateInitialConfiguration(X, Nodes = InitNodes, Configuration = "Line")
        } else {
          InitialConf <- generateInitialConfiguration(X, Nodes = InitNodes, Configuration = ICOver, DensityRadius = DensityRadius)
        }
        
        # Set the initial edge configuration
        InitEdges <- InitialConf$Edges
        
        # Compute the initial elastic matrix
        EM <- Encode2ElasticMatrix(Edges = InitialConf$Edges, Lambdas = Lambda, Mus = Mu)
        
        # Compute the initial node position
        InitNodePositions <- PrimitiveElasticGraphEmbedment(
          X = X, NodePositions = InitialConf$NodePositions,
          MaxNumberOfIterations = MaxNumberOfIterations, TrimmingRadius = TrimmingRadius, eps = eps,
          ElasticMatrix = EM, Mode = Mode)$EmbeddedNodePositions
      }
      
      # Limit plotting after a few examples
      if(length(ReturnList) == 3){
        print("Graphical output will be suppressed for the remaining replicas")
        Intermediate.drawPCAView <- FALSE
        Intermediate.drawAccuracyComplexity <- FALSE 
        Intermediate.drawEnergy <- FALSE
      }
      
      print(paste("Constructing tree", i, "of", nReps, "/ Subset", j, "of", length(Subsets)))
      
      # Run the ElPiGraph algorithm
      ReturnList[[length(ReturnList)+1]] <- computeElasticPrincipalGraph(Data = X[runif(nrow(X)) <= ProbPoint, ], NumNodes = NumNodes, NumEdges = NumEdges,
                                                      InitNodePositions = InitNodePositions, InitEdges = InitEdges,
                                                      GrowGrammars = list(c('bisectedge','addnode2node'),c('bisectedge','addnode2node')),
                                                      ShrinkGrammars = list(c('shrinkedge','removenode')),
                                                      MaxNumberOfIterations = MaxNumberOfIterations, TrimmingRadius = TrimmingRadius, eps = eps,
                                                      Lambda = Lambda, Mu = Mu, Do_PCA = Do_PCA,
                                                      CenterData = CenterData, ComputeMSEP = ComputeMSEP,
                                                      verbose = verbose, ShowTimer = ShowTimer,
                                                      ReduceDimension = ReduceDimension, Mode = Mode,
                                                      drawAccuracyComplexity = Intermediate.drawAccuracyComplexity,
                                                      drawPCAView = Intermediate.drawPCAView,
                                                      drawEnergy = Intermediate.drawEnergy,
                                                      n.cores = cl, ClusType = ClusType,
                                                      FastSolve = FastSolve, AvoidSolitary = AvoidSolitary)
      
      # Save extra information
      ReturnList[[length(ReturnList)]]$SubSetID <- j
      ReturnList[[length(ReturnList)]]$ReplicaID <- i
      ReturnList[[length(ReturnList)]]$ProbPoint <- ProbPoint
      
      # Reset InitNodePositions for the next iteration
      if(ComputeIC){
        InitNodePositions <- NULL
      }
      
    }
    
    # Are we using bootstrapping (nRep > 1). If yes we compute the consensus tree
    if(nReps>1){
      
      print("Constructing average tree")
      
      # The nodes of the principal trees will be used as points to compute the consensus tree
      AllPoints <- do.call(rbind, lapply(ReturnList[sapply(ReturnList, "[[", "SubSetID") == j], "[[", "NodePositions"))
      
      # De we need to compute the initial conditions?
      if(is.null(InitNodePositions) | is.null(InitEdges)){
        
        # are we using an user-defined configuration for the initial configuration?
        if(is.null(ICOver)){
          InitialConf <- generateInitialConfiguration(AllPoints, Nodes = InitNodes, Configuration = "Line")
        } else {
          InitialConf <- generateInitialConfiguration(AllPoints, Nodes = InitNodes, Configuration = ICOver, DensityRadius = DensityRadius)
        }
        
        # print(InitialConf)
          
        # Set the initial edge configuration
        InitEdges <- InitialConf$Edges
        
        # Compute the initial elastic matrix
        EM <- Encode2ElasticMatrix(Edges = InitialConf$Edges, Lambdas = Lambda, Mus = Mu)
        
        # Compute the initial node position
        InitNodePositions <- PrimitiveElasticGraphEmbedment(
          X = X, NodePositions = InitialConf$NodePositions,
          MaxNumberOfIterations = MaxNumberOfIterations, TrimmingRadius = TrimmingRadius, eps = eps,
          ElasticMatrix = EM, Mode = Mode)$EmbeddedNodePositions
      }
      
      
      ReturnList[[length(ReturnList)+1]] <- computeElasticPrincipalGraph(Data = AllPoints, NumNodes = NumNodes, NumEdges = NumEdges,
                                                            InitNodePositions = InitNodePositions, InitEdges = InitEdges,
                                                            GrowGrammars = list(c('bisectedge','addnode2node'),c('bisectedge','addnode2node')),
                                                            ShrinkGrammars = list(c('shrinkedge','removenode')),
                                                            MaxNumberOfIterations = MaxNumberOfIterations, TrimmingRadius = TrimmingRadius, eps = eps,
                                                            Lambda = Lambda, Mu = Mu, Do_PCA = Do_PCA,
                                                            CenterData = CenterData, ComputeMSEP = ComputeMSEP,
                                                            verbose = verbose, ShowTimer = ShowTimer,
                                                            ReduceDimension = NULL, Mode = Mode,
                                                            drawAccuracyComplexity = drawAccuracyComplexity,
                                                            drawPCAView = drawPCAView, drawEnergy = drawEnergy,
                                                            n.cores = cl, FastSolve = FastSolve, AvoidSolitary = AvoidSolitary)
      
      # Run the ElPiGraph algorithm
      ReturnList[[length(ReturnList)]]$SubSetID <- j
      ReturnList[[length(ReturnList)]]$ReplicaID <- 0
      ReturnList[[length(ReturnList)]]$ProbPoint <- 1
      
    }
    
  }
  
  # if we created a cluster we need to stop it
  if(n.cores > 1){
    parallel::stopCluster(cl)
  }
  
  return(ReturnList)
  
}



































#' Conscruct a princial elastic curve
#'
#' This function is a wrapper to the computeElasticPrincipalGraph function that construct the appropriate initial graph and grammars
#' when constructing a curve
#'
#' @param X numerical 2D matrix, the n-by-m matrix with the position of n m-dimensional points
#' @param NumNodes integer, the number of nodes of the principal graph
#' @param Lambda real, the lambda parameter used the compute the elastic energy
#' @param Mu real, the lambda parameter used the compute the elastic energy
#' @param InitNodes integer, number of points to include in the initial graph
#' @param MaxNumberOfIterations integer, maximum number of steps to embed the nodes in the data
#' @param TrimmingRadius real, maximal distance of point from a node to affect its embedment
#' @param eps real, minimal relative change in the position of the nodes to stop embedment 
#' @param Do_PCA boolean, should data and initial node positions be PCA trnasformed?
#' @param InitNodePositions numerical 2D matrix, the k-by-m matrix with k m-dimensional positions of the nodes
#' in the initial step
#' @param InitEdges numerical 2D matrix, the e-by-2 matrix with e end-points of the edges connecting the nodes
#' @param CenterData boolean, should data and initial node positions be centered?
#' @param ComputeMSEP boolean, should MSEP be computed when building the report?
#' @param verbose boolean, should debugging information be reported?
#' @param ShowTimer boolean, should the time to construct the graph be computed and reported for each step?
#' @param ReduceDimension integer vector, vector of principal components to retain when performing
#' dimensionality reduction. If NULL all the components will be used
#' @param drawAccuracyComplexity boolean, should the accuracy VS complexity plot be reported?
#' @param drawPCAView boolean, should a 2D plot of the points and pricipal curve be dranw for the final configuration?
#' @param drawEnergy boolean, should changes of evergy VS the number of nodes be reported?
#' @param n.cores either an integer (indicating the number of cores to used for the creation of a cluster) or 
#' cluster structure returned, e.g., by makeCluster. If a cluster structure is used, all the nodes must contains X
#' (this is done using clusterExport)
#' @param nReps integer, number of replica of the construction 
#' @param ProbPoint real between 0 and 1, probability of inclusing of a single point for each computation
#' @param Subsets list of column names (or column number). When specified a principal tree will be computed for each of the subsets specified.
#' @param NumEdges integer, the maximum nulber of edges
#' @param Mode integer, the energy computation mode
#' @param FastSolve boolean, should FastSolve be used when fitting the points to the data?
#' @param ClusType string, the type of cluster to use. It can gbe either "Sock" or "Fork".
#' Currently fork clustering only works in Linux
#' @param ICOver string, initial condition overlap mode. This can be used to alter the default behaviour for the initial configuration of the
#' principal tree.
#' @param DensityRadius numeric, the radius used to estimate local density. This need to be set when ICOver is equal to "Density"
#' @param AvoidSolitary 
#'
#' @return A list of principal graph strucutures containing the curves constructed during the different replica of the algorithm.
#' If the number of replicas is larger than 1. The the final element of the list is the "average curve", which is constructed by
#' fitting the coordinates of the nodes of the reconstructed curve
#' @export
#'
#' @examples
#' 
#' Elastic curve with different parameters
#' PG <- computeElasticPrincipalCurve(X = tree_data, NumNodes = 30, InitNodes = 2, verbose = TRUE)
#' PG <- computeElasticPrincipalCurve(X = circle_data, NumNodes = 30, InitNodes = 2, verbose = TRUE)
#' 
#' PG <- computeElasticPrincipalCurve(X = tree_data, NumNodes = 30, InitNodes = 2, verbose = TRUE, Mu = 1, Lambda = .001)
#' PG <- computeElasticPrincipalCurve(X = circle_data, NumNodes = 30, InitNodes = 2, verbose = TRUE, Mu = 1, Lambda = .001)
#' 
#' 
#' Bootstrapping the construction of the curve
#' PG <- computeElasticPrincipalCurve(X = tree_data, NumNodes = 40, InitNodes = 2,
#' drawAccuracyComplexity = FALSE, drawPCAView = FALSE, drawEnergy = FALSE,
#' verbose = FALSE, nReps = 50, ProbPoint = .8)
#' 
#' PlotPG(X = tree_data, TargetPG = PG[[length(PG)]], BootPG = PG[1:(length(PG)-1)])
#' 
computeElasticPrincipalCurve <- function(X,
                                         NumNodes,
                                         NumEdges = Inf,
                                         InitNodes = 3,
                                         Lambda = 0.01,
                                         Mu = 0.1,
                                         MaxNumberOfIterations = 10,
                                         TrimmingRadius = Inf,
                                         eps = .01,
                                         Do_PCA = TRUE,
                                         InitNodePositions = NULL,
                                         InitEdges = NULL,
                                         CenterData = TRUE,
                                         ComputeMSEP = TRUE,
                                         verbose = FALSE,
                                         ShowTimer = FALSE,
                                         ReduceDimension = NULL,
                                         drawAccuracyComplexity = TRUE,
                                         drawPCAView = TRUE,
                                         drawEnergy = TRUE,
                                         n.cores = 1,
                                         ClusType = "Fork",
                                         nReps = 1,
                                         Subsets = list(),
                                         ProbPoint = 1,
                                         Mode = 1,
                                         FastSolve = FALSE,
                                         ICOver = NULL,
                                         DensityRadius = NULL,
                                         AvoidSolitary = FALSE) {
  
  if(n.cores > 1){
    if(ClusType == "Fork"){
      print(paste("Creating a fork cluster with", n.cores, "nodes"))
      cl <- parallel::makeCluster(n.cores, type="FORK")
    } else {
      print(paste("Creating a sock cluster with", n.cores, "nodes"))
      cl <- parallel::makeCluster(n.cores)
      parallel::clusterExport(cl, varlist = c("X"), envir=environment())
    }
  } else {
    cl = 1
  }
  
  if(length(Subsets) == 0){
    Subsets[[1]] <- 1:ncol(X)
  }
  
  ReturnList <- list()
  
  Base_X <- X
  
  for(j in 1:length(Subsets)){
    
    X <- Base_X[, Subsets[[j]]]
    
    if(n.cores > 1 & ClusType != "Fork"){
      parallel::clusterExport(cl, varlist = c("X"), envir=environment())
    }
    
    if(is.null(InitNodePositions) | is.null(InitEdges)){
      if(is.null(ICOver)){
        InitialConf <- generateInitialConfiguration(X, Nodes = InitNodes, Configuration = "Line")
      } else {
        InitialConf <- generateInitialConfiguration(X, Nodes = InitNodes, Configuration = ICOver, DensityRadius = DensityRadius)
      }
      InitEdges <- InitialConf$Edges
      
      EM <- Encode2ElasticMatrix(Edges = InitialConf$Edges, Lambdas = Lambda, Mus = Mu)
      
      InitNodePositions <- PrimitiveElasticGraphEmbedment(
        X = X, NodePositions = InitialConf$NodePositions,
        MaxNumberOfIterations = MaxNumberOfIterations, TrimmingRadius = TrimmingRadius, eps = eps,
        ElasticMatrix = EM, Mode = Mode)$EmbeddedNodePositions
    }
    
    Intermediate.drawPCAView <- drawPCAView
    Intermediate.drawAccuracyComplexity <- drawAccuracyComplexity 
    Intermediate.drawEnergy <- drawEnergy
    
    for(i in 1:nReps){
      
      if(length(ReturnList) == 3){
        print("Graphical output will be suppressed for the remaining replicas")
        Intermediate.drawPCAView <- FALSE
        Intermediate.drawAccuracyComplexity <- FALSE 
        Intermediate.drawEnergy <- FALSE
      }
      
      print(paste("Constructing curve", i, "of", nReps, "/ Subset", j, "of", length(Subsets)))
      
      ReturnList[[length(ReturnList)+1]] <- computeElasticPrincipalGraph(Data = X[runif(nrow(X)) <= ProbPoint, ], NumNodes = NumNodes, NumEdges = NumEdges,
                                                                         GrowGrammars = list('bisectedge'), ShrinkGrammars = list(),
                                                                         InitNodePositions = InitNodePositions, InitEdges = InitEdges,
                                                                         Lambda = Lambda, Mu = Mu, Do_PCA = Do_PCA,
                                                                         MaxNumberOfIterations = MaxNumberOfIterations, TrimmingRadius = TrimmingRadius, eps = eps,
                                                                         CenterData = CenterData, ComputeMSEP = ComputeMSEP,
                                                                         verbose = verbose, ShowTimer = ShowTimer,
                                                                         ReduceDimension = ReduceDimension, Mode = Mode,
                                                                         drawAccuracyComplexity = Intermediate.drawAccuracyComplexity,
                                                                         drawPCAView = Intermediate.drawPCAView, drawEnergy = Intermediate.drawEnergy,
                                                                         n.cores = cl, FastSolve = FastSolve, AvoidSolitary = AvoidSolitary)
      
      ReturnList[[length(ReturnList)]]$SubSetID <- j
      ReturnList[[length(ReturnList)]]$ReplicaID <- i
      ReturnList[[length(ReturnList)]]$ProbPoint <- ProbPoint
      
    }
    
    if(nReps>1){
      
      print("Constructing average tree")
      
      AllPoints <- do.call(rbind, lapply(ReturnList[sapply(ReturnList, "[[", "SubSetID") == j], "[[", "NodePositions"))
      
      ReturnList[[length(ReturnList)+1]] <- computeElasticPrincipalGraph(Data = AllPoints, NumNodes = NumNodes, NumEdges = NumEdges,
                                                                         GrowGrammars = list('bisectedge'), ShrinkGrammars = list(),
                                                                         InitNodePositions = InitNodePositions, InitEdges = InitEdges,
                                                                         Lambda = Lambda, Mu = Mu, Do_PCA = Do_PCA,
                                                                         MaxNumberOfIterations = MaxNumberOfIterations, TrimmingRadius = TrimmingRadius, eps = eps,
                                                                         CenterData = CenterData, ComputeMSEP = ComputeMSEP,
                                                                         verbose = verbose, ShowTimer = ShowTimer,
                                                                         ReduceDimension = NULL, Mode = Mode,
                                                                         drawAccuracyComplexity = Intermediate.drawAccuracyComplexity,
                                                                         drawPCAView = Intermediate.drawPCAView, drawEnergy = Intermediate.drawEnergy,
                                                                         n.cores = cl, FastSolve = FastSolve, AvoidSolitary = AvoidSolitary)
      
      ReturnList[[length(ReturnList)]]$SubSetID <- j
      ReturnList[[length(ReturnList)]]$ReplicaID <- 0
      ReturnList[[length(ReturnList)]]$ProbPoint <- 1
      
    }
    
  }
  
  if(n.cores > 1){
    parallel::stopCluster(cl)
  }
  
  return(ReturnList)
  
}





#' Produce an initial graph with a given structure
#'
#' @param X numerical 2D matrix, the n-by-m matrix with the position of n m-dimensional points
#' @param Configuration string, type of graph to return. It should be one of the following value
#' \describe{
#'   \item{"Line"}{Points are placed on the 1st principal component between mean-sd and mean+sd}
#'   \item{"Circle"}{Points are placed on the the plane induced by the 1st and 2nd principal components.
#'   In both dimensions they are placed between mean-sd and mean+sd}
#'   \item{"Density"}{Two points are selected randomly in the neighborhood of one of the points with
#'   the largest number of neighbour points}
#'   \item{"DensityProb"}{Two points are selected randomly in the neighborhood of one of a point randomly
#'   selected with a probability proportional to the number of neighbour points}
#'   \item{"Random"}{Two points are returned. The first is selected at random, and the second is selected with
#'   a probability inversely proportional to thr distance to the 1st point selected}
#' }
#' 
#' @param Nodes integer, number of nodes of the graph
#' @param DensityRadius numeric, the radius used to estimate local density. This need to be set when Configuration is equal to "Density"
#' @param MaxPoints integer, the maximum number of points for which the local density will be estimated. If the number of data points is
#' larger than MaxPoints, a subset of the original points will be sampled
#' @param PCADensity boolean, should PCA be applied to the data before computing the most dense area 
#'
#' @return
#' @export
#'
#' @examples
generateInitialConfiguration <- function(X, Nodes, Configuration = "Line",
                                         DensityRadius = NULL, MaxPoints = 10000,
                                         PCADensity = TRUE, CenterDataDensity = TRUE){
  
  DONE <- FALSE
  
  if(Configuration == "Line"){
    
    # Chain of nodes along the first principal component direction
    print(paste("Creating a chain in the 1st PC with", Nodes, "nodes"))
    
    PCA <- suppressWarnings(irlba::prcomp_irlba(x = X, n = 1, center = TRUE, scale. = FALSE, retx = TRUE))
    
    # Creating nodes
    mn <- mean(PCA$x)
    st <- sd(PCA$x)
    NodePositions = t(t(seq(from=mn-st, to = mn+st, length.out = Nodes) %*% t(PCA$rotation)) + PCA$center)
    
    # Creating edges
    edges = matrix(c(1,2), nrow = nrow(NodePositions) - 1, ncol = 2, byrow = TRUE)
    edges <- edges + 0:(nrow(edges)-1)
    
    DONE <- TRUE
    
  }
  
  if(Configuration == "Circle"){
    
    # Chain of nodes along the first principal component direction
    print(paste("Creating a circle in the plane induced buy the 1st and 2nd PCs with", Nodes, "nodes"))
    
    PCA <- suppressWarnings(irlba::prcomp_irlba(x = X, n = 2, center = TRUE, scale. = FALSE, retx = TRUE))
    
    Nodes_X <- cos(seq(from = 0, to = 2*pi, length.out = Nodes + 1))*sd(PCA$x[,1])
    Nodes_Y <- sin(seq(from = 0, to = 2*pi, length.out = Nodes + 1))*sd(PCA$x[,2])
    
    NodePositions <- t(t(cbind(Nodes_X[-1], Nodes_Y[-1]) %*% t(PCA$rotation)) + PCA$center)
    
    edges <- matrix(c(1,2), nrow = nrow(NodePositions) - 1, ncol = 2, byrow = TRUE)
    edges <- edges + 0:(nrow(edges)-1)
    edges <- rbind(edges, c(Nodes, 1))
    
    DONE <- TRUE
    
  }
  
  if(Configuration == "Random"){
    
    # Starting from Random Points in the data
    print("Creating a line between two random points of the data")
    
    ID1 <- sample(1:nrow(X), 1)
    
    Dist <- distutils::PartialDistance(matrix(X[ID1,], nrow = 1), Br = X)
    
    Probs <- 1/Dist
    Probs[is.infinite(Probs)] <- 0
    
    ID2 <- sample(1:nrow(X), 1, prob = Probs)
    
    NodePositions <- X[c(ID1, ID2),]
    
    # Creating edges
    edges = matrix(c(1,2), nrow = 1, byrow = TRUE)
    
    DONE <- TRUE
    
  }
  
  if(Configuration == "Density"){
    
    if(is.null(DensityRadius)){
      stop("DensityRadius need to be specified for density-dependent inizialization!")
    }
    
    # Starting from Random Points in the data
    print("Creating a line in the densest part of the graph. DensityRadius needs to be specified!")
    
    if(PCADensity){
      tX.PCA <- prcomp(x = X, retx = TRUE, center = CenterDataDensity, scale. = FALSE)
      tX <- tX.PCA$x
    } else {
      tX <- X
    }
    
    if(nrow(tX) > MaxPoints){
      
      print(paste("Too many points, a subset of", MaxPoints, "will be sampled"))
      
      SampedIdxs <- sample(1:nrow(tX), MaxPoints)
      
      PartStruct <- distutils::PartialDistance(tX[SampedIdxs, ], tX[SampedIdxs, ])
      PointsInNei <- apply(PartStruct < DensityRadius, 1, sum)
      
      if(max(PointsInNei) < 2){
        stop("DensityRadius too small (Not enough points found in the neighborhood))!!")
      }
      
      IdMax <- which.max(PointsInNei)
      
      NodePositions <- X[SampedIdxs[sample(which(PartStruct[IdMax, ] < DensityRadius), 2)], ]
      
      # Creating edges
      edges = matrix(c(1,2), nrow = 1, byrow = TRUE)
      
      DONE <- TRUE
    } else {
      PartStruct <- distutils::PartialDistance(tX, tX)
      PointsInNei <- apply(PartStruct < DensityRadius, 1, sum)
      
      if(max(PointsInNei) < 2){
        stop("DensityRadius too small (Not enough points found in the neighborhood))!!")
      }
      
      IdMax <- which.max(PointsInNei)
      
      NodePositions <- X[sample(which(PartStruct[IdMax, ] < DensityRadius), 2), ]
      
      # Creating edges
      edges = matrix(c(1,2), nrow = 1, byrow = TRUE)
      
      DONE <- TRUE
    }
    
    
    
  }
  
  if(Configuration == "DensityProb"){
    
    if(is.null(DensityRadius)){
      stop("DensityRadius need to be specified for density-dependent inizialization!")
    }
    
    # Starting from Random Points in the data
    print("Creating a line in the densest part of the graph. DensityRadius needs to be specified!")
    
    if(PCADensity){
      tX.PCA <- prcomp(x = X, retx = TRUE, center = CenterDataDensity, scale. = FALSE)
      tX <- tX.PCA$x
    } else {
      tX <- X
    }
    
    if(nrow(tX) > MaxPoints){
      
      print(paste("Too many points, a subset of", MaxPoints, "will be sampled"))
      
      SampedIdxs <- sample(1:nrow(tX), MaxPoints)
      
      PartStruct <- distutils::PartialDistance(tX[SampedIdxs, ], tX[SampedIdxs, ])
      PointsInNei <- apply(PartStruct < DensityRadius, 1, sum)
      
      if(max(PointsInNei) < 2){
        stop("DensityRadius too small (Not enough points found in the neighborhood))!!")
      }
      
      PointsInNei[PointsInNei == 1] <- 0
      IdMax <- sample(1:length(PointsInNei), size = 1, prob = PointsInNei)
      
      NodePositions <- X[SampedIdxs[sample(which(PartStruct[IdMax, ] < DensityRadius), 2)], ]
      
      # Creating edges
      edges = matrix(c(1,2), nrow = 1, byrow = TRUE)
      
      DONE <- TRUE
    } else {
      PartStruct <- distutils::PartialDistance(tX, tX)
      PointsInNei <- apply(PartStruct < DensityRadius, 1, sum)
      
      if(max(PointsInNei) < 2){
        stop("DensityRadius too small (Not enough points found in the neighborhood))!!")
      }
      
      PointsInNei[PointsInNei == 1] <- 0
      IdMax <- sample(1:length(PointsInNei), size = 1, prob = PointsInNei)
      
      NodePositions <- X[sample(which(PartStruct[IdMax, ] < DensityRadius), 2), ]
      
      # Creating edges
      edges = matrix(c(1,2), nrow = 1, byrow = TRUE)
      
      DONE <- TRUE
    }
    
  }
  
  
  if(DONE){
    return(list(NodePositions = NodePositions, Edges = edges))
  } else {
    stop("Unsupported configuration!")
  }
  
}




















#' Extend leaves with additional nodes
#'
#' @param X numeric matrix, the data matrix
#' @param TargetPG list, the ElPiGraph structure to extend
#' @param LeafIDs integer vector, the id of nodes to extend. If NULL, all the vertices will be extended.
#' @param TrimmingRadius positive numeric, the trimming radius used to control distance 
#' @param ControlPar positive numeric, the paramter used to control the contribution of the different data points
#' @param Mode string, the mode used to extend the graph. "QuantCentroid" and "WeigthedCentroid" are currently implemented
#' @param PlotSelected boolean, should a diagnostic plot be visualized
#'
#' @return The extended ElPiGraph structure
#' 
#' The value of ControlPar has a different interpretation depending on the valus of Mode. In each case, for only the extreme points,
#' i.e., the points associated with the leaf node that do not have a projection on any edge are considered.
#' 
#' If Mode = "QuantCentroid", for each leaf node, the extreme points are ordered by their distance from the node
#' and the centroid of the points farther away than the ControlPar is returned.
#' 
#' If Mode = "WeigthedCentroid", for each leaf node, a weight is computed for each points by raising the distance to the ControlPar power.
#' Hence, larger values of ControlPar result in a larger influence of points farther from the node
#'
#' @export
#'
#' @examples
#' 
#' TreeEPG <- computeElasticPrincipalTree(X = tree_data, NumNodes = 50,
#' drawAccuracyComplexity = FALSE, drawEnergy = FALSE)
#' 
#' ExtStruct <- ExtendLeaves(X = tree_data, TargetPG = TreeEPG[[1]], Mode = "QuantCentroid", ControlPar = .5)
#' PlotPG(X = tree_data, TargetPG = ExtStruct)
#' 
#' ExtStruct <- ExtendLeaves(X = tree_data, TargetPG = TreeEPG[[1]], Mode = "QuantCentroid", ControlPar = .9)
#' PlotPG(X = tree_data, TargetPG = ExtStruct)
#' 
#' ExtStruct <- ExtendLeaves(X = tree_data, TargetPG = TreeEPG[[1]], Mode = "WeigthedCentroid", ControlPar = .2)
#' PlotPG(X = tree_data, TargetPG = ExtStruct)
#' 
#' ExtStruct <- ExtendLeaves(X = tree_data, TargetPG = TreeEPG[[1]], Mode = "WeigthedCentroid", ControlPar = .8)
#' PlotPG(X = tree_data, TargetPG = ExtStruct)
#' 
ExtendLeaves <- function(X, TargetPG, Mode = "WeigthedCentroid", ControlPar = .9, 
                         LeafIDs = NULL, TrimmingRadius = Inf,
                         PlotSelected = TRUE) {
  
  # Generate net
  Net <- ConstructGraph(PrintGraph = TargetPG)
  
  # get leafs
  if(is.null(LeafIDs)){
    LeafIDs <- which(igraph::degree(Net) == 1)
  }
  
  # check LeafIDs
  if(any(igraph::degree(Net, LeafIDs) > 1)){
    stop("Only leaf nodes can be extended")
  }
  
  # and their neigh
  Nei <- igraph::neighborhood(graph = Net, order = 1, nodes = LeafIDs)
  
  # and put stuff together
  NeiVect <- sapply(1:length(Nei), function(i){setdiff(Nei[[i]], LeafIDs[i])})
  NodesMat <- cbind(LeafIDs, NeiVect)
  
  # project data on the nodes
  PD <- PartitionData(X = X, NodePositions = TargetPG$NodePositions, TrimmingRadius = TrimmingRadius)
  
  # Inizialize the new nodes and edges
  NNPos <- NULL
  NEdgs <- NULL
  
  # Keep track of the new nodes IDs
  NodeID <- nrow(TargetPG$NodePositions)
  
  # keep track of the used nodes
  UsedNodes <- NULL
  WeiVal <- NULL
  
  # for each leaf
  for(i in 1:nrow(NodesMat)){
    
    # generate the new node id
    NodeID <- NodeID + 1
    
    # get all the data associated with the leaf node
    tData <- X[PD$Partition == NodesMat[i,1], ]
    
    # and project them on the edge
    Proj <- project_point_onto_edge(X = X[PD$Partition == NodesMat[i,1], ],
                                    NodePositions = TargetPG$NodePositions,
                                    Edge = NodesMat[i,])
    
    # Select the distances of the associated points
    Dists <- PD$Dists[PD$Partition == NodesMat[i,1]]
    
    # Set distances of points projected on beyond the initial position of the edge to 0
    Dists[Proj$Projection_Value >= 0] <- 0
    
    if(Mode == "QuantCentroid"){
      ThrDist <- quantile(Dists[Dists>0], ControlPar)
      SelPoints <- which(Dists >= ThrDist)
      
      print(paste(length(SelPoints), "points selected to compute the centroid while extending node", NodesMat[i,1]))
      
      if(length(SelPoints)>1){
        NN <- colMeans(tData[SelPoints,])
      } else {
        NN <- tData[SelPoints,]
      }
      
      NNPos <- rbind(NNPos, NN)
      NEdgs <- rbind(NEdgs, c(NodesMat[i,1], NodeID))
      
      UsedNodes <- c(UsedNodes, which(PD$Partition == NodesMat[i,1])[SelPoints])
    }
    
    if(Mode == "WeigthedCentroid"){
      
      Dist2 <- Dists^(2*ControlPar)
      Wei <- Dist2/max(Dist2)
      
      if(length(Wei)>1){
        NN <- apply(tData, 2, function(x){sum(x*Wei)/sum(Wei)})
      } else {
        NN <- tData
      }
      
      NNPos <- rbind(NNPos, NN)
      NEdgs <- rbind(NEdgs, c(NodesMat[i,1], NodeID))
      
      UsedNodes <- c(UsedNodes, which(PD$Partition == NodesMat[i,1]))
      WeiVal <- c(WeiVal, Wei)
    }
    
  }
  
  # plot(X)
  # points(TargetPG$NodePositions, col="red")
  # points(NNPos, col="blue")
  # 
  TargetPG$NodePositions <- rbind(TargetPG$NodePositions, NNPos)
  TargetPG$Edges$Edges <- rbind(TargetPG$Edges$Edges, NEdgs)
  TargetPG$Edges$Lambdas <- c(TargetPG$Edges$Lambdas, rep(NA, nrow(NEdgs)))
  TargetPG$Edges$Mus <- c(TargetPG$Edges$Lambdas, rep(NA, nrow(NEdgs)))
  
  
  if(PlotSelected){
    
    if(Mode == "QuantCentroid"){
      Cats <- rep("Unused", nrow(X))
      if(!is.null(UsedNodes)){
        Cats[UsedNodes] <- "Used"
      }
      
      p <- PlotPG(X = X, TargetPG = TargetPG, GroupsLab = Cats)
      print(p)
    }
    
    if(Mode == "WeigthedCentroid"){
      Cats <- rep(0, nrow(X))
      if(!is.null(UsedNodes)){
        Cats[UsedNodes] <- WeiVal
      }
      
      p <- PlotPG(X = X[Cats>0, ], TargetPG = TargetPG, GroupsLab = Cats[Cats>0])
      print(p)
      
      p1 <- PlotPG(X = X, TargetPG = TargetPG, GroupsLab = Cats)
      print(p1)
    }
    
    
  }
  
  return(TargetPG)
  
}






