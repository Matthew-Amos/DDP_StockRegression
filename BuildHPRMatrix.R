# Functions
## Builds a matrix of holding period returns. Natural log by default.
## Specify simple.returns = TRUE to get simple returns
build.HPRMatrix <- function(tbl, simple.returns = FALSE, ignore.firstCol = TRUE,...) {
  # Set starting column
  if(ignore.firstCol) stCol = 2 else stCol = 1

  # Caclualte HPRs
  if(simple.returns)
  {
    HPRs <- tbl[1:(nrow(tbl) - 1), stCol:ncol(tbl)] / tbl[2:nrow(tbl), stCol:ncol(tbl)] - 1
  } else
  {
    HPRs <- log(tbl[1:(nrow(tbl) - 1), stCol:ncol(tbl)] / tbl[2:nrow(tbl), stCol:ncol(tbl)])
  }

  # Prepare final table
  if(ignore.firstCol) {
    hpr.mat <- cbind(tbl[1:(nrow(tbl) - 1),1], HPRs)
  } else {
    hpr.mat <- data.frame(HPRs)
  }

  names(hpr.mat) <- names(tbl)

  hpr.mat
}
