#' Conscruct a principal graph with the specified grammar
#'
#' This function is a wrapper to the computeElasticPrincipalGraph function that construct the appropriate initial graph and
#' apply the required grammar operations. Note that this is a generic function that is is called by the topology specific functions.
#'
#' @inheritParams computeElasticPrincipalGraph
#' @param X numerical 2D matrix, the n-by-m matrix with the position of n m-dimensional points
#' @param InitNodes integer, number of points to include in the initial graph
#' @param nReps integer, number of replica of the construction
#' @param ProbPoint real between 0 and 1, probability of inclusing of a single point for each computation
#' @param Subsets list of column names (or column number). When specified a principal tree will be computed for each of the subsets specified.
#' @param Configuration string, initial configuration type.
#' @param DensityRadius numeric, the radius used to estimate local density. This need to be set when ICOver is equal to "Density"
#' @param SampleIC boolean, should the initial configuration be considered on the sampled points when applicable?
#' @param ParallelRep boolean, should parallel execution be performed on the sampling instead of the the grammar evaluations?
#' @param AvoidResampling booleand, should the sampling of initial conditions avoid reselecting the same points
#' (or points neighbors if DensityRadius is specified)?
#'
#' @return A list of principal graph strucutures containing the trees constructed during the different replica of the algorithm.
#' If the number of replicas is larger than 1. The the final element of the list is the "average tree", which is constructed by
#' fitting the coordinates of the nodes of the reconstructed trees
#' @export
#'
#' @examples
#'
#'
computeElasticPrincipalGraphWithGrammars <- function(X,
                                                     NumNodes,
                                                     NumEdges = Inf,
                                                     InitNodes = 2,
                                                     Lambda = 0.01,
                                                     Mu = 0.1,
                                                     GrowGrammars,
                                                     ShrinkGrammars,
                                                     GrammarOptimization = FALSE,
                                                     MaxSteps = Inf,
                                                     GrammarOrder = c("Grow", "Shrink"),
                                                     MaxNumberOfIterations = 10,
                                                     TrimmingRadius = Inf,
                                                     eps = .01,
                                                     Do_PCA = TRUE,
                                                     InitNodePositions = NULL,
                                                     AdjustVect = NULL,
                                                     ElasticMatrix = NULL,
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
                                                     MinParOP = MinParOP,
                                                     nReps = 1,
                                                     ParallelRep = FALSE,
                                                     Subsets = list(),
                                                     ProbPoint = 1,
                                                     Mode = 1,
                                                     FinalEnergy = "Base",
                                                     alpha = 0,
                                                     beta = 0,
                                                     gamma = 0,
                                                     FastSolve = FALSE,
                                                     Configuration = NULL,
                                                     DensityRadius = NULL,
                                                     AvoidSolitary = FALSE,
                                                     EmbPointProb = 1,
                                                     SampleIC = TRUE,
                                                     AvoidResampling = TRUE,
                                                     AdjustElasticMatrix = NULL,
                                                     AdjustElasticMatrix.Initial = NULL,
                                                     Lambda.Initial = NULL, Mu.Initial = NULL,
                                                     ...) {

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

  # Copy the original matrix, this is needed in case of subsetting
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

    if(ParallelRep & n.cores > 1){

      print("Using parallel sampling analysis. Limited output available")

      if(ProbPoint<1 & ProbPoint>0){
        SelPoints <- lapply(as.list(1:nReps), function(i){return(runif(nrow(X)) <= ProbPoint)})
      } else {
        SelPoints <- lapply(as.list(1:nReps), function(i){return(rep(TRUE, nrow(X)))})
      }

      # Do we need to compute the initial conditions?
      if(is.null(InitNodePositions) | (is.null(InitEdges) & is.null(ElasticMatrix))){

        print("Generating the initial configurations")

        if(ClusType != "Fork"){
          print("Exporting initial configuration parameters")
          parallel::clusterExport(cl, varlist = c("InitNodes", "Configuration", "DensityRadius",
                                                  "SelPoints", "Lambda", "Mu", "MaxNumberOfIterations",
                                                  "TrimmingRadius", "eps", "Mode"), envir=environment())
        }

        # We are computing the initial conditions. InitNodePositions need to be reset after each step!
        ComputeIC <- TRUE

        if(SampleIC){

          if(AvoidResampling){

            Used <- rep(FALSE, nrow(X))
            InitialConf.List <- list()

            for(i in 1:nReps){

              print(paste("Rep", i, sum(Used), "out of", length(Used), "points have been used"))

              tryCatch(
                InitialConf.List[[i]] <-
                  ElPiGraph.R:::generateInitialConfiguration(X[SelPoints[[i]] & !Used, ],
                                                             Nodes = InitNodes,
                                                             Configuration = Configuration,
                                                             DensityRadius = DensityRadius),
                error = function(e){
                  print(e)
                  print("Resetting Initial point set")
                  Used <<- rep(FALSE, nrow(X))
                  InitialConf.List[[i]] <<-
                    ElPiGraph.R:::generateInitialConfiguration(X[SelPoints[[i]] & !Used, ],
                                                               Nodes = InitNodes,
                                                               Configuration = Configuration,
                                                               DensityRadius = DensityRadius)
                },
                warning = {})

              Dist <- apply(distutils::PartialDistance(InitialConf.List[[i]]$NodePositions, Br = X), 2, min)

              if(!is.null(DensityRadius)){
                Used <- Used | (Dist < DensityRadius)
              } else {
                Used <- Used | (Dist < .Machine$double.xmin)
              }


            }


          } else {

            # Construct the initial configuration
            InitialConf.List <-
              parallel::parLapply(cl, as.list(1:nReps), function(i){
                ElPiGraph.R:::generateInitialConfiguration(X[SelPoints[[i]], ], Nodes = InitNodes,
                                                           Configuration = Configuration, DensityRadius = DensityRadius)
              })

          }




        } else {

          if(AvoidResampling){

            Used <- rep(FALSE, nrow(X))
            InitialConf.List <- list()

            for(i in 1:nReps){

              print(paste("Rep", i, sum(Used), "out of", length(Used), "points have been used"))

              tryCatch(
                InitialConf.List[[i]] <-
                  ElPiGraph.R:::generateInitialConfiguration(X[!Used, ],
                                                             Nodes = InitNodes,
                                                             Configuration = Configuration,
                                                             DensityRadius = DensityRadius),
                error = function(e){
                  print(e)
                  print("Resetting Initial point set")
                  Used <<- rep(FALSE, nrow(X))
                  InitialConf.List[[i]] <<-
                    ElPiGraph.R:::generateInitialConfiguration(X[!Used, ],
                                                               Nodes = InitNodes,
                                                               Configuration = Configuration,
                                                               DensityRadius = DensityRadius)
                },
                warning = {})

              Dist <- apply(distutils::PartialDistance(InitialConf.List[[i]]$NodePositions, Br = X), 2, min)

              if(!is.null(DensityRadius)){
                Used <- Used | (Dist < DensityRadius)
              } else {
                Used <- Used | (Dist <= .Machine$double.xmin)
              }

            }


          } else {

            # Construct the initial configuration
            InitialConf.List <-
              parallel::parLapply(cl, as.list(1:nReps), function(i){
                ElPiGraph.R:::generateInitialConfiguration(X, Nodes = InitNodes,
                                                           Configuration = Configuration, DensityRadius = DensityRadius)
              })

          }



        }

        # Set the initial edge configuration
        InitEdges.List <- lapply(InitialConf.List, "[[", "Edges")

        # Compute the initial elastic matrices
        ElasticMatrix.List <- parallel::parLapply(cl, InitEdges.List, function(Edges){
          ElPiGraph.R:::Encode2ElasticMatrix(Edges = Edges, Lambdas = Lambda, Mus = Mu)
        })

        if(ClusType != "Fork"){
          print("Exporting initial configuration parameters")
          parallel::clusterExport(cl, varlist = c("InitialConf.List", "ElasticMatrix.List"),
                                  envir=environment())
        }

        # Compute the initial node position
        InitNodePositions.List <- parallel::parLapply(cl, as.list(1:nReps), function(i){
          ElPiGraph.R:::PrimitiveElasticGraphEmbedment(
            X = X, NodePositions = InitialConf.List[[i]]$NodePositions,
            MaxNumberOfIterations = MaxNumberOfIterations,
            TrimmingRadius = TrimmingRadius, eps = eps,
            ElasticMatrix = ElasticMatrix.List[[i]], Mode = Mode)$EmbeddedNodePositions
        })
      }


      # Do we need to compute AdjustVect?
      if(is.null(AdjustVect)){
        AdjustVect <- rep(FALSE, nrow(InitNodePositions.List[[1]]))
      }

      # Prevent plotting after a few examples
      print("Graphical output will be suppressed")
      Intermediate.drawPCAView <- FALSE
      Intermediate.drawAccuracyComplexity <- FALSE
      Intermediate.drawEnergy <- FALSE

      # print(paste("Constructing tree", i, "of", nReps, "/ Subset", j, "of", length(Subsets)))


      if(ClusType != "Fork"){
        print("Exporting parameters")
        parallel::clusterExport(cl, varlist = c("InitNodePositions.List", "InitEdges.List", "ElasticMatrix.List",
                                                "NumNodes", "NumEdges", "InitNodePositions.List", "InitEdges.List",
                                                "ElasticMatrix.List", "AdjustVect", "GrowGrammars", "ShrinkGrammars",
                                                "GrammarOptimization", "MaxSteps", "GrammarOrder", "MaxNumberOfIterations",
                                                "TrimmingRadius", "eps", "Lambda", "Mu", "Do_PCA", "CenterData", "ComputeMSEP",
                                                "ReduceDimension", "Mode", "FinalEnergy", "alpha", "beta", "gamma",
                                                "Intermediate.drawAccuracyComplexity", "Intermediate.drawPCAView", "Intermediate.drawEnergy",
                                                "FastSolve", "AvoidSolitary", "EmbPointProb", "AdjustElasticMatrix", "AdjustElasticMatrix.Initial",
                                                "Lambda.Initial", "Mu.Initial"),
                                envir=environment())
      }



      print("Analysis is running ... no output will be shown")
      print("Sit back and relax, this may take a long time ...")

      tictoc::tic()

      # Run the ElPiGraph algorithm
      ReturnList <- parallel::parLapply(cl, as.list(1:nReps), function(i, ...){

        ElPiGraph.R:::computeElasticPrincipalGraph(Data = X[SelPoints[[i]], ],
                                                   NumNodes = NumNodes,
                                                   NumEdges = NumEdges,
                                                   InitNodePositions = InitNodePositions.List[[i]],
                                                   InitEdges = InitEdges.List[[i]],
                                                   ElasticMatrix = ElasticMatrix.List[[i]],
                                                   AdjustVect = AdjustVect,
                                                   GrowGrammars = GrowGrammars,
                                                   ShrinkGrammars = ShrinkGrammars,
                                                   GrammarOptimization = GrammarOptimization,
                                                   MaxSteps = MaxSteps,
                                                   GrammarOrder = GrammarOrder,
                                                   MaxNumberOfIterations = MaxNumberOfIterations,
                                                   TrimmingRadius = TrimmingRadius,
                                                   eps = eps,
                                                   Lambda = Lambda,
                                                   Mu = Mu,
                                                   Do_PCA = Do_PCA,
                                                   CenterData = CenterData,
                                                   ComputeMSEP = ComputeMSEP,
                                                   verbose = FALSE,
                                                   ShowTimer = FALSE,
                                                   ReduceDimension = ReduceDimension,
                                                   Mode = Mode,
                                                   FinalEnergy = FinalEnergy,
                                                   alpha = alpha,
                                                   beta = beta,
                                                   gamma = gamma,
                                                   drawAccuracyComplexity = Intermediate.drawAccuracyComplexity,
                                                   drawPCAView = Intermediate.drawPCAView,
                                                   drawEnergy = Intermediate.drawEnergy,
                                                   n.cores = 1,
                                                   FastSolve = FastSolve,
                                                   AvoidSolitary = AvoidSolitary,
                                                   EmbPointProb = EmbPointProb,
                                                   AdjustElasticMatrix = AdjustElasticMatrix,
                                                   AdjustElasticMatrix.Initial = AdjustElasticMatrix.Initial,
                                                   Lambda.Initial = Lambda.Initial,
                                                   Mu.Initial = Mu.Initial,
                                                   ...)


      })

      tictoc::toc()

      # Save extra information
      for(i in 1:length(ReturnList)){
        ReturnList[[i]]$SubSetID <- j
        ReturnList[[i]]$ReplicaID <- i
        ReturnList[[i]]$ProbPoint <- ProbPoint
      }

      # Reset InitNodePositions for the next iteration
      if(ComputeIC){
        InitNodePositions <- NULL
      }


    } else {

      Used <- rep(FALSE, nrow(X))

      for(i in 1:nReps){

        # Select the poits to be used
        if(ProbPoint<1 & ProbPoint>0){
          SelPoints <- runif(nrow(X)) <= ProbPoint
        } else {
          SelPoints <- rep(TRUE, nrow(X))
        }

        # Do we need to compute the initial conditions?
        if(is.null(InitNodePositions) | (is.null(InitEdges) & is.null(ElasticMatrix))){

          print("Generating the initial configuration")

          # We are computing the initial conditions. InitNodePositions need to be reset after each step!
          ComputeIC <- TRUE

          if(SampleIC){

            if(AvoidResampling){

              InitialConf <-
                ElPiGraph.R:::generateInitialConfiguration(X[SelPoints & !Used, ],
                                                                    Nodes = InitNodes,
                                                                    Configuration = Configuration,
                                                                    DensityRadius = DensityRadius)

              Dist <- apply(distutils::PartialDistance(InitialConf$NodePositions, Br = X), 2, min)

              if(!is.null(DensityRadius)){
                Used <- Used | (Dist < DensityRadius)
              } else {
                Used <- Used | (Dist <= .Machine$double.xmin)
              }

              if(sum(Used) < nrow(X)*.9){
                print("90% of the points have been used as initial conditions. Resetting.")
              }

            } else {
              # Construct the initial configuration
              InitialConf <-
                ElPiGraph.R:::generateInitialConfiguration(X[SelPoints, ],
                                                           Nodes = InitNodes,
                                                           Configuration = Configuration,
                                                           DensityRadius = DensityRadius)
            }

          } else {

            if(AvoidResampling){

              InitialConf <-
                ElPiGraph.R:::generateInitialConfiguration(X[!Used, ],
                                                           Nodes = InitNodes,
                                                           Configuration = Configuration,
                                                           DensityRadius = DensityRadius)

              Dist <- apply(distutils::PartialDistance(InitialConf$NodePositions, Br = X), 2, min)

              if(!is.null(DensityRadius)){
                Used <- Used | (Dist < DensityRadius)
              } else {
                Used <- Used | (Dist < .Machine$double.xmin)
              }

              if(sum(Used) > nrow(X)*.9){
                print("90% of the points have been used as initial conditions. Resetting.")
              }


            } else {

              # Construct the initial configuration
              InitialConf <-
                ElPiGraph.R:::generateInitialConfiguration(X[, ],
                                                           Nodes = InitNodes,
                                                           Configuration = Configuration,
                                                           DensityRadius = DensityRadius)
            }

          }

          # Set the initial edge configuration
          InitEdges <- InitialConf$Edges

          # Compute the initial elastic matrix
          ElasticMatrix <- ElPiGraph.R:::Encode2ElasticMatrix(Edges = InitialConf$Edges, Lambdas = Lambda, Mus = Mu)

          # Compute the initial node position
          InitNodePositions <- ElPiGraph.R:::PrimitiveElasticGraphEmbedment(
            X = X, NodePositions = InitialConf$NodePositions,
            MaxNumberOfIterations = MaxNumberOfIterations, TrimmingRadius = TrimmingRadius, eps = eps,
            ElasticMatrix = ElasticMatrix, Mode = Mode)$EmbeddedNodePositions
        }

        # Do we need to compute AdjustVect?
        if(is.null(AdjustVect)){
          AdjustVect <- rep(FALSE, nrow(InitNodePositions))
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
        ReturnList[[length(ReturnList)+1]] <- ElPiGraph.R:::computeElasticPrincipalGraph(Data = X[SelPoints, ], NumNodes = NumNodes, NumEdges = NumEdges,
                                                                                         InitNodePositions = InitNodePositions, InitEdges = InitEdges, ElasticMatrix = ElasticMatrix,
                                                                                         AdjustVect = AdjustVect,
                                                                                         GrowGrammars = GrowGrammars,
                                                                                         ShrinkGrammars = ShrinkGrammars,
                                                                                         GrammarOptimization = GrammarOptimization,
                                                                                         MaxSteps = MaxSteps,
                                                                                         GrammarOrder = GrammarOrder,
                                                                                         MaxNumberOfIterations = MaxNumberOfIterations, TrimmingRadius = TrimmingRadius, eps = eps,
                                                                                         Lambda = Lambda, Mu = Mu, Do_PCA = Do_PCA,
                                                                                         CenterData = CenterData, ComputeMSEP = ComputeMSEP,
                                                                                         verbose = verbose, ShowTimer = ShowTimer,
                                                                                         ReduceDimension = ReduceDimension, Mode = Mode,
                                                                                         FinalEnergy = FinalEnergy, alpha = alpha, beta = beta, gamma = gamma,
                                                                                         drawAccuracyComplexity = Intermediate.drawAccuracyComplexity,
                                                                                         drawPCAView = Intermediate.drawPCAView,
                                                                                         drawEnergy = Intermediate.drawEnergy,
                                                                                         n.cores = cl, ClusType = ClusType, MinParOP = MinParOP,
                                                                                         FastSolve = FastSolve, AvoidSolitary = AvoidSolitary,
                                                                                         EmbPointProb = EmbPointProb, AdjustElasticMatrix = AdjustElasticMatrix,
                                                                                         AdjustElasticMatrix.Initial = AdjustElasticMatrix.Initial,
                                                                                         Lambda.Initial = Lambda.Initial, Mu.Initial = Mu.Initial,
                                                                                         ...)

        # Save extra information
        ReturnList[[length(ReturnList)]]$SubSetID <- j
        ReturnList[[length(ReturnList)]]$ReplicaID <- i
        ReturnList[[length(ReturnList)]]$ProbPoint <- ProbPoint

        # Reset InitNodePositions for the next iteration
        if(ComputeIC){
          InitNodePositions <- NULL
        }

      }

    }



    # Are we using bootstrapping (nRep > 1). If yes we compute the consensus tree
    if(nReps>1){

      print("Constructing average tree")

      # The nodes of the principal trees will be used as points to compute the consensus tree
      AllPoints <- do.call(rbind, lapply(ReturnList[sapply(ReturnList, "[[", "SubSetID") == j], "[[", "NodePositions"))

      # De we need to compute the initial conditions?
      if(is.null(InitNodePositions) | (is.null(InitEdges) & is.null(ElasticMatrix))){

        # areconstruct the initial configuration
        InitialConf <- ElPiGraph.R:::generateInitialConfiguration(AllPoints, Nodes = InitNodes, Configuration = Configuration, DensityRadius = DensityRadius)

        # print(InitialConf)

        # Set the initial edge configuration
        InitEdges <- InitialConf$Edges

        # Compute the initial elastic matrix
        EM <- Encode2ElasticMatrix(Edges = InitialConf$Edges, Lambdas = Lambda, Mus = Mu)

        # Compute the initial node position
        InitNodePositions <- ElPiGraph.R:::PrimitiveElasticGraphEmbedment(
          X = X, NodePositions = InitialConf$NodePositions,
          MaxNumberOfIterations = MaxNumberOfIterations, TrimmingRadius = TrimmingRadius, eps = eps,
          ElasticMatrix = EM, Mode = Mode)$EmbeddedNodePositions
      }


      ReturnList[[length(ReturnList)+1]] <- ElPiGraph.R:::computeElasticPrincipalGraph(Data = AllPoints, NumNodes = NumNodes, NumEdges = NumEdges,
                                                                         InitNodePositions = InitNodePositions, InitEdges = InitEdges, ElasticMatrix = ElasticMatrix,
                                                                         AdjustVect = AdjustVect,
                                                                         GrowGrammars = GrowGrammars,
                                                                         ShrinkGrammars = ShrinkGrammars,
                                                                         MaxNumberOfIterations = MaxNumberOfIterations, TrimmingRadius = TrimmingRadius, eps = eps,
                                                                         Lambda = Lambda, Mu = Mu, Do_PCA = Do_PCA,
                                                                         CenterData = CenterData, ComputeMSEP = ComputeMSEP,
                                                                         verbose = verbose, ShowTimer = ShowTimer,
                                                                         ReduceDimension = NULL, Mode = Mode,
                                                                         FinalEnergy = FinalEnergy, alpha = alpha, beta = beta, gamma = gamma,
                                                                         drawAccuracyComplexity = drawAccuracyComplexity,
                                                                         drawPCAView = drawPCAView, drawEnergy = drawEnergy,
                                                                         n.cores = cl, ClusType = ClusType, MinParOP = MinParOP,
                                                                         FastSolve = FastSolve, AvoidSolitary = AvoidSolitary,
                                                                         EmbPointProb = EmbPointProb, AdjustElasticMatrix = AdjustElasticMatrix,
                                                                         AdjustElasticMatrix.Initial = AdjustElasticMatrix.Initial,
                                                                         Lambda.Initial = Lambda.Initial, Mu.Initial = Lambda.Initial,
                                                                         ...)

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


