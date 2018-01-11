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
## 3.264 sec elapsed
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
## = 0.0556045436349542
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
## = 0.0108997004478186
```

```
## 8
```

```
## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
## = 0.0338837538875411
```

```
## 9
```

```
## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
## = 0.0186764499907295
```

```
## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
## = 0.054863847452363
```

```
## 10
```

```
## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
## = 0.0244949370624996
```

```
## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
## = 0.0117614602046908
```

```
## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
## = 0.0358113369806447
```

```
## Warning in PrimitiveElasticGraphEmbedment(X, input$NodePositions, input
## $ElasticMatrix, : Maximum number of iterations (10) has been reached. diff
## = 0.0139648044782385
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
## 13.464 sec elapsed
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
## 2.621 sec elapsed
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
## [1] "Computing EPG with 50 nodes on 167 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04488	50	50	50	0	0	0	0.02484	0.02395	0.9769	0.9777	0.01787	0.002162	0.1081	5.404	0
## 2.639 sec elapsed
## [1] "Constructing curve 2 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 171 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04427	50	50	50	0	0	0	0.02416	0.02319	0.9774	0.9783	0.01805	0.002063	0.1031	5.156	0
## 2.385 sec elapsed
## [1] "Constructing curve 3 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 164 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04559	50	50	50	0	0	0	0.02565	0.02473	0.976	0.9768	0.01774	0.002191	0.1095	5.476	0
## 2.564 sec elapsed
## [1] "Graphical output will be suppressed for the remaining replicas"
## [1] "Constructing curve 4 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 164 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04512	50	50	50	0	0	0	0.02436	0.02325	0.9769	0.9779	0.01824	0.002515	0.1257	6.287	0
## 2.623 sec elapsed
## [1] "Constructing curve 5 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 152 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04352	50	50	50	0	0	0	0.02351	0.02268	0.9779	0.9787	0.01792	0.002088	0.1044	5.22	0
## 2.388 sec elapsed
## [1] "Constructing curve 6 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 164 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04709	50	50	50	0	0	0	0.02773	0.02685	0.9742	0.975	0.01749	0.001873	0.09367	4.683	0
## 2.571 sec elapsed
## [1] "Constructing curve 7 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 169 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04408	50	50	50	0	0	0	0.02526	0.02438	0.9762	0.977	0.0171	0.00172	0.08602	4.301	0
## 2.641 sec elapsed
## [1] "Constructing curve 8 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 157 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04535	50	50	50	0	0	0	0.02437	0.02352	0.9772	0.9779	0.01849	0.002495	0.1247	6.236	0
## 2.361 sec elapsed
## [1] "Constructing curve 9 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 167 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04552	50	50	50	0	0	0	0.02654	0.02558	0.9748	0.9757	0.01722	0.001757	0.08787	4.393	0
## 2.583 sec elapsed
## [1] "Constructing curve 10 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 161 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04651	50	50	50	0	0	0	0.0258	0.02492	0.9761	0.9769	0.01816	0.002552	0.1276	6.379	0
## 2.638 sec elapsed
## [1] "Constructing curve 11 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 160 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04469	50	50	50	0	0	0	0.02571	0.02483	0.9756	0.9765	0.01715	0.001834	0.09169	4.585	0
## 2.35 sec elapsed
## [1] "Constructing curve 12 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 169 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04492	50	50	50	0	0	0	0.02552	0.0246	0.9764	0.9773	0.01771	0.001701	0.08503	4.252	0
## 2.613 sec elapsed
## [1] "Constructing curve 13 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 163 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04263	50	50	50	0	0	0	0.02381	0.02294	0.9776	0.9784	0.01726	0.001564	0.07819	3.91	0
## 2.66 sec elapsed
## [1] "Constructing curve 14 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 167 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04603	50	50	50	0	0	0	0.02761	0.02668	0.9737	0.9746	0.01685	0.001561	0.07805	3.902	0
## 2.374 sec elapsed
## [1] "Constructing curve 15 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 166 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04518	50	50	50	0	0	0	0.02596	0.02519	0.9756	0.9763	0.01752	0.001705	0.08523	4.261	0
## 2.638 sec elapsed
## [1] "Constructing curve 16 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 163 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04572	50	50	50	0	0	0	0.02594	0.02513	0.9758	0.9765	0.01783	0.001945	0.09726	4.863	0
## 2.666 sec elapsed
## [1] "Constructing curve 17 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 150 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04283	50	50	50	0	0	0	0.02367	0.02292	0.9776	0.9783	0.0174	0.00176	0.08798	4.399	0
## 2.374 sec elapsed
## [1] "Constructing curve 18 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 167 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04485	50	50	50	0	0	0	0.02617	0.02526	0.9755	0.9763	0.01709	0.001597	0.07984	3.992	0
## 2.631 sec elapsed
## [1] "Constructing curve 19 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 159 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04649	50	50	50	0	0	0	0.02643	0.02544	0.9753	0.9762	0.01789	0.002167	0.1083	5.416	0
## 2.673 sec elapsed
## [1] "Constructing curve 20 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 164 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.0444	50	50	50	0	0	0	0.02552	0.02467	0.9761	0.9769	0.01739	0.001492	0.07462	3.731	0
## 2.4 sec elapsed
## [1] "Constructing curve 21 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 158 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04356	50	50	50	0	0	0	0.0247	0.02383	0.9768	0.9776	0.01714	0.001719	0.08597	4.298	0
## 2.618 sec elapsed
## [1] "Constructing curve 22 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 163 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04281	50	50	50	0	0	0	0.02429	0.02351	0.977	0.9777	0.01705	0.001471	0.07354	3.677	0
## 2.676 sec elapsed
## [1] "Constructing curve 23 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 164 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04575	50	50	50	0	0	0	0.0255	0.02458	0.9761	0.977	0.018	0.002251	0.1125	5.627	0
## 2.393 sec elapsed
## [1] "Constructing curve 24 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 158 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04319	50	50	50	0	0	0	0.02295	0.02192	0.979	0.9799	0.01827	0.001971	0.09853	4.927	0
## 2.621 sec elapsed
## [1] "Constructing curve 25 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 162 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04435	50	50	50	0	0	0	0.02485	0.024	0.9766	0.9774	0.01779	0.001717	0.08586	4.293	0
## 2.676 sec elapsed
## [1] "Constructing curve 26 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 167 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04258	50	50	50	0	0	0	0.02287	0.02193	0.979	0.9799	0.01784	0.001872	0.09361	4.68	0
## 2.446 sec elapsed
## [1] "Constructing curve 27 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 159 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04172	50	50	50	0	0	0	0.02204	0.02112	0.9797	0.9805	0.01786	0.001825	0.09125	4.562	0
## 2.618 sec elapsed
## [1] "Constructing curve 28 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 163 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04544	50	50	50	0	0	0	0.02555	0.02446	0.9757	0.9767	0.01767	0.002222	0.1111	5.555	0
## 2.676 sec elapsed
## [1] "Constructing curve 29 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 156 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04468	50	50	50	0	0	0	0.02596	0.02508	0.9751	0.976	0.01707	0.001658	0.08289	4.145	0
## 2.462 sec elapsed
## [1] "Constructing curve 30 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 162 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04432	50	50	50	0	0	0	0.02448	0.02352	0.9777	0.9786	0.018	0.001831	0.09155	4.577	0
## 2.589 sec elapsed
## [1] "Constructing curve 31 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 164 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.0452	50	50	50	0	0	0	0.02545	0.02459	0.9764	0.9772	0.0179	0.001851	0.09255	4.628	0
## 2.66 sec elapsed
## [1] "Constructing curve 32 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 154 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.0438	50	50	50	0	0	0	0.02323	0.02236	0.9778	0.9787	0.01797	0.002596	0.1298	6.491	0
## 2.712 sec elapsed
## [1] "Constructing curve 33 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 159 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04749	50	50	50	0	0	0	0.02742	0.0266	0.9739	0.9747	0.0176	0.002466	0.1233	6.164	0
## 2.387 sec elapsed
## [1] "Constructing curve 34 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 159 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04692	50	50	50	0	0	0	0.0275	0.02643	0.9748	0.9758	0.0177	0.001719	0.08597	4.299	0
## 2.633 sec elapsed
## [1] "Constructing curve 35 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 164 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04327	50	50	50	0	0	0	0.02357	0.02267	0.978	0.9788	0.0178	0.001895	0.09475	4.737	0
## 2.685 sec elapsed
## [1] "Constructing curve 36 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 158 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04364	50	50	50	0	0	0	0.02478	0.02392	0.9771	0.9779	0.0173	0.001555	0.07774	3.887	0
## 2.738 sec elapsed
## [1] "Constructing curve 37 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 159 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04623	50	50	50	0	0	0	0.02665	0.02579	0.9752	0.9761	0.01766	0.001909	0.09544	4.772	0
## 2.407 sec elapsed
## [1] "Constructing curve 38 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 147 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04467	50	50	50	0	0	0	0.02582	0.02481	0.9757	0.9766	0.0173	0.001552	0.07762	3.881	0
## 2.638 sec elapsed
## [1] "Constructing curve 39 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 165 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04507	50	50	50	0	0	0	0.02638	0.0255	0.9748	0.9757	0.01713	0.001559	0.07797	3.898	0
## 2.706 sec elapsed
## [1] "Constructing curve 40 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 165 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04716	50	50	50	0	0	0	0.02705	0.02611	0.975	0.9759	0.01804	0.00206	0.103	5.15	0
## 2.736 sec elapsed
## [1] "Constructing curve 41 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 157 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04523	50	50	50	0	0	0	0.02468	0.02376	0.9774	0.9782	0.01833	0.00222	0.111	5.55	0
## 2.657 sec elapsed
## [1] "Constructing curve 42 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 154 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04372	50	50	50	0	0	0	0.02468	0.02376	0.9776	0.9784	0.0176	0.001443	0.07213	3.606	0
## 2.408 sec elapsed
## [1] "Constructing curve 43 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 152 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04764	50	50	50	0	0	0	0.02689	0.02607	0.9752	0.9759	0.01826	0.002484	0.1242	6.21	0
## 2.681 sec elapsed
## [1] "Constructing curve 44 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 151 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04453	50	50	50	0	0	0	0.02429	0.02339	0.977	0.9778	0.0178	0.002448	0.1224	6.121	0
## 2.697 sec elapsed
## [1] "Constructing curve 45 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 156 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.0435	50	50	50	0	0	0	0.02482	0.02406	0.9764	0.9771	0.01695	0.001726	0.08631	4.316	0
## 2.44 sec elapsed
## [1] "Constructing curve 46 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 155 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04704	50	50	50	0	0	0	0.02718	0.02629	0.9749	0.9757	0.01778	0.002084	0.1042	5.21	0
## 2.662 sec elapsed
## [1] "Constructing curve 47 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 159 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04618	50	50	50	0	0	0	0.0272	0.02628	0.9745	0.9753	0.01724	0.001738	0.0869	4.345	0
## 2.675 sec elapsed
## [1] "Constructing curve 48 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 160 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04283	50	50	50	0	0	0	0.02368	0.0226	0.9779	0.9789	0.01755	0.001611	0.08054	4.027	0
## 2.728 sec elapsed
## [1] "Constructing curve 49 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 161 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04478	50	50	50	0	0	0	0.02662	0.02573	0.9748	0.9756	0.01681	0.001349	0.06746	3.373	0
## 2.685 sec elapsed
## [1] "Constructing curve 50 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 162 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04408	50	50	50	0	0	0	0.02327	0.02237	0.9785	0.9793	0.01856	0.002254	0.1127	5.634	0
## 2.449 sec elapsed
## [1] "Constructing average tree"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 2500 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.01912	50	50	50	0	0	0	0.002443	0.001675	0.9976	0.9984	0.01612	0.0005582	0.02791	1.396	0
## 4.732 sec elapsed
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

# More info

Additional details on the derivation of [substructures](guides/struct.md) and on the use of [pseudotime](guides/pseudo.md) derivation are also available
