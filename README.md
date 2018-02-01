-   [Descrition](#descrition)
-   [Installation](#installation)
-   [Usage](#usage)

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

Usage
=====

Several guides are available to exemplify the behaviour of ElPiGraph.R:

-   [Basic usage](guides/base.md)
-   [Derivation of graph substructures](guides/struct.md)
-   [Derivation and visualization of pseudotime](guides/struct.md)
-   [Usage of the trimming radius](guides/trim.md)
-   [Advanced bootstrapping](guides/boot.md)
-   [Generation of synthetic data](guides/synth.md)
-   [Plotting](guides/plotting.md)
