#' Conscruct a principal elastic circle
#'
#' This function is a wrapper to the computeElasticPrincipalGraph function that construct the appropriate initial graph and grammars
#' when constructing a circle
#'
#' @inheritParams computeElasticPrincipalGraphWithGrammars
#' @param Subsets list of column names (or column number). When specified a principal circle will be computed for each of the subsets specified.
#' @param ICOver string, initial condition overlap mode. This can be used to alter the default behaviour for the initial configuration of the
#' principal circle
#'
#' @return
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
                                          ElasticMatrix = NULL,
                                          AdjustVect = NULL,
                                          CenterData = TRUE,
                                          ComputeMSEP = TRUE,
                                          verbose = FALSE,
                                          ShowTimer = FALSE,
                                          ReduceDimension = NULL,
                                          drawAccuracyComplexity = TRUE,
                                          drawPCAView = TRUE,
                                          drawEnergy = TRUE,
                                          n.cores = 1,
                                          MinParOP = 20,
                                          ClusType = "Sock",
                                          nReps = 1,
                                          Subsets = list(),
                                          ProbPoint = 1,
                                          Mode = 1,
                                          FinalEnergy = "Base",
                                          alpha = 0,
                                          beta = 0,
                                          FastSolve = FALSE,
                                          ICOver = NULL,
                                          DensityRadius = NULL,
                                          AvoidSolitary = FALSE,
                                          EmbPointProb = 1,
                                          ParallelRep = FALSE,
                                          SampleIC = TRUE,
                                          AvoidResampling = FALSE,
                                          AdjustElasticMatrix = NULL,
                                          AdjustElasticMatrix.Initial = NULL,
                                          Lambda.Initial = NULL, Mu.Initial = NULL,
                                          ...) {

  # Difine the initial configuration

  if(is.null(ICOver)){
    Configuration = "Circle"
  } else {
    warnings("ICOver is currently ignored when constructing a circle")
    Configuration = "Circle"
  }

  if(InitNodes < 3){
    warnings("The initial number of nodes must be at least 3. This will be fixed")
    InitNodes <- 3
  }

  return(
    computeElasticPrincipalGraphWithGrammars(X = X,
                                             NumNodes = NumNodes,
                                             NumEdges = NumEdges,
                                             InitNodes = InitNodes,
                                             Lambda = Lambda,
                                             Mu = Mu,
                                             GrowGrammars = list('bisectedge'),
                                             ShrinkGrammars = list(),
                                             MaxNumberOfIterations = MaxNumberOfIterations,
                                             TrimmingRadius = TrimmingRadius,
                                             eps = eps,
                                             Do_PCA = Do_PCA,
                                             InitNodePositions = InitNodePositions,
                                             InitEdges = InitEdges,
                                             AdjustVect = AdjustVect,
                                             Configuration = Configuration,
                                             CenterData = CenterData,
                                             ComputeMSEP = ComputeMSEP,
                                             verbose = verbose,
                                             ShowTimer = ShowTimer,
                                             ReduceDimension = ReduceDimension,
                                             drawAccuracyComplexity = drawAccuracyComplexity,
                                             drawPCAView = drawPCAView,
                                             drawEnergy = drawEnergy,
                                             n.cores = n.cores,
                                             MinParOP = MinParOP,
                                             ClusType = ClusType,
                                             nReps = nReps,
                                             Subsets = list(),
                                             ProbPoint = ProbPoint,
                                             Mode = Mode,
                                             FinalEnergy = FinalEnergy,
                                             alpha = alpha,
                                             beta = beta,
                                             FastSolve = FastSolve,
                                             DensityRadius = DensityRadius,
                                             AvoidSolitary = AvoidSolitary,
                                             EmbPointProb = EmbPointProb,
                                             SampleIC = SampleIC,
                                             AvoidResampling = AvoidResampling,
                                             ParallelRep = ParallelRep,
                                             AdjustElasticMatrix = AdjustElasticMatrix,
                                             AdjustElasticMatrix.Initial = AdjustElasticMatrix.Initial,
                                             Lambda.Initial = Lambda.Initial, Mu.Initial = Mu.Initial,
                                             ...)
  )

}










