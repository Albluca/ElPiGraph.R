-   [Setup](#setup)
-   [Getting the substructure of
    interest](#getting-the-substructure-of-interest)
-   [Getting the supporting
    structures](#getting-the-supporting-structures)
-   [Computing pseudotime](#computing-pseudotime)
-   [Exploring features over
    pseudotime](#exploring-features-over-pseudotime)

The ElPiGraph package contains a number of functions to derive the
pseudotime associated with each point. This is particularly relevant in
biological contexts.

Setup
=====

As a first step, we will construct a tree structure on the sample data

    library(ElPiGraph.R)

    TreeEPG <- computeElasticPrincipalTree(X = tree_data, NumNodes = 60, Lambda = .03, Mu = .01,
                                           drawAccuracyComplexity = FALSE, drawEnergy = FALSE)

    ## [1] "Creating a chain in the 1st PC with 2 nodes"
    ## [1] "Constructing tree 1 of 1 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 60 nodes on 492 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 1|2||60  0.01848 60  59  51  2   0   0   0.00548 0.005053    0.9898  0.9906  0.01249 0.0005134   0.03081 1.848   0
    ## 29.923 sec elapsed
    ## [[1]]

![](pseudo_files/figure-markdown_strict/unnamed-chunk-1-1.png)

and visualize the node labels:

    PlotPG(X = tree_data, TargetPG = TreeEPG[[1]],
           NodeLabels = 1:nrow(TreeEPG[[1]]$NodePositions),
           LabMult = 2.5, PointSize = NA, p.alpha = .1)

    ## [[1]]

![](pseudo_files/figure-markdown_strict/unnamed-chunk-2-1.png)

To improve visualization, it is also possible to plot only leaves labels

    library(igraph)

    ## 
    ## Attaching package: 'igraph'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     decompose, spectrum

    ## The following object is masked from 'package:base':
    ## 
    ##     union

    NodeLabs <- 1:nrow(TreeEPG[[1]]$NodePositions)
    NodeLabs[degree(ConstructGraph(TreeEPG[[1]])) != 1] <- NA

    PlotPG(X = tree_data, TargetPG = TreeEPG[[1]],
           NodeLabels = NodeLabs,
           LabMult = 5, PointSize = NA, p.alpha = .1)

    ## [[1]]

![](pseudo_files/figure-markdown_strict/unnamed-chunk-3-1.png)

Getting the substructure of interest
====================================

In this example, we will look at all the path originating in 2 and
extending to all the other leafs of the tree. Hence, we assume that 2 is
the starting points for the pseudotime.

We will begin by computing all of the paths between leaves.

    Tree_Graph <- ConstructGraph(TreeEPG[[1]])
    Tree_e2e <- GetSubGraph(Net = Tree_Graph, Structure = 'end2end')

Since the paths derived are unique, the node 1 could be either at the
beginning or at the end of the path considered. therefore, we select all
the path starting or ending in 1

    Root <- 2
    SelPaths <- Tree_e2e[sapply(Tree_e2e, function(x){any(x[c(1, length(x))] == Root)})]

and reverse the paths ending in 1

    SelPaths <- lapply(SelPaths, function(x){
      if(x[1] == Root){
        return(x)
      } else {
        return(rev(x))
      }
    })

At this point, we can look at `SelPaths` to make sure that the results
are compatible with our expectations

    SelPaths

    ## $Path_1
    ## + 26/60 vertices, named, from 045cf7f:
    ##  [1] 2  8  40 60 16 5  30 52 21 1  57 34 9  47 28 12 19 3  15 18 27 31 35
    ## [24] 36 45 51
    ## 
    ## $Path_2
    ## + 27/60 vertices, named, from 045cf7f:
    ##  [1] 2  8  40 60 16 5  30 52 21 1  57 34 9  47 28 12 19 3  11 17 24 25 42
    ## [24] 43 48 49 54
    ## 
    ## $Path_3
    ## + 28/60 vertices, named, from 045cf7f:
    ##  [1] 2  8  40 60 16 5  30 52 21 1  7  20 44 55 29 37 6  26 13 4  14 22 23
    ## [24] 33 38 41 53 56
    ## 
    ## $Path_4
    ## + 24/60 vertices, named, from 045cf7f:
    ##  [1] 2  8  40 60 16 5  30 52 21 1  57 34 9  47 28 12 19 3  10 32 39 46 50
    ## [24] 58
    ## 
    ## $Path_5
    ## + 21/60 vertices, named, from 045cf7f:
    ##  [1] 2  8  40 60 16 5  30 52 21 1  7  20 44 55 29 37 6  26 13 4  59

Getting the supporting structures
=================================

To optimize the computation, certain structures used to compute the
pseudotime are computed externally. We begin by computing a Partition
structure, which contains information on the projection of points on the
nodes

    PartStruct <- PartitionData(X = tree_data, NodePositions = TreeEPG[[1]]$NodePositions)

Then, we will compute a projection structure, which contains information
relative to the projection of points on the edge of the graph

    ProjStruct <- project_point_onto_graph(X = tree_data,
                                           NodePositions = TreeEPG[[1]]$NodePositions,
                                           Edges = TreeEPG[[1]]$Edges$Edges,
                                           Partition = PartStruct$Partition)

Computing pseudotime
====================

We are now able to obtain the pseudotime, via the `getPseudotime`
function. We will use `lapply` to compute all of the pseudotime at once.
Moreover, the functions requires nodes to be passed as a vector of
strings, so we will need to use the `names` function to convert the
sequence of vertices.

    AllPt <- lapply(SelPaths, function(x){
      getPseudotime(ProjStruct = ProjStruct, NodeSeq = names(x))
    })

At this point, we can merge the pseudotime projections. This is possible
because points are uniquely projected on the graph and all the paths
selected have a common root

    PointsPT <- apply(sapply(AllPt, "[[", "Pt"), 1, function(x){unique(x[!is.na(x)])})

When can then visualize the pseudotime on the points via the `PlotPG`
function

    PlotPG(X = tree_data, TargetPG = TreeEPG[[1]], GroupsLab = PointsPT)

    ## [[1]]

![](pseudo_files/figure-markdown_strict/unnamed-chunk-12-1.png)

Exploring features over pseudotime
==================================

Once the pseudotime has been computed, it is possible to explore how the
different features of the data behave over the psedutime. This feature
is particulartly helpful for gene expression data as it allow checking
how gene dynamics contribute to the topoligical features of the data.

It is possible to visualize this information using the
`CompareOnBranches` function

    CompareOnBranches(X = tree_data,
                      Paths = lapply(SelPaths[1:4], function(x){names(x)}),
                      TargetPG = TreeEPG[[1]],
                      Partition = PartStruct$Partition,
                      PrjStr = ProjStruct,
                      Main = "A simple tree example",
                      Features = 2)

    ## `geom_smooth()` using method = 'loess'

![](pseudo_files/figure-markdown_strict/unnamed-chunk-13-1.png)
