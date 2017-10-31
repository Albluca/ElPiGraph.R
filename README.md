# ElPiGraph.R
[Luca Albergante](mailto:luca.albergante@gmail.com)  
November 2017  



# Descrition

This package provides an R implementation of the ElPiGraph algorithm. A self-contained description of the algorithm is available [here](https://github.com/auranic/Elastic-principal-graphs/blob/master/ElPiGraph_Methods.pdf)

A native MATLAB implementation of the algorithm (coded by Andrei Zinovyev) is also [available](https://github.com/auranic/Elastic-principal-graphs)

# Installation

To improve the performance of the algorithm, a number of functions have been implemented as C++ functions. To simplify the maintenance and updating of the package, these functions have been implemented in the package `distutils`, which needs to be installed separately. The following command will check the presence of the `devtools`, and install it if necessary, after that it will install the `distutils` package. A working internet connection is required.


```r
if(!require("devtools")){
  install.packages("devtools")
}
devtools::install_github("Albluca/distutils")  
```

Once `distutils` has been installed, `ElPiGraph.R` can be installed by typing 


```r
devtools::install_github("Albluca/ElPiGraph.R")
```

the package can then be loaded via the command


```r
library("ElPiGraph.R")
```

# Constructing a principal graph

The construction of a principal graph with a given topology is done via the specification of an appropriate initial conditions and of appropriate growth/shrink grammars. This can be done via the `computeElasticPrincipalGraph`.

Specific wrapping functions are also provided to build commonly encountered topologies (`computeElasticPrincipalCurve`, ``computeElasticPrincipalTree`, `computeElasticPrincipalCircle`), with minimal required inputs. In all of these function, it is necessary to specify a numeric matrix with the data points (`X`) and the number of nodes to of the principal graph (`NumNodes`). It is possible to control the behavior of the algorithm via a set of optional parameters. For example, it is possible to:

* modify the parameter controlling the elastic energy (`Mu` and `Lambda`)
* specify the number of processor to be used (`n.cores`)
* indicate if diagnostic plots should be produced (`drawAccuracyComplexity` and `drawEnergy`)
* indicate if the final graph should be used to plotted non the data (`drawPCAView`)
* specify if PCA should be performed on the data prior to principal graph fitting (`Do_PCA`) and if dimensionality  should be reduced (`ReduceDimension`)

# Examples of principal curves

The function `computeElasticPrincipalCurve` constructs a principal curve on the data. For example to construct a principal curve with 50 nodes on the example dataset `line_data`, it is sufficient to write


```r
CurveEPG <- computeElasticPrincipalCurve(X = curve_data, NumNodes = 50)
```

```
## [1] "Creating a chain in the 1st PC with 3 nodes"
## [1] "Constructing curve 1 of 1 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 500 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.1163	50	49	48	0	0	0	0.05429	0.05149	0.9819	0.9828	0.05109	0.01088	0.5438	27.19	0
## 2.144 sec elapsed
```

![](README_files/figure-html/unnamed-chunk-1-1.png)<!-- -->![](README_files/figure-html/unnamed-chunk-1-2.png)<!-- -->

```
## [[1]]
```

![](README_files/figure-html/unnamed-chunk-1-3.png)<!-- -->

A principal tree can be constructed via the `computeElasticPrincipalTree` function. For example to construct a principal tree with 50 nodes on the example dataset `tree_data`, it is sufficient to write


```r
TreeEPG <- computeElasticPrincipalTree(X = tree_data, NumNodes = 50)
```

```
## [1] "Creating a chain in the 1st PC with 2 nodes"
## [1] "Constructing tree 1 of 1 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 492 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 2 3
```

```
## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
## = 0.0556045436349549
```

```
## 4
```

```
## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
## = 0.0301832931960279
```

```
## 5 6 7
```

```
## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
## = 0.0108997004478185
```

```
## 8
```

```
## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
## = 0.033883753887541
```

```
## 9
```

```
## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
## = 0.0186764499907289
```

```
## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
## = 0.054863847452364
```

```
## 10
```

```
## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
## = 0.0244949370624991
```

```
## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
## = 0.0117614602046905
```

```
## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
## = 0.0358113369806443
```

```
## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
## = 0.0139648044782379
```

```
## 11 12 13
```

```
## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
## = 0.0183632027691593
```

```
## 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 1|2||50	0.01568	50	49	41	2	0	0	0.004137	0.003432	0.9923	0.9936	0.01114	0.0004032	0.02016	1.008	0
## 7.277 sec elapsed
```

![](README_files/figure-html/unnamed-chunk-2-1.png)<!-- -->![](README_files/figure-html/unnamed-chunk-2-2.png)<!-- -->

```
## [[1]]
```

![](README_files/figure-html/unnamed-chunk-2-3.png)<!-- -->


Finally, a principal circle can be constructed via the `computeElasticPrincipalCircle` function. For example to construct a principal circle with 50 nodes on the example dataset `circe_data`, it is sufficient to write



```r
CircleEPG <- computeElasticPrincipalCircle(X = circle_data, NumNodes = 50)
```

```
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
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.0456	50	50	50	0	0	0	0.02624	0.02528	0.9754	0.9763	0.01754	0.001818	0.09089	4.545	0
## 1.393 sec elapsed
```

![](README_files/figure-html/unnamed-chunk-3-1.png)<!-- -->![](README_files/figure-html/unnamed-chunk-3-2.png)<!-- -->

```
## [[1]]
```

![](README_files/figure-html/unnamed-chunk-3-3.png)<!-- -->


All of these functions will return a list of length 1, with all the information associated with the graph.

# Using bootstrapping

All of the functions provided to build principal graphs allow a bootstrapped construction. To enable that it is sufficient to modify the parameters `nReps` and `ProbPoint`. `nReps` indicates the number of repetitions and `ProbPoint` indicates the probability to include a point in each of the repetition. When `nReps` is larger than 1, a final consensus principal graph will be constructed using the nodes of the graph derived in each repetition.

As an example, let us perform bootstrapping on the circle data. We will also prevent the plotting, for now.


```r
CircleEPG.Boot <- computeElasticPrincipalCircle(X = circle_data, NumNodes = 50, nReps = 50, ProbPoint = .8, drawAccuracyComplexity = FALSE, drawEnergy = FALSE, drawPCAView = FALSE)
```

```
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
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04457	50	50	50	0	0	0	0.02647	0.02566	0.9744	0.9751	0.01646	0.001634	0.08172	4.086	0
## 1.403 sec elapsed
## [1] "Constructing curve 2 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 165 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04317	50	50	50	0	0	0	0.02462	0.02381	0.9771	0.9778	0.01721	0.001345	0.06723	3.362	0
## 1.232 sec elapsed
## [1] "Constructing curve 3 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 162 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04435	50	50	50	0	0	0	0.02494	0.02402	0.9771	0.9779	0.01776	0.001643	0.08216	4.108	0
## 1.361 sec elapsed
## [1] "Graphical output will be suppressed for the remaining replicas"
## [1] "Constructing curve 4 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 158 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04516	50	50	50	0	0	0	0.02532	0.02443	0.9762	0.977	0.01778	0.002056	0.1028	5.139	0
## 1.391 sec elapsed
## [1] "Constructing curve 5 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 163 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04504	50	50	50	0	0	0	0.02673	0.02592	0.9747	0.9755	0.01683	0.001477	0.07387	3.694	0
## 1.404 sec elapsed
## [1] "Constructing curve 6 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 158 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04257	50	50	50	0	0	0	0.02338	0.02254	0.9783	0.9791	0.01755	0.001644	0.0822	4.11	0
## 1.29 sec elapsed
## [1] "Constructing curve 7 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 168 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04451	50	50	50	0	0	0	0.02474	0.02365	0.9766	0.9776	0.01756	0.002216	0.1108	5.539	0
## 1.431 sec elapsed
## [1] "Constructing curve 8 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 162 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.0456	50	50	50	0	0	0	0.02659	0.02579	0.9752	0.976	0.01736	0.001645	0.08225	4.113	0
## 1.25 sec elapsed
## [1] "Constructing curve 9 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 160 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04508	50	50	50	0	0	0	0.02622	0.02531	0.9753	0.9762	0.01743	0.001432	0.07159	3.579	0
## 1.338 sec elapsed
## [1] "Constructing curve 10 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 155 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04346	50	50	50	0	0	0	0.02491	0.02397	0.9763	0.9772	0.01692	0.001629	0.08144	4.072	0
## 1.378 sec elapsed
## [1] "Constructing curve 11 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 149 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04445	50	50	50	0	0	0	0.02319	0.0222	0.9782	0.9791	0.01863	0.002633	0.1316	6.582	0
## 1.264 sec elapsed
## [1] "Constructing curve 12 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 157 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04416	50	50	50	0	0	0	0.02424	0.02331	0.9777	0.9785	0.01793	0.001997	0.09984	4.992	0
## 1.534 sec elapsed
## [1] "Constructing curve 13 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 164 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04383	50	50	50	0	0	0	0.02358	0.02262	0.9782	0.9791	0.01816	0.002085	0.1042	5.212	0
## 1.358 sec elapsed
## [1] "Constructing curve 14 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 152 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04559	50	50	50	0	0	0	0.02516	0.02424	0.9767	0.9776	0.01812	0.002314	0.1157	5.785	0
## 1.278 sec elapsed
## [1] "Constructing curve 15 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 163 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04436	50	50	50	0	0	0	0.02563	0.02479	0.9759	0.9767	0.01709	0.001633	0.08163	4.082	0
## 1.501 sec elapsed
## [1] "Constructing curve 16 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 165 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04074	50	50	50	0	0	0	0.0224	0.02159	0.9793	0.98	0.01711	0.001227	0.06136	3.068	0
## 1.582 sec elapsed
## [1] "Constructing curve 17 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 145 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.0448	50	50	50	0	0	0	0.02593	0.02509	0.9759	0.9766	0.0171	0.001766	0.0883	4.415	0
## 1.31 sec elapsed
## [1] "Constructing curve 18 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 160 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04221	50	50	50	0	0	0	0.02307	0.02211	0.9782	0.9791	0.01751	0.001637	0.08185	4.092	0
## 1.449 sec elapsed
## [1] "Constructing curve 19 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 151 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04367	50	50	50	0	0	0	0.02407	0.02313	0.9773	0.9781	0.01755	0.002055	0.1028	5.139	0
## 1.541 sec elapsed
## [1] "Constructing curve 20 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 160 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04719	50	50	50	0	0	0	0.0275	0.02653	0.9745	0.9754	0.01776	0.001927	0.09634	4.817	0
## 1.308 sec elapsed
## [1] "Constructing curve 21 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 161 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04616	50	50	50	0	0	0	0.02618	0.02514	0.9755	0.9765	0.01781	0.002162	0.1081	5.406	0
## 1.481 sec elapsed
## [1] "Constructing curve 22 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 162 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04427	50	50	50	0	0	0	0.02525	0.02434	0.9767	0.9776	0.01736	0.001662	0.08312	4.156	0
## 1.481 sec elapsed
## [1] "Constructing curve 23 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 162 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04474	50	50	50	0	0	0	0.02555	0.02461	0.9759	0.9768	0.01755	0.001648	0.08239	4.12	0
## 1.351 sec elapsed
## [1] "Constructing curve 24 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 164 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04719	50	50	50	0	0	0	0.02759	0.02679	0.974	0.9747	0.01741	0.002195	0.1097	5.487	0
## 1.477 sec elapsed
## [1] "Constructing curve 25 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 158 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04425	50	50	50	0	0	0	0.02536	0.02455	0.9761	0.9769	0.01729	0.0016	0.07998	3.999	0
## 1.517 sec elapsed
## [1] "Constructing curve 26 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 163 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04443	50	50	50	0	0	0	0.02597	0.02511	0.9755	0.9763	0.0169	0.001558	0.0779	3.895	0
## 1.436 sec elapsed
## [1] "Constructing curve 27 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 161 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04532	50	50	50	0	0	0	0.02652	0.02569	0.9752	0.976	0.0173	0.001504	0.07522	3.761	0
## 1.524 sec elapsed
## [1] "Constructing curve 28 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 156 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04348	50	50	50	0	0	0	0.02449	0.02351	0.9769	0.9778	0.01724	0.001747	0.08734	4.367	0
## 1.523 sec elapsed
## [1] "Constructing curve 29 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 152 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04686	50	50	50	0	0	0	0.0276	0.0267	0.974	0.9748	0.01745	0.001806	0.09028	4.514	0
## 2.166 sec elapsed
## [1] "Constructing curve 30 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 171 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04348	50	50	50	0	0	0	0.02447	0.0236	0.9771	0.978	0.01749	0.001513	0.07563	3.781	0
## 1.741 sec elapsed
## [1] "Constructing curve 31 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 163 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04617	50	50	50	0	0	0	0.02675	0.02584	0.9748	0.9757	0.01747	0.001946	0.09732	4.866	0
## 1.919 sec elapsed
## [1] "Constructing curve 32 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 161 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04532	50	50	50	0	0	0	0.02438	0.02349	0.9771	0.9779	0.01831	0.002633	0.1317	6.583	0
## 1.406 sec elapsed
## [1] "Constructing curve 33 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 157 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04384	50	50	50	0	0	0	0.02466	0.0238	0.9767	0.9775	0.01723	0.001943	0.09715	4.857	0
## 1.345 sec elapsed
## [1] "Constructing curve 34 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 162 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04433	50	50	50	0	0	0	0.02416	0.02327	0.9772	0.9781	0.01796	0.002203	0.1101	5.507	0
## 1.498 sec elapsed
## [1] "Constructing curve 35 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 162 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04614	50	50	50	0	0	0	0.02662	0.0257	0.9748	0.9757	0.0175	0.002025	0.1012	5.062	0
## 1.523 sec elapsed
## [1] "Constructing curve 36 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 155 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04583	50	50	50	0	0	0	0.02709	0.02619	0.9749	0.9757	0.01739	0.001348	0.0674	3.37	0
## 1.239 sec elapsed
## [1] "Constructing curve 37 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 158 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04206	50	50	50	0	0	0	0.02419	0.02327	0.9773	0.9782	0.01669	0.001191	0.05955	2.978	0
## 1.491 sec elapsed
## [1] "Constructing curve 38 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 169 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04255	50	50	50	0	0	0	0.02328	0.02236	0.9781	0.9789	0.01745	0.00182	0.09099	4.549	0
## 1.549 sec elapsed
## [1] "Constructing curve 39 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 158 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04411	50	50	50	0	0	0	0.02443	0.02363	0.9775	0.9782	0.01788	0.001802	0.09011	4.505	0
## 1.385 sec elapsed
## [1] "Constructing curve 40 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 167 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04508	50	50	50	0	0	0	0.02572	0.02485	0.9753	0.9761	0.01731	0.002041	0.102	5.102	0
## 1.672 sec elapsed
## [1] "Constructing curve 41 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 168 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04555	50	50	50	0	0	0	0.02595	0.02488	0.9756	0.9766	0.01771	0.001895	0.09475	4.738	0
## 1.415 sec elapsed
## [1] "Constructing curve 42 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 164 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04586	50	50	50	0	0	0	0.02612	0.02527	0.9756	0.9764	0.01767	0.002068	0.1034	5.17	0
## 1.374 sec elapsed
## [1] "Constructing curve 43 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 157 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04175	50	50	50	0	0	0	0.02273	0.0218	0.9791	0.98	0.01753	0.001492	0.0746	3.73	0
## 1.862 sec elapsed
## [1] "Constructing curve 44 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 162 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04692	50	50	50	0	0	0	0.02625	0.02537	0.9755	0.9764	0.01831	0.002359	0.118	5.898	0
## 1.433 sec elapsed
## [1] "Constructing curve 45 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 168 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04336	50	50	50	0	0	0	0.02423	0.02323	0.9774	0.9783	0.01729	0.001848	0.0924	4.62	0
## 1.437 sec elapsed
## [1] "Constructing curve 46 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 162 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04167	50	50	50	0	0	0	0.02294	0.02205	0.9785	0.9793	0.01706	0.001657	0.08286	4.143	0
## 1.284 sec elapsed
## [1] "Constructing curve 47 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 174 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04709	50	50	50	0	0	0	0.02765	0.02674	0.9737	0.9746	0.01753	0.001916	0.09579	4.789	0
## 1.37 sec elapsed
## [1] "Constructing curve 48 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 166 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04625	50	50	50	0	0	0	0.02599	0.02506	0.976	0.9769	0.01812	0.002139	0.107	5.349	0
## 1.398 sec elapsed
## [1] "Constructing curve 49 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 157 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04588	50	50	50	0	0	0	0.02518	0.02432	0.9771	0.9779	0.01846	0.002232	0.1116	5.58	0
## 1.27 sec elapsed
## [1] "Constructing curve 50 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 161 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04473	50	50	50	0	0	0	0.02533	0.02443	0.9764	0.9772	0.01767	0.001727	0.08636	4.318	0
## 1.386 sec elapsed
## [1] "Constructing average tree"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 2500 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.01897	50	50	50	0	0	0	0.002358	0.001629	0.9977	0.9984	0.0161	0.0005168	0.02584	1.292	0
## 2.591 sec elapsed
```

`CircleEPG.Boot` will be a list with 51 elements: the 50 bootstrapped circles and the final consensus one.

# Plotting data with principal graphs

The `ElPiGraph.R` provides different functions to explore show how the principal graph approximate the data. The main function is `plotPG`. This function can be used to show how the principal graph fit the data in different ways.

To plot the principal tree previously constructed we can type


```r
PlotPG(X = tree_data, TargetPG = TreeEPG[[1]], Main = "A tree")
```

```
## [[1]]
```

![](README_files/figure-html/unnamed-chunk-5-1.png)<!-- -->

The main plot reports different features including the percentage of variance explained relative to the nodes of the principal graph (PG var), the percentage of variance explained relative to the data points (Data var), the fraction of variance of the data explained by the nodes of the principal graph (FVE) and the fraction of variance of the data explained by the projection of the points on the the principal graph (FVEP). In this example the nodes of the principal graph have been used to compute PCA and rotate the space (the Do_PCA parameter is TRUE be default), this can be seen by the "EpG PC" label of the axes.

To include additional dimension in the plot it is sufficient to specify them with the DimToPlot parameter, e.g.,


```r
PlotPG(X = tree_data, TargetPG = TreeEPG[[1]], Main = "A tree", DimToPlot = 1:3)
```

```
## [[1]]
```

![](README_files/figure-html/unnamed-chunk-6-1.png)<!-- -->

```
## 
## [[2]]
```

![](README_files/figure-html/unnamed-chunk-6-2.png)<!-- -->

```
## 
## [[3]]
```

![](README_files/figure-html/unnamed-chunk-6-3.png)<!-- -->

We can also visualize the results of the bootstrapped construction by using the `BootPG` parameter:


```r
PlotPG(X = circle_data, TargetPG = CircleEPG.Boot[[length(CircleEPG.Boot)]],
       BootPG = CircleEPG.Boot[1:(length(CircleEPG.Boot)-1)],
       Main = "A bootstrapped circle", DimToPlot = 1:2)
```

```
## [[1]]
```

![](README_files/figure-html/unnamed-chunk-7-1.png)<!-- -->