#' Conscruct a principal elastic tree
#'
#' This function is a wrapper to the computeElasticPrincipalGraph function that construct the appropriate initial graph and grammars
#' when constructing a tree
#'
#' @inheritParams computeElasticPrincipalGraphWithGrammars
#' @param Subsets list of column names (or column number). When specified a principal tree will be computed for each of the subsets specified.
#' @param ICOver string, initial condition overlap mode. This can be used to alter the default behaviour for the initial configuration of the
#' principal tree.
#'
#' @return A list of principal graph strucutures containing the trees constructed during the different replica of the algorithm.
#' If the number of replicas is larger than 1. The the final element of the list is the "average tree", which is constructed by
#' fitting the coordinates of the nodes of the reconstructed trees.
#'
#' @export
#'
#' @examples
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
                                        ElasticMatrix = NULL,
                                        AdjustVect = NULL,
                                        CenterData = TRUE,
                                        ComputeMSEP = TRUE,
                                        verbose = FALSE,
                                        ShowTimer = FALSE,
                                        ReduceDimension = NULL,
                                        drawAccuracyComplexity = TRUE,
                                        drawPCAView = TRUE,
                                        drawEnergy = TRUE,
                                        n.cores = 1,
                                        MinParOP = 20,
                                        ClusType = "Sock",
                                        nReps = 1,
                                        Subsets = list(),
                                        ProbPoint = 1,
                                        Mode = 1,
                                        FinalEnergy = "Base",
                                        alpha = 0,
                                        beta = 0,
                                        FastSolve = FALSE,
                                        ICOver = NULL,
                                        DensityRadius = NULL,
                                        AvoidSolitary = FALSE,
                                        EmbPointProb = 1,
                                        ParallelRep = FALSE,
                                        AvoidResampling = FALSE,
                                        SampleIC = TRUE,
                                        AdjustElasticMatrix = NULL,
                                        AdjustElasticMatrix.Initial = NULL,
                                        Lambda.Initial = NULL, Mu.Initial = NULL,
                                        ...) {


  # Difine the initial configuration

  if(is.null(ICOver)){
    Configuration <- "Line"
  } else {
    Configuration <- ICOver
  }

  return(
    computeElasticPrincipalGraphWithGrammars(X = X,
                                             NumNodes = NumNodes,
                                             NumEdges = NumEdges,
                                             InitNodes = InitNodes,
                                             Lambda = Lambda,
                                             Mu = Mu,
                                             GrowGrammars = list(c('bisectedge','addnode2node'),c('bisectedge','addnode2node')),
                                             ShrinkGrammars = list(c('shrinkedge','removenode')),
                                             MaxNumberOfIterations = MaxNumberOfIterations,
                                             TrimmingRadius = TrimmingRadius,
                                             eps = eps,
                                             Do_PCA = Do_PCA,
                                             InitNodePositions = InitNodePositions,
                                             InitEdges = InitEdges,
                                             AdjustVect = AdjustVect,
                                             Configuration = Configuration,
                                             CenterData = CenterData,
                                             ComputeMSEP = ComputeMSEP,
                                             verbose = verbose,
                                             ShowTimer = ShowTimer,
                                             ReduceDimension = ReduceDimension,
                                             drawAccuracyComplexity = drawAccuracyComplexity,
                                             drawPCAView = drawPCAView,
                                             drawEnergy = drawEnergy,
                                             n.cores = n.cores,
                                             MinParOP = MinParOP,
                                             ClusType = ClusType,
                                             nReps = nReps,
                                             Subsets = list(),
                                             ProbPoint = ProbPoint,
                                             Mode = Mode,
                                             FinalEnergy = FinalEnergy,
                                             alpha = alpha,
                                             beta = beta,
                                             gamma = gamma,
                                             FastSolve = FastSolve,
                                             DensityRadius = DensityRadius,
                                             AvoidSolitary = AvoidSolitary,
                                             EmbPointProb = EmbPointProb,
                                             SampleIC = SampleIC,
                                             AvoidResampling = AvoidResampling,
                                             ParallelRep = ParallelRep,
                                             AdjustElasticMatrix = AdjustElasticMatrix,
                                             AdjustElasticMatrix.Initial = AdjustElasticMatrix.Initial,
                                             Lambda.Initial = Lambda.Initial, Mu.Initial = Mu.Initial,
                                             ...)
  )

}


























