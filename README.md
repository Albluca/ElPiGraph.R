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
## 3.3 sec elapsed
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
## 13.609 sec elapsed
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
## 2.581 sec elapsed
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
## [1] "Computing EPG with 50 nodes on 162 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04419	50	50	50	0	0	0	0.02523	0.02421	0.9762	0.9771	0.01738	0.001584	0.07918	3.959	0
## 2.639 sec elapsed
## [1] "Constructing curve 2 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 159 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04671	50	50	50	0	0	0	0.02678	0.02596	0.9749	0.9757	0.01791	0.002017	0.1008	5.041	0
## 2.33 sec elapsed
## [1] "Constructing curve 3 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 163 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04497	50	50	50	0	0	0	0.02514	0.02433	0.9766	0.9774	0.01769	0.002141	0.1071	5.353	0
## 2.552 sec elapsed
## [1] "Graphical output will be suppressed for the remaining replicas"
## [1] "Constructing curve 4 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 146 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04596	50	50	50	0	0	0	0.02684	0.02591	0.9745	0.9754	0.01736	0.001765	0.08823	4.412	0
## 2.6 sec elapsed
## [1] "Constructing curve 5 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 155 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04586	50	50	50	0	0	0	0.02708	0.02629	0.9741	0.9749	0.0171	0.001678	0.08388	4.194	0
## 2.347 sec elapsed
## [1] "Constructing curve 6 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 150 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04374	50	50	50	0	0	0	0.02346	0.0226	0.978	0.9788	0.01805	0.002229	0.1114	5.572	0
## 2.594 sec elapsed
## [1] "Constructing curve 7 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 162 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04356	50	50	50	0	0	0	0.02455	0.02365	0.9769	0.9778	0.01734	0.00167	0.08351	4.176	0
## 2.635 sec elapsed
## [1] "Constructing curve 8 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 158 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04526	50	50	50	0	0	0	0.02528	0.02439	0.9764	0.9772	0.01791	0.002064	0.1032	5.159	0
## 2.359 sec elapsed
## [1] "Constructing curve 9 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 150 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04531	50	50	50	0	0	0	0.02608	0.02518	0.9754	0.9762	0.01727	0.001959	0.09797	4.898	0
## 2.584 sec elapsed
## [1] "Constructing curve 10 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 153 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04565	50	50	50	0	0	0	0.02667	0.02579	0.9754	0.9762	0.01734	0.001644	0.08222	4.111	0
## 2.628 sec elapsed
## [1] "Constructing curve 11 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 143 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04357	50	50	50	0	0	0	0.0229	0.02203	0.9789	0.9797	0.01839	0.002275	0.1138	5.688	0
## 2.356 sec elapsed
## [1] "Constructing curve 12 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 158 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04309	50	50	50	0	0	0	0.025	0.02402	0.976	0.9769	0.01669	0.001399	0.06995	3.498	0
## 2.597 sec elapsed
## [1] "Constructing curve 13 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 160 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04657	50	50	50	0	0	0	0.02738	0.02646	0.9746	0.9755	0.01744	0.001747	0.08733	4.366	0
## 2.644 sec elapsed
## [1] "Constructing curve 14 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 163 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04291	50	50	50	0	0	0	0.02371	0.02292	0.978	0.9787	0.01753	0.001677	0.08385	4.193	0
## 2.362 sec elapsed
## [1] "Constructing curve 15 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 167 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04688	50	50	50	0	0	0	0.02737	0.02649	0.9741	0.9749	0.01741	0.002101	0.105	5.252	0
## 2.617 sec elapsed
## [1] "Constructing curve 16 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 173 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04518	50	50	50	0	0	0	0.02588	0.02498	0.976	0.9768	0.01749	0.001812	0.09062	4.531	0
## 2.667 sec elapsed
## [1] "Constructing curve 17 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 154 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04506	50	50	50	0	0	0	0.02524	0.02432	0.9764	0.9773	0.01783	0.001983	0.09915	4.958	0
## 2.366 sec elapsed
## [1] "Constructing curve 18 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 166 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04442	50	50	50	0	0	0	0.0242	0.02325	0.9773	0.9782	0.01795	0.002275	0.1138	5.689	0
## 2.6 sec elapsed
## [1] "Constructing curve 19 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 160 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04653	50	50	50	0	0	0	0.02584	0.02501	0.9755	0.9763	0.01821	0.002477	0.1238	6.192	0
## 2.663 sec elapsed
## [1] "Constructing curve 20 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 164 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04388	50	50	50	0	0	0	0.02509	0.02429	0.9761	0.9769	0.01708	0.001702	0.08512	4.256	0
## 2.389 sec elapsed
## [1] "Constructing curve 21 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 159 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04238	50	50	50	0	0	0	0.02265	0.02183	0.9785	0.9793	0.0177	0.002023	0.1011	5.056	0
## 2.583 sec elapsed
## [1] "Constructing curve 22 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 161 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04174	50	50	50	0	0	0	0.02245	0.02152	0.9791	0.98	0.01759	0.001691	0.08453	4.226	0
## 2.637 sec elapsed
## [1] "Constructing curve 23 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 172 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.0443	50	50	50	0	0	0	0.02542	0.02441	0.9759	0.9769	0.0171	0.00178	0.089	4.45	0
## 2.438 sec elapsed
## [1] "Constructing curve 24 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 157 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04364	50	50	50	0	0	0	0.02391	0.02303	0.9777	0.9785	0.01778	0.001947	0.09735	4.867	0
## 2.586 sec elapsed
## [1] "Constructing curve 25 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 157 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04594	50	50	50	0	0	0	0.0259	0.02506	0.9761	0.9768	0.01807	0.001973	0.09864	4.932	0
## 2.628 sec elapsed
## [1] "Constructing curve 26 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 159 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04644	50	50	50	0	0	0	0.02688	0.02585	0.9749	0.9758	0.01749	0.002074	0.1037	5.185	0
## 2.401 sec elapsed
## [1] "Constructing curve 27 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 163 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04623	50	50	50	0	0	0	0.02622	0.02522	0.9754	0.9764	0.01798	0.002026	0.1013	5.064	0
## 2.59 sec elapsed
## [1] "Constructing curve 28 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 167 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04634	50	50	50	0	0	0	0.02649	0.02558	0.9755	0.9763	0.018	0.001856	0.09279	4.639	0
## 2.638 sec elapsed
## [1] "Constructing curve 29 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 152 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04419	50	50	50	0	0	0	0.02519	0.02434	0.9762	0.977	0.01723	0.001771	0.08854	4.427	0
## 2.413 sec elapsed
## [1] "Constructing curve 30 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 159 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04512	50	50	50	0	0	0	0.02582	0.02483	0.9761	0.977	0.01754	0.001757	0.08786	4.393	0
## 2.586 sec elapsed
## [1] "Constructing curve 31 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 162 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04484	50	50	50	0	0	0	0.02468	0.02378	0.977	0.9778	0.01803	0.002135	0.1067	5.337	0
## 2.659 sec elapsed
## [1] "Constructing curve 32 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 164 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04654	50	50	50	0	0	0	0.02606	0.0251	0.9758	0.9767	0.01807	0.002413	0.1207	6.033	0
## 2.663 sec elapsed
## [1] "Constructing curve 33 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 156 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.046	50	50	50	0	0	0	0.02613	0.02517	0.9758	0.9767	0.01816	0.001713	0.08566	4.283	0
## 2.363 sec elapsed
## [1] "Constructing curve 34 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 152 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04125	50	50	50	0	0	0	0.02163	0.02085	0.9794	0.9801	0.01764	0.001978	0.09888	4.944	0
## 2.623 sec elapsed
## [1] "Constructing curve 35 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 165 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04257	50	50	50	0	0	0	0.023	0.02194	0.9783	0.9793	0.01766	0.001909	0.09545	4.772	0
## 2.669 sec elapsed
## [1] "Constructing curve 36 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 160 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04735	50	50	50	0	0	0	0.02758	0.02659	0.9744	0.9753	0.01767	0.002097	0.1048	5.242	0
## 2.378 sec elapsed
## [1] "Constructing curve 37 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 156 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04633	50	50	50	0	0	0	0.02612	0.02521	0.9755	0.9763	0.01782	0.002385	0.1192	5.962	0
## 2.605 sec elapsed
## [1] "Constructing curve 38 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 174 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04448	50	50	50	0	0	0	0.025	0.02418	0.9767	0.9775	0.0176	0.001876	0.09379	4.689	0
## 2.658 sec elapsed
## [1] "Constructing curve 39 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 162 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04608	50	50	50	0	0	0	0.02626	0.02536	0.9751	0.976	0.01758	0.00225	0.1125	5.625	0
## 2.635 sec elapsed
## [1] "Constructing curve 40 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 164 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04453	50	50	50	0	0	0	0.0261	0.02524	0.9753	0.9762	0.01708	0.001344	0.0672	3.36	0
## 2.377 sec elapsed
## [1] "Constructing curve 41 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 150 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04358	50	50	50	0	0	0	0.02442	0.02359	0.9772	0.9779	0.01758	0.001579	0.07894	3.947	0
## 2.609 sec elapsed
## [1] "Constructing curve 42 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 169 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04531	50	50	50	0	0	0	0.02586	0.02499	0.976	0.9768	0.01753	0.001918	0.09588	4.794	0
## 2.648 sec elapsed
## [1] "Constructing curve 43 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 155 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04498	50	50	50	0	0	0	0.02668	0.02573	0.9747	0.9756	0.0167	0.001594	0.07968	3.984	0
## 2.623 sec elapsed
## [1] "Constructing curve 44 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 154 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04655	50	50	50	0	0	0	0.0274	0.02659	0.9738	0.9746	0.01705	0.002094	0.1047	5.234	0
## 2.352 sec elapsed
## [1] "Constructing curve 45 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 157 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.0432	50	50	50	0	0	0	0.02323	0.02221	0.9786	0.9795	0.01805	0.001921	0.09605	4.802	0
## 2.603 sec elapsed
## [1] "Constructing curve 46 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 163 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04432	50	50	50	0	0	0	0.02388	0.02288	0.9775	0.9784	0.01791	0.002527	0.1264	6.319	0
## 2.623 sec elapsed
## [1] "Constructing curve 47 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 160 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04643	50	50	50	0	0	0	0.02734	0.02645	0.9742	0.975	0.0172	0.001891	0.09455	4.728	0
## 2.391 sec elapsed
## [1] "Constructing curve 48 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 162 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04477	50	50	50	0	0	0	0.02557	0.02469	0.9758	0.9767	0.01732	0.001885	0.09425	4.713	0
## 2.557 sec elapsed
## [1] "Constructing curve 49 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 158 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04417	50	50	50	0	0	0	0.02575	0.02482	0.9763	0.9772	0.01704	0.001371	0.06856	3.428	0
## 2.588 sec elapsed
## [1] "Constructing curve 50 of 50 / Subset 1 of 1"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 167 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.04559	50	50	50	0	0	0	0.02411	0.02325	0.9779	0.9786	0.01878	0.002695	0.1348	6.738	0
## 2.629 sec elapsed
## [1] "Constructing average tree"
## [1] "Performing PCA on the data"
## [1] "Using standard PCA"
## [1] "3 dimensions are being used"
## [1] "100% of the original variance has been retained"
## [1] "Computing EPG with 50 nodes on 2500 points and 3 dimensions"
## [1] "Using a single core"
## Nodes = 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 
## BARCODE	ENERGY	NNODES	NEDGES	NRIBS	NSTARS	NRAYS	NRAYS2	MSE	MSEP	FVE	FVEP	UE	UR	URN	URN2	URSD
## 0||50	0.01896	50	50	50	0	0	0	0.002306	0.001621	0.9977	0.9984	0.0161	0.0005492	0.02746	1.373	0
## 4.597 sec elapsed
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

Additional details on the derivation of [substructures](/guides/) and on the use of [pseudotime](guides/struct.md) derivation are also available
