#### Matthew Amos
# Libraries
library(lubridate)
library(plyr)

# - Financial Data

### Imports financial data from Yahoo! Finance
GetYFData <- function(ticker = "AAPL", start = "1/1/2010", end = "1/1/2015", period="Monthly")
{
  sDate <- as.POSIXlt(start, format = "%m/%d/%Y")
  eDate <- as.POSIXlt(end, format = "%m/%d/%Y")

  # ----------------------------- VALIDATION -----------------------
  # PERIOD
  period <- validatePeriodParam(period)
  # ----------------------------------------------------------------

  file <- build.YahooURL(ticker, sDate, eDate, period)
  data <- read.csv(file, header = TRUE)
  data
}

### Return matrix of price returns.
## Date | Ticker A | Ticker B
build.PriceMatrix <- function(tickers = c("AAPL", "GE", "HP"),
                             start = "1/1/2010",
                             end = "1/1/2015",
                             period = "Monthly",
                             column = "Adjusted")
{
  sDate <- as.POSIXlt(start, format = "%m/%d/%Y")
  eDate <- as.POSIXlt(end, format = "%m/%d/%Y")

  # ----------------------------- VALIDATION -----------------------
  # PERIOD
  period <- validatePeriodParam(period)

  # COLUMN
  if(period != "V") column <- validateColumnParam(column)

  # Dividends
  if(period == "V" && column != 2) column = 2
  # ----------------------------------------------------------------

  header <- c("Date", tickers)

  firstiteration = TRUE
  for(i in 1:length(tickers))
  {

    temp <- GetYFData(tickers[i], start, end, period)
    if(firstiteration)
    {
      data <- cbind(temp[1], temp[column])
      firstiteration = FALSE
    } else
    {
      data <- bindTables(data, cbind(temp[1], temp[column]))
    }
    temp <- c()
  }

  names(data) <- header

  data
}

## Adds column vector to existing table
## Contemplates only the 1st and last new col
bindTables <- function(old, new)
{
  old <- as.vector(old)
  new <- as.vector(new)

  # Truncate new and old
  if(ncol(old) > 1) old.t <- data.frame(t(old[,2:ncol(old)]))
  new.t <- data.frame(t(new[,ncol(new)]))

  temp <- data.frame(t(rbind.fill(old.t, new.t)))

  if(ncol(old) > 1)
  {
    if(nrow(old) > nrow(new)) fcol <- old[,1]
    if(nrow(new) > nrow(old)) fcol <- new[,1]
    if(nrow(new) == nrow(old)) fcol <- old[,1]
    temp <- data.frame(cbind(fcol, temp))
  }

  temp
}

## Builds Y!F url to .csv price data
build.YahooURL <- function(ticker, sDate, eDate, period)
{
  baseurl <- "http://real-chart.finance.yahoo.com/table.csv?"

  YFUrl <- paste(
    baseurl,
    "s=",
    ticker,
    "&a=",
    formatC(month(sDate) - 1, width = 2, format = "d", flag = 0),
    "&b=",
    formatC(day(sDate), width = 2, format = "d", flag = 0),
    "&c=",
    year(sDate),
    "&d=",
    formatC(month(eDate) - 1, width = 2, format = "d", flag = 0),
    "&e=",
    formatC(day(eDate), width = 2, format = "d", flag = 0),
    "&f=",
    year(eDate),
    "&g=",
    tolower(period),
    "&ignore=.csv", sep = "")
  YFUrl
}

## Excecutes grep on vector
findMatch <- function(vector, pattern, ignoreCase = TRUE)
{
  found = FALSE

  for(i in 1:length(vector))
  {
    if(!is.na(grep(vector[i], pattern, ignore.case = ignoreCase)[1]))
    {
      found = TRUE
      break
    }
  }

  found
}

## Returns match index numberm
findMatchIndex <- function(vector, pattern, ignoreCase = TRUE)
{
  for(i in 1:length(vector))
  {
    if(!is.na(grep(vector[i], pattern, ignore.case = ignoreCase)[1]))
    {
      # Found. add 1 to compensate for date column
      ind = i + 1
      break
    }
  }

  ind
}

## ------- VALIDATION FUNCTIONS -----------
## Validates period parameter
validatePeriodParam <- function(period)
{
  period = trimws(toupper(period))
  if(nchar(period) > 1)
  {
    period = switch(period,
                    "DAILY" = "D",
                    "WEEKLY" = "W",
                    "MONTHLY" = "M",
                    "DIVIDEND" = "V",
                    stop("Invalid period. Choose D, W, M or V."))
  } else
  {
    if(!any(period == c("D", "W","M","V"))) { stop("Invalid period. Choose D, W, M or V.") }
  }
  period
}

## Validates character column parameter
validateColumnParam <- function(column)
{
  if(is.numeric(column))
  {
    if(column < 2 || column > 7) { stop("Column number invalid. Please select 2-7 (inclusive).") }

    column
  } else
  {
    cols <- c("OPEN", "HIGH", "LOW", "CLOSE", "VOLUME", "ADJUSTED")
    matchFound <- findMatch(cols, column)

    if(!matchFound) stop("Please enter a valid column.")

    column <- findMatchIndex(cols, column)
  }
}