#' Construct a principal elastic curve
#'
#' This function is a wrapper to the computeElasticPrincipalGraph function that construct the appropriate initial graph and grammars
#' when constructing a curve
#'
#' @inheritParams computeElasticPrincipalGraphWithGrammars
#' @param Subsets list of column names (or column number). When specified a principal curve will be computed for each of the subsets specified.
#' @param ICOver string, initial condition overlap mode. This can be used to alter the default behaviour for the initial configuration of the
#' principal curve.
#'
#' @return A list of principal graph strucutures containing the curves constructed during the different replica of the algorithm.
#' If the number of replicas is larger than 1. The the final element of the list is the "average curve", which is constructed by
#' fitting the coordinates of the nodes of the reconstructed curves.
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
                                        InitNodes = 2,
                                        Lambda = 0.01,
                                        Mu = 0.1,
                                        MaxNumberOfIterations = 10,
                                        TrimmingRadius = Inf,
                                        eps = .01,
                                        Do_PCA = TRUE,
                                        InitNodePositions = NULL,
                                        InitEdges = NULL,
                                        ElasticMatrix = NULL,
                                        AdjustVect = NULL,
                                        CenterData = TRUE,
                                        ComputeMSEP = TRUE,
                                        verbose = FALSE,
                                        ShowTimer = FALSE,
                                        ReduceDimension = NULL,
                                        drawAccuracyComplexity = TRUE,
                                        drawPCAView = TRUE,
                                        drawEnergy = TRUE,
                                        n.cores = 1,
                                        MinParOP = 20,
                                        ClusType = "Sock",
                                        nReps = 1,
                                        Subsets = list(),
                                        ProbPoint = 1,
                                        Mode = 1,
                                        FinalEnergy = "Base",
                                        alpha = 0,
                                        beta = 0,
                                        FastSolve = FALSE,
                                        ICOver = NULL,
                                        DensityRadius = NULL,
                                        AvoidSolitary = FALSE,
                                        EmbPointProb = 1,
                                        ParallelRep = FALSE,
                                        AvoidResampling = FALSE,
                                        SampleIC = TRUE,
                                        AdjustElasticMatrix = NULL,
                                        AdjustElasticMatrix.Initial = NULL,
                                        Lambda.Initial = NULL, Mu.Initial = NULL,
                                        ...) {


  # Difine the initial configuration

  if(is.null(ICOver)){
    Configuration = "Line"
  } else {
    Configuration = ICOver
  }

  return(
    computeElasticPrincipalGraphWithGrammars(X = X,
                                             NumNodes = NumNodes,
                                             NumEdges = NumEdges,
                                             InitNodes = InitNodes,
                                             Lambda = Lambda,
                                             Mu = Mu,
                                             GrowGrammars = list('bisectedge'),
                                             ShrinkGrammars = list(),
                                             MaxNumberOfIterations = MaxNumberOfIterations,
                                             TrimmingRadius = TrimmingRadius,
                                             eps = eps,
                                             Do_PCA = Do_PCA,
                                             InitNodePositions = InitNodePositions,
                                             InitEdges = InitEdges,
                                             AdjustVect = AdjustVect,
                                             Configuration = Configuration,
                                             CenterData = CenterData,
                                             ComputeMSEP = ComputeMSEP,
                                             verbose = verbose,
                                             ShowTimer = ShowTimer,
                                             ReduceDimension = ReduceDimension,
                                             drawAccuracyComplexity = drawAccuracyComplexity,
                                             drawPCAView = drawPCAView,
                                             drawEnergy = drawEnergy,
                                             n.cores = n.cores,
                                             MinParOP = MinParOP,
                                             ClusType = ClusType,
                                             nReps = nReps,
                                             Subsets = list(),
                                             ProbPoint = ProbPoint,
                                             Mode = Mode,
                                             FinalEnergy = FinalEnergy,
                                             alpha = alpha,
                                             beta = beta,
                                             FastSolve = FastSolve,
                                             DensityRadius = DensityRadius,
                                             AvoidSolitary = AvoidSolitary,
                                             EmbPointProb = EmbPointProb,
                                             SampleIC = SampleIC,
                                             ParallelRep = ParallelRep,
                                             AvoidResampling = AvoidResampling,
                                             AdjustElasticMatrix = AdjustElasticMatrix,
                                             AdjustElasticMatrix.Initial = AdjustElasticMatrix.Initial,
                                             Lambda.Initial = Lambda.Initial, Mu.Initial = Mu.Initial,
                                             ...)
  )

}




















