-   [Descrition](#descrition)
-   [Installation](#installation)
-   [Constructing a principal graph](#constructing-a-principal-graph)
-   [Examples of principal curves](#examples-of-principal-curves)
-   [Using bootstrapping](#using-bootstrapping)
-   [Plotting data with principal
    graphs](#plotting-data-with-principal-graphs)
-   [More info](#more-info)

Descrition
==========

This package provides an R implementation of the ElPiGraph algorithm. A
self-contained description of the algorithm is available
[here](https://github.com/auranic/Elastic-principal-graphs/blob/master/ElPiGraph_Methods.pdf)

A native MATLAB implementation of the algorithm (coded by Andrei
Zinovyev) is also
[available](https://github.com/auranic/Elastic-principal-graphs)

Installation
============

To improve the performance of the algorithm, a number of functions have
been implemented as C++ functions. To simplify the maintenance and
updating of the package, these functions have been implemented in the
package `distutils`, which needs to be installed separately. The
following command will check the presence of the `devtools`, and install
it if necessary, after that it will install the `distutils` package. A
working internet connection is required.

    if(!require("devtools")){
      install.packages("devtools")
    }
    devtools::install_github("Albluca/distutils")  

Once `distutils` has been installed, `ElPiGraph.R` can be installed by
typing

    devtools::install_github("Albluca/ElPiGraph.R")

It is also possible to get the most recent developmental version (which
will contains more feature, but is potentially more unstable) via:

    devtools::install_github("Albluca/ElPiGraph.R", ref = "Development")

The package can then be loaded via the command

    library("ElPiGraph.R")

Constructing a principal graph
==============================

The construction of a principal graph with a given topology is done via
the specification of an appropriate initial conditions and of
appropriate growth/shrink grammars. This can be done via the
`computeElasticPrincipalGraph`.

Specific wrapping functions are also provided to build commonly
encountered topologies (`computeElasticPrincipalCurve`,
\``computeElasticPrincipalTree`, `computeElasticPrincipalCircle`), with
minimal required inputs. In all of these function, it is necessary to
specify a numeric matrix with the data points (`X`) and the number of
nodes to of the principal graph (`NumNodes`). It is possible to control
the behavior of the algorithm via a set of optional parameters. For
example, it is possible to:

-   modify the parameter controlling the elastic energy (`Mu` and
    `Lambda`)
-   specify the number of processor to be used (`n.cores`)
-   indicate if diagnostic plots should be produced
    (`drawAccuracyComplexity` and `drawEnergy`)
-   indicate if the final graph should be used to plotted non the data
    (`drawPCAView`)
-   specify if PCA should be performed on the data prior to principal
    graph fitting (`Do_PCA`) and if dimensionality should be reduced
    (`ReduceDimension`)

Examples of principal curves
============================

The function `computeElasticPrincipalCurve` constructs a principal curve
on the data. For example to construct a principal curve with 50 nodes on
the example dataset `line_data`, it is sufficient to write

    CurveEPG <- computeElasticPrincipalCurve(X = curve_data, NumNodes = 50)

    ## [1] "Creating a chain in the 1st PC with 3 nodes"
    ## [1] "Constructing curve 1 of 1 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 500 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.1163  50  49  48  0   0   0   0.05429 0.05149 0.9819  0.9828  0.05109 0.01088 0.5438  27.19   0
    ## 3.278 sec elapsed

![](README_files/figure-markdown_strict/unnamed-chunk-1-1.png)![](README_files/figure-markdown_strict/unnamed-chunk-1-2.png)

    ## [[1]]

![](README_files/figure-markdown_strict/unnamed-chunk-1-3.png)

A principal tree can be constructed via the
`computeElasticPrincipalTree` function. For example to construct a
principal tree with 50 nodes on the example dataset `tree_data`, it is
sufficient to write

    TreeEPG <- computeElasticPrincipalTree(X = tree_data, NumNodes = 50)

    ## [1] "Creating a chain in the 1st PC with 2 nodes"
    ## [1] "Constructing tree 1 of 1 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 492 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 2 3

    ## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
    ## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
    ## = 0.0556045436349542

    ## 4

    ## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
    ## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
    ## = 0.0301832931960279

    ## 5 6 7

    ## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
    ## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
    ## = 0.0108997004478186

    ## 8

    ## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
    ## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
    ## = 0.0338837538875411

    ## 9

    ## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
    ## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
    ## = 0.0186764499907295

    ## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
    ## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
    ## = 0.054863847452363

    ## 10

    ## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
    ## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
    ## = 0.0244949370624996

    ## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
    ## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
    ## = 0.0117614602046908

    ## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
    ## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
    ## = 0.0358113369806447

    ## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
    ## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
    ## = 0.0139648044782385

    ## 11 12 13

    ## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
    ## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
    ## = 0.0183632027691593

    ## 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 1|2||50  0.01568 50  49  41  2   0   0   0.004137    0.003432    0.9923  0.9936  0.01114 0.0004032   0.02016 1.008   0
    ## 13.732 sec elapsed

![](README_files/figure-markdown_strict/unnamed-chunk-2-1.png)![](README_files/figure-markdown_strict/unnamed-chunk-2-2.png)

    ## [[1]]

![](README_files/figure-markdown_strict/unnamed-chunk-2-3.png)

Finally, a principal circle can be constructed via the
`computeElasticPrincipalCircle` function. For example to construct a
principal circle with 50 nodes on the example dataset `circe_data`, it
is sufficient to write

    CircleEPG <- computeElasticPrincipalCircle(X = circle_data, NumNodes = 50)

    ## [1] "Using a single core"
    ## [1] "Creating a circle in the plane induced buy the 1st and 2nd PCs with 3 nodes"
    ## [1] "Constructing curve 1 of 1 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 200 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.0456  50  50  50  0   0   0   0.02624 0.02528 0.9754  0.9763  0.01754 0.001818    0.09089 4.545   0
    ## 2.69 sec elapsed

![](README_files/figure-markdown_strict/unnamed-chunk-3-1.png)![](README_files/figure-markdown_strict/unnamed-chunk-3-2.png)

    ## [[1]]

![](README_files/figure-markdown_strict/unnamed-chunk-3-3.png)

All of these functions will return a list of length 1, with all the
information associated with the graph.

Using bootstrapping
===================

All of the functions provided to build principal graphs allow a
bootstrapped construction. To enable that it is sufficient to modify the
parameters `nReps` and `ProbPoint`. `nReps` indicates the number of
repetitions and `ProbPoint` indicates the probability to include a point
in each of the repetition. When `nReps` is larger than 1, a final
consensus principal graph will be constructed using the nodes of the
graph derived in each repetition.

As an example, let us perform bootstrapping on the circle data. We will
also prevent the plotting, for now.

    CircleEPG.Boot <- computeElasticPrincipalCircle(X = circle_data, NumNodes = 50, nReps = 50, ProbPoint = .8, drawAccuracyComplexity = FALSE, drawEnergy = FALSE, drawPCAView = FALSE)

    ## [1] "Using a single core"
    ## [1] "Creating a circle in the plane induced buy the 1st and 2nd PCs with 3 nodes"
    ## [1] "Constructing curve 1 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 159 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04482 50  50  50  0   0   0   0.02558 0.02482 0.9758  0.9765  0.01747 0.001777    0.08887 4.443   0
    ## 2.675 sec elapsed
    ## [1] "Constructing curve 2 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 157 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04493 50  50  50  0   0   0   0.02419 0.02339 0.9774  0.9781  0.01818 0.002559    0.128   6.399   0
    ## 2.339 sec elapsed
    ## [1] "Constructing curve 3 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 153 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.0448  50  50  50  0   0   0   0.02544 0.02452 0.9763  0.9772  0.0175  0.001866    0.0933  4.665   0
    ## 2.602 sec elapsed
    ## [1] "Graphical output will be suppressed for the remaining replicas"
    ## [1] "Constructing curve 4 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 154 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04407 50  50  50  0   0   0   0.02478 0.02387 0.9767  0.9776  0.01751 0.001779    0.08897 4.448   0
    ## 2.647 sec elapsed
    ## [1] "Constructing curve 5 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 157 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04523 50  50  50  0   0   0   0.02522 0.02425 0.9764  0.9773  0.01771 0.002295    0.1147  5.737   0
    ## 2.341 sec elapsed
    ## [1] "Constructing curve 6 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 153 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04528 50  50  50  0   0   0   0.02532 0.02449 0.9765  0.9773  0.01802 0.001935    0.09675 4.838   0
    ## 2.6 sec elapsed
    ## [1] "Constructing curve 7 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 157 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04615 50  50  50  0   0   0   0.02575 0.02477 0.9765  0.9774  0.01837 0.002023    0.1011  5.056   0
    ## 2.425 sec elapsed
    ## [1] "Constructing curve 8 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 162 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.045   50  50  50  0   0   0   0.0253  0.0244  0.9766  0.9774  0.01785 0.001846    0.09229 4.615   0
    ## 2.578 sec elapsed
    ## [1] "Constructing curve 9 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 158 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04595 50  50  50  0   0   0   0.02718 0.02632 0.9745  0.9753  0.01739 0.001372    0.06861 3.431   0
    ## 2.64 sec elapsed
    ## [1] "Constructing curve 10 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 152 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04352 50  50  50  0   0   0   0.02413 0.02316 0.9775  0.9784  0.01766 0.001727    0.08635 4.317   0
    ## 2.412 sec elapsed
    ## [1] "Constructing curve 11 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 154 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04354 50  50  50  0   0   0   0.02457 0.02364 0.9768  0.9777  0.01729 0.001677    0.08386 4.193   0
    ## 2.631 sec elapsed
    ## [1] "Constructing curve 12 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 173 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04707 50  50  50  0   0   0   0.02657 0.02562 0.9754  0.9762  0.01812 0.00239 0.1195  5.974   0
    ## 2.685 sec elapsed
    ## [1] "Constructing curve 13 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 169 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04473 50  50  50  0   0   0   0.02617 0.02514 0.9753  0.9762  0.01701 0.001557    0.07786 3.893   0
    ## 2.41 sec elapsed
    ## [1] "Constructing curve 14 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 165 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.0431  50  50  50  0   0   0   0.0242  0.02338 0.9774  0.9782  0.01734 0.001567    0.07837 3.919   0
    ## 2.628 sec elapsed
    ## [1] "Constructing curve 15 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 159 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04417 50  50  50  0   0   0   0.02487 0.02395 0.9768  0.9777  0.01752 0.001782    0.0891  4.455   0
    ## 2.666 sec elapsed
    ## [1] "Constructing curve 16 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 158 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04591 50  50  50  0   0   0   0.02722 0.02624 0.9744  0.9753  0.0172  0.001497    0.07486 3.743   0
    ## 2.406 sec elapsed
    ## [1] "Constructing curve 17 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 161 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04419 50  50  50  0   0   0   0.02567 0.02488 0.9754  0.9761  0.01689 0.001627    0.08133 4.066   0
    ## 2.608 sec elapsed
    ## [1] "Constructing curve 18 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 169 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04383 50  50  50  0   0   0   0.02407 0.02322 0.9773  0.9781  0.01783 0.001929    0.09644 4.822   0
    ## 2.677 sec elapsed
    ## [1] "Constructing curve 19 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 169 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.0439  50  50  50  0   0   0   0.02499 0.02414 0.9768  0.9776  0.01733 0.001578    0.07891 3.946   0
    ## 2.436 sec elapsed
    ## [1] "Constructing curve 20 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 156 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04431 50  50  50  0   0   0   0.02568 0.02478 0.9754  0.9762  0.01695 0.001684    0.08422 4.211   0
    ## 2.606 sec elapsed
    ## [1] "Constructing curve 21 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 161 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04771 50  50  50  0   0   0   0.02777 0.02678 0.9741  0.975   0.0178  0.002147    0.1074  5.368   0
    ## 2.663 sec elapsed
    ## [1] "Constructing curve 22 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 160 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04152 50  50  50  0   0   0   0.02247 0.02167 0.9791  0.9799  0.01749 0.00156 0.07802 3.901   0
    ## 2.703 sec elapsed
    ## [1] "Constructing curve 23 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 158 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04297 50  50  50  0   0   0   0.02314 0.02219 0.9789  0.9797  0.01798 0.001842    0.09212 4.606   0
    ## 2.389 sec elapsed
    ## [1] "Constructing curve 24 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 164 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04611 50  50  50  0   0   0   0.02716 0.02624 0.9742  0.975   0.0171  0.001849    0.09246 4.623   0
    ## 2.661 sec elapsed
    ## [1] "Constructing curve 25 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 153 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04334 50  50  50  0   0   0   0.02478 0.02392 0.9766  0.9774  0.01704 0.001523    0.07613 3.807   0
    ## 2.678 sec elapsed
    ## [1] "Constructing curve 26 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 165 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04724 50  50  50  0   0   0   0.02841 0.02754 0.9732  0.974   0.01727 0.00157 0.07851 3.926   0
    ## 2.406 sec elapsed
    ## [1] "Constructing curve 27 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 156 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04747 50  50  50  0   0   0   0.02676 0.02593 0.9753  0.9761  0.01833 0.002384    0.1192  5.96    0
    ## 2.647 sec elapsed
    ## [1] "Constructing curve 28 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 165 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04479 50  50  50  0   0   0   0.02559 0.02464 0.9758  0.9767  0.01731 0.001897    0.09485 4.743   0
    ## 2.685 sec elapsed
    ## [1] "Constructing curve 29 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 159 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.0449  50  50  50  0   0   0   0.02551 0.0246  0.9757  0.9766  0.01741 0.001982    0.0991  4.955   0
    ## 2.414 sec elapsed
    ## [1] "Constructing curve 30 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 153 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04804 50  50  50  0   0   0   0.0284  0.02755 0.9733  0.9741  0.01758 0.002056    0.1028  5.14    0
    ## 2.647 sec elapsed
    ## [1] "Constructing curve 31 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 161 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04526 50  50  50  0   0   0   0.0251  0.02416 0.9768  0.9776  0.01825 0.001907    0.09536 4.768   0
    ## 2.68 sec elapsed
    ## [1] "Constructing curve 32 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 161 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04344 50  50  50  0   0   0   0.02477 0.02387 0.9764  0.9772  0.0169  0.001763    0.08816 4.408   0
    ## 2.45 sec elapsed
    ## [1] "Constructing curve 33 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 168 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04383 50  50  50  0   0   0   0.02341 0.02248 0.9777  0.9786  0.01798 0.00244 0.122   6.099   0
    ## 2.648 sec elapsed
    ## [1] "Constructing curve 34 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 163 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04582 50  50  50  0   0   0   0.02604 0.02514 0.9759  0.9767  0.01786 0.001923    0.09616 4.808   0
    ## 2.69 sec elapsed
    ## [1] "Constructing curve 35 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 158 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04454 50  50  50  0   0   0   0.0256  0.02473 0.9753  0.9761  0.01699 0.001948    0.0974  4.87    0
    ## 2.45 sec elapsed
    ## [1] "Constructing curve 36 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 157 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04452 50  50  50  0   0   0   0.02628 0.02535 0.9751  0.976   0.01682 0.001432    0.07162 3.581   0
    ## 2.626 sec elapsed
    ## [1] "Constructing curve 37 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 166 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04345 50  50  50  0   0   0   0.02454 0.0236  0.9773  0.9782  0.01732 0.00159 0.07952 3.976   0
    ## 2.683 sec elapsed
    ## [1] "Constructing curve 38 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 155 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04101 50  50  50  0   0   0   0.02127 0.02032 0.9798  0.9807  0.01772 0.002025    0.1013  5.063   0
    ## 2.698 sec elapsed
    ## [1] "Constructing curve 39 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 161 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04321 50  50  50  0   0   0   0.0241  0.0231  0.9773  0.9782  0.01742 0.001693    0.08465 4.232   0
    ## 2.429 sec elapsed
    ## [1] "Constructing curve 40 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 158 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04477 50  50  50  0   0   0   0.02472 0.02373 0.9771  0.978   0.01803 0.002023    0.1011  5.057   0
    ## 2.679 sec elapsed
    ## [1] "Constructing curve 41 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 154 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04516 50  50  50  0   0   0   0.02634 0.0255  0.9753  0.9761  0.01727 0.001543    0.07716 3.858   0
    ## 2.699 sec elapsed
    ## [1] "Constructing curve 42 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 164 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04407 50  50  50  0   0   0   0.02455 0.02349 0.9766  0.9776  0.01767 0.001854    0.09271 4.635   0
    ## 2.763 sec elapsed
    ## [1] "Constructing curve 43 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 168 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04594 50  50  50  0   0   0   0.02605 0.02509 0.9753  0.9762  0.01741 0.002488    0.1244  6.219   0
    ## 2.437 sec elapsed
    ## [1] "Constructing curve 44 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 156 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04506 50  50  50  0   0   0   0.02629 0.0255  0.9749  0.9757  0.01722 0.00156 0.07798 3.899   0
    ## 2.684 sec elapsed
    ## [1] "Constructing curve 45 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 165 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.0453  50  50  50  0   0   0   0.02679 0.0261  0.9747  0.9754  0.01699 0.001517    0.07584 3.792   0
    ## 2.713 sec elapsed
    ## [1] "Constructing curve 46 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 159 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04529 50  50  50  0   0   0   0.02535 0.0244  0.9763  0.9771  0.01777 0.00217 0.1085  5.425   0
    ## 2.758 sec elapsed
    ## [1] "Constructing curve 47 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 155 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04422 50  50  50  0   0   0   0.02474 0.02387 0.9769  0.9777  0.01781 0.001664    0.08322 4.161   0
    ## 2.687 sec elapsed
    ## [1] "Constructing curve 48 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 148 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04633 50  50  50  0   0   0   0.02647 0.02553 0.9755  0.9764  0.01809 0.001774    0.08872 4.436   0
    ## 2.439 sec elapsed
    ## [1] "Constructing curve 49 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 162 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04367 50  50  50  0   0   0   0.02435 0.02341 0.9768  0.9777  0.01749 0.001823    0.09115 4.558   0
    ## 2.701 sec elapsed
    ## [1] "Constructing curve 50 of 50 / Subset 1 of 1"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 160 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.04276 50  50  50  0   0   0   0.02393 0.02306 0.9778  0.9786  0.01744 0.001395    0.06973 3.486   0
    ## 2.691 sec elapsed
    ## [1] "Constructing average tree"
    ## [1] "Performing PCA on the data"
    ## [1] "Using standard PCA"
    ## [1] "3 dimensions are being used"
    ## [1] "100% of the original variance has been retained"
    ## [1] "Computing EPG with 50 nodes on 2500 points and 3 dimensions"
    ## [1] "Using a single core"
    ## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
    ## BARCODE  ENERGY  NNODES  NEDGES  NRIBS   NSTARS  NRAYS   NRAYS2  MSE MSEP    FVE FVEP    UE  UR  URN URN2    URSD
    ## 0||50    0.01901 50  50  50  0   0   0   0.002392    0.001676    0.9976  0.9983  0.0161  0.0005186   0.02593 1.296   0
    ## 4.767 sec elapsed

`CircleEPG.Boot` will be a list with 51 elements: the 50 bootstrapped
circles and the final consensus one.

Plotting data with principal graphs
===================================

The `ElPiGraph.R` provides different functions to explore show how the
principal graph approximate the data. The main function is `plotPG`.
This function can be used to show how the principal graph fit the data
in different ways.

To plot the principal tree previously constructed we can type

    PlotPG(X = tree_data, TargetPG = TreeEPG[[1]], Main = "A tree")

    ## [[1]]

![](README_files/figure-markdown_strict/unnamed-chunk-5-1.png)

The main plot reports different features including the percentage of
variance explained relative to the nodes of the principal graph (PG
var), the percentage of variance explained relative to the data points
(Data var), the fraction of variance of the data explained by the nodes
of the principal graph (FVE) and the fraction of variance of the data
explained by the projection of the points on the the principal graph
(FVEP). In this example the nodes of the principal graph have been used
to compute PCA and rotate the space (the Do\_PCA parameter is TRUE be
default), this can be seen by the "EpG PC" label of the axes.

To include additional dimension in the plot it is sufficient to specify
them with the DimToPlot parameter, e.g.,

    PlotPG(X = tree_data, TargetPG = TreeEPG[[1]], Main = "A tree", DimToPlot = 1:3)

    ## [[1]]

![](README_files/figure-markdown_strict/unnamed-chunk-6-1.png)

    ## 
    ## [[2]]

![](README_files/figure-markdown_strict/unnamed-chunk-6-2.png)

    ## 
    ## [[3]]

![](README_files/figure-markdown_strict/unnamed-chunk-6-3.png)

We can also visualize the results of the bootstrapped construction by
using the `BootPG` parameter:

    PlotPG(X = circle_data, TargetPG = CircleEPG.Boot[[length(CircleEPG.Boot)]],
           BootPG = CircleEPG.Boot[1:(length(CircleEPG.Boot)-1)],
           Main = "A bootstrapped circle", DimToPlot = 1:2)

    ## [[1]]

![](README_files/figure-markdown_strict/unnamed-chunk-7-1.png)

More info
=========

Additional details on the derivation of
[substructures](guides/struct.md) and on the use of
[pseudotime](guides/pseudo.md) derivation are also available
