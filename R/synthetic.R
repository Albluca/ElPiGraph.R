#' Initialize a group of 'walkers'
#'
#' @param Number integer, the number of walkers to be inizialised
#' @param Dimensions integer, the number of dimensions of the walkers
#' @param MeanShift numeric, the mean shift in each dimension for the walker 
#' @param SdShift positive numeric, the standard deviation in the shift in each dimension for the walker 
#'
#' @return A list with the walkers
#' @export
#'
#' @examples
#' 
#' Walkers <- InizializeWalkers(Dimensions = 1000)
#' 
InizializeWalkers <- function(Number = 1,
                              Dimensions = 3,
                              MeanShift = 1,
                              SdShift = .3) {
  
  RetList <- list()
  
  for(i in 1:Number){
    RetList[[i]] <- list(
      nDim = Dimensions,
      Positions = rep(0, Dimensions),
      DiffusionShift = sample(c(-1, 1), Dimensions, TRUE) * rnorm(Dimensions, MeanShift, SdShift),
      Name = i,
      Age = 0
    )
  }
  
  return(RetList)
}





#' Grow a branching path using walkers
#'
#' @param Walkers list, a list of walker as returned from the InizializeWalkers function
#' @param StepSize positive numeric, the standard deviation associated with the movement
#' in each direction for each step
#' @param nSteps integer, the number of steps 
#' @param BranchProb numeric between 0 and 1, the probability per walker of branching at each step 
#' @param MinAgeBr integer, the minimal number of steps before a newly introduced walker will start branhing
#' @param BrDim integer, the number of dimensions affected during branching
#'
#' @return
#' @export
#'
#' @examples
#' 
#' Walkers <- InizializeWalkers(nDim = 1000)
#' 
#' Data <- GrowPath(Walkers = Walkers, StepSize = 50, nSteps = 2000, BranchProb = .0015, MinAgeBr = 75, BrDim = 15)
#' 
GrowPath <- function(Walkers,
                     StepSize = .1,
                     nSteps = 100,
                     BranchProb = .01,
                     MinAgeBr = 50,
                     BrDim = 5) {
  
  Trace <- matrix(0, nrow = 0, ncol = length(Walkers[[1]]$Pos))
  Branch = NULL
  
  while(nrow(Trace) < nSteps){
    nWalkers <- length(Walkers)
    for(j in 1:nWalkers){
      # Create a new point by diffusion
      Walkers[[j]]$Pos <- Walkers[[j]]$Pos + Walkers[[j]]$Dif + rnorm(n = Walkers[[j]]$nDim, sd = StepSize)
      Trace <- rbind(Trace, Walkers[[j]]$Pos)
      # In crese the age of the walker
      Walkers[[j]]$Age <- Walkers[[j]]$Age + 1
      # Keep Track of the originating population
      Branch <- c(Branch, Walkers[[j]]$Name)
      if(runif(1) < BranchProb & Walkers[[j]]$Age >= MinAgeBr){
        # Create a new branch
        BranchDim <- runif(n = Walkers[[j]]$nDim) < BrDim/Walkers[[j]]$nDim
        if(any(BranchDim) & !all(BranchDim)){
          cat("Time=", nrow(Trace), " Branching in ", sum(BranchDim), " dimensions \n")
          
          Walkers[[j]]$Age <- 0
          Walkers[[j]]$Name <- max(sapply(Walkers, "[[", "Name")) + 1
          
          NewBuild <- Walkers[[j]]
          NewBuild$Age <- 0
          NewBuild$Dif[BranchDim] <- -NewBuild$Dif[BranchDim]
          NewBuild$Name <- Walkers[[j]]$Name +1
          Walkers[[length(Walkers)+1]] <- NewBuild
        }
      }
    }
  }
  
  return(list(UpdatedWalker = Walkers, Trace = Trace, Branch = Branch))
  
}