#' Expand the nodes around a branching point
#'
#' This function is a wrapper to the computeElasticPrincipalGraph function that construct the appropriate initial graph and grammars
#' when increasing the nume number around the branching point
#'
#' @inheritParams computeElasticPrincipalGraphWithGrammars
#' @param Subsets list of column names (or column number). When specified a principal curve will be computed for each of the subsets specified.
#' @param ICOver string, initial condition overlap mode. This can be used to alter the default behaviour for the initial configuration of the
#' principal curve.
#'
#' @return A list of principal graph strucutures containing the curves constructed during the different replica of the algorithm.
#' If the number of replicas is larger than 1. The the final element of the list is the "average curve", which is constructed by
#' fitting the coordinates of the nodes of the reconstructed curves.
#'
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
fineTuneBR <- function(X,
                       NumNodes,
                       NumEdges = Inf,
                       InitNodes = 2,
                       Lambda = 0.01,
                       Mu = 0.1,
                       InitNodePositions,
                       InitEdges = NULL,
                       ElasticMatrix = NULL,
                       MaxSteps = 100,
                       MaxNumberOfIterations = 10,
                       TrimmingRadius = Inf,
                       eps = .01,
                       Do_PCA = TRUE,
                       AdjustVect = NULL,
                       CenterData = TRUE,
                       ComputeMSEP = TRUE,
                       verbose = FALSE,
                       ShowTimer = FALSE,
                       ReduceDimension = NULL,
                       drawAccuracyComplexity = TRUE,
                       drawPCAView = TRUE,
                       drawEnergy = TRUE,
                       n.cores = 1,
                       MinParOP = 20,
                       ClusType = "Sock",
                       nReps = 1,
                       Subsets = list(),
                       ProbPoint = 1,
                       Mode = 1,
                       FinalEnergy = "Base",
                       alpha = 0,
                       beta = 0,
                       FastSolve = FALSE,
                       ICOver = NULL,
                       DensityRadius = NULL,
                       AvoidSolitary = FALSE,
                       EmbPointProb = 1,
                       ParallelRep = FALSE,
                       SampleIC = TRUE,
                       AdjustElasticMatrix = NULL,
                       AdjustElasticMatrix.Initial = NULL,
                       Lambda.Initial = NULL, Mu.Initial = NULL,
                       ...) {


  # Difine the initial configuration

  if(is.null(ICOver)){
    Configuration = "Line"
  } else {
    Configuration = ICOver
  }

  if(NumNodes > nrow(InitNodePositions)){
    GrammarOptimization = FALSE
    GrowGrammars = list('bisectedge_3')
    ShrinkGrammars = list('shrinkedge_3')
    GrammarOrder = c("Grow", "Shrink", "Grow")
  } else {
    GrammarOptimization = TRUE
    GrowGrammars = list('bisectedge_3')
    ShrinkGrammars = list('shrinkedge_3')
    GrammarOrder = c("Shrink", "Grow")
  }

  return(
    computeElasticPrincipalGraphWithGrammars(X = X,
                                             NumNodes = NumNodes,
                                             NumEdges = NumEdges,
                                             InitNodes = InitNodes,
                                             Lambda = Lambda,
                                             Mu = Mu,
                                             GrowGrammars = GrowGrammars,
                                             ShrinkGrammars = ShrinkGrammars,
                                             GrammarOrder = GrammarOrder,
                                             GrammarOptimization = GrammarOptimization,
                                             MaxSteps = MaxSteps,
                                             MaxNumberOfIterations = MaxNumberOfIterations,
                                             TrimmingRadius = TrimmingRadius,
                                             eps = eps,
                                             Do_PCA = Do_PCA,
                                             InitNodePositions = InitNodePositions,
                                             InitEdges = InitEdges,
                                             AdjustVect = AdjustVect,
                                             Configuration = Configuration,
                                             CenterData = CenterData,
                                             ComputeMSEP = ComputeMSEP,
                                             verbose = verbose,
                                             ShowTimer = ShowTimer,
                                             ReduceDimension = ReduceDimension,
                                             drawAccuracyComplexity = drawAccuracyComplexity,
                                             drawPCAView = drawPCAView,
                                             drawEnergy = drawEnergy,
                                             n.cores = n.cores,
                                             ClusType = ClusType,
                                             MinParOP = MinParOP,
                                             nReps = nReps,
                                             Subsets = list(),
                                             ProbPoint = ProbPoint,
                                             Mode = Mode,
                                             FinalEnergy = FinalEnergy,
                                             alpha = alpha,
                                             beta = beta,
                                             FastSolve = FastSolve,
                                             DensityRadius = DensityRadius,
                                             AvoidSolitary = AvoidSolitary,
                                             EmbPointProb = EmbPointProb,
                                             SampleIC = SampleIC,
                                             ParallelRep = ParallelRep,
                                             AdjustElasticMatrix = AdjustElasticMatrix,
                                             AdjustElasticMatrix.Initial = AdjustElasticMatrix.Initial,
                                             Lambda.Initial = Lambda.Initial, Mu.Initial = Mu.Initial,
                                             ...)
  )

}
















#' Extend the leaves of a graph
#'
#' This function is a wrapper to the computeElasticPrincipalGraph function that construct the appropriate initial graph and grammars
#' when increasing the nume number around the branching point
#'
#' @inheritParams computeElasticPrincipalGraphWithGrammars
#'
#' @return A list of principal graph strucutures containing the curves constructed during the different replica of the algorithm.
#' If the number of replicas is larger than 1. The the final element of the list is the "average curve", which is constructed by
#' fitting the coordinates of the nodes of the reconstructed curves.
#'
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
GrowLeaves <- function(X,
                       NumNodes,
                       NumEdges = Inf,
                       InitNodes = 2,
                       Lambda = 0.01,
                       Mu = 0.1,
                       InitNodePositions,
                       InitEdges = NULL,
                       ElasticMatrix = NULL,
                       MaxSteps = 100,
                       MaxNumberOfIterations = 10,
                       TrimmingRadius = Inf,
                       eps = .01,
                       Do_PCA = TRUE,
                       AdjustVect = NULL,
                       CenterData = TRUE,
                       ComputeMSEP = TRUE,
                       verbose = FALSE,
                       ShowTimer = FALSE,
                       ReduceDimension = NULL,
                       drawAccuracyComplexity = TRUE,
                       drawPCAView = TRUE,
                       drawEnergy = TRUE,
                       n.cores = 1,
                       MinParOP = 20,
                       ClusType = "Sock",
                       nReps = 1,
                       Subsets = list(),
                       ProbPoint = 1,
                       Mode = 1,
                       FinalEnergy = "Base",
                       alpha = 0,
                       beta = 0,
                       FastSolve = FALSE,
                       ICOver = NULL,
                       DensityRadius = NULL,
                       AvoidSolitary = FALSE,
                       EmbPointProb = 1,
                       ParallelRep = FALSE,
                       SampleIC = TRUE,
                       AdjustElasticMatrix = NULL,
                       AdjustElasticMatrix.Initial = NULL,
                       Lambda.Initial = NULL, Mu.Initial = NULL,
                       ...) {


  # Difine the initial configuration

  if(is.null(ICOver)){
    Configuration = "Line"
  } else {
    Configuration = ICOver
  }

  return(
    computeElasticPrincipalGraphWithGrammars(X = X,
                                             NumNodes = NumNodes,
                                             NumEdges = NumEdges,
                                             InitNodes = InitNodes,
                                             Lambda = Lambda,
                                             Mu = Mu,
                                             GrowGrammars = list('addnode2node_1'),
                                             ShrinkGrammars = list(),
                                             GrammarOrder = c("Grow"),
                                             GrammarOptimization = FALSE,
                                             MaxSteps = MaxSteps,
                                             MaxNumberOfIterations = MaxNumberOfIterations,
                                             TrimmingRadius = TrimmingRadius,
                                             eps = eps,
                                             Do_PCA = Do_PCA,
                                             InitNodePositions = InitNodePositions,
                                             InitEdges = InitEdges,
                                             AdjustVect = AdjustVect,
                                             Configuration = Configuration,
                                             CenterData = CenterData,
                                             ComputeMSEP = ComputeMSEP,
                                             verbose = verbose,
                                             ShowTimer = ShowTimer,
                                             ReduceDimension = ReduceDimension,
                                             drawAccuracyComplexity = drawAccuracyComplexity,
                                             drawPCAView = drawPCAView,
                                             drawEnergy = drawEnergy,
                                             n.cores = n.cores,
                                             ClusType = ClusType,
                                             MinParOP = MinParOP,
                                             nReps = nReps,
                                             Subsets = list(),
                                             ProbPoint = ProbPoint,
                                             Mode = Mode,
                                             FinalEnergy = FinalEnergy,
                                             alpha = alpha,
                                             beta = beta,
                                             FastSolve = FastSolve,
                                             DensityRadius = DensityRadius,
                                             AvoidSolitary = AvoidSolitary,
                                             EmbPointProb = EmbPointProb,
                                             SampleIC = SampleIC,
                                             ParallelRep = ParallelRep,
                                             AdjustElasticMatrix = AdjustElasticMatrix,
                                             AdjustElasticMatrix.Initial = AdjustElasticMatrix.Initial,
                                             Lambda.Initial = Lambda.Initial, Mu.Initial = Mu.Initial,
                                             ...)
  )

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

    if(ncol(X) < 3){
      PCA <- prcomp(x = X, center = TRUE, scale. = FALSE, retx = TRUE)
    } else {
      PCA <- suppressWarnings(irlba::prcomp_irlba(x = X, n = 2, center = TRUE, scale. = FALSE, retx = TRUE))
    }


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
    print("Creating a line between two random points of the data. The points will have at most a distance DensityRadius if the parameter is specified")

    ID1 <- sample(1:nrow(X), 1)

    Dist <- distutils::PartialDistance(matrix(X[ID1,], nrow = 1), Br = X)

    Probs <- 1/Dist
    if(!is.null(DensityRadius)){
      Probs[Dist > DensityRadius] <- 0
    }
    Probs[is.infinite(Probs)] <- 0

    ID2 <- sample(1:nrow(X), 1, prob = Probs)

    NodePositions <- X[c(ID1, ID2),]

    # Creating edges
    edges = matrix(c(1,2), nrow = 1, byrow = TRUE)

    DONE <- TRUE

  }

  if(Configuration == "RandomSpace"){

    # Starting from Random Points in the data
    print("Creating a line between a point randomy chosen uniformily in the space of points and one of its neighbours. The points will have at most a distance DensityRadius if the parameter is specified")

    KM <- kmeans(X, 10)
    RandClus <- sample(1:length(KM$size))

    ID1 <- sample(which(KM$cluster == RandClus), 1)

    Dist <- distutils::PartialDistance(matrix(X[ID1,], nrow = 1), Br = X)

    Probs <- 1/Dist
    if(!is.null(DensityRadius)){
      Probs[Dist > DensityRadius] <- 0
    }
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
    print("Creating a line in the densest part of the data. DensityRadius needs to be specified!")

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
    print("Creating a line a part of the data, chosen probabilistically by its density. DensityRadius needs to be specified!")

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


















