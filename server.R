require(shiny)
require(ggplot2)
require(scales)

source("GetYFData.R")
source("BuildHPRMatrix.R")
source("Markets.R")

convertDates <- function(d) {
  paste(
    month(d),
    day(d),
    year(d),
    sep = "/"
  )
}

# 1/6/2000 - 1/30/2016, monthly, adj. close
VTI <- read.csv("VTI.csv")
VTI <- data.frame(cbind(
  VTI[,2:ncol(VTI)]
))

default_tStart <- "1/6/2000"
default_tEnd <- "1/30/2016"
default_tick <- "VTI"

defaultStock <- read.csv("AAPL.csv")
defaultStock <- data.frame(cbind(
  defaultStock[,2:ncol(defaultStock)]
))

shinyServer(
  function(input, output) {

    # Date range data
    tStart <- reactive({
      if(length(input$daterange) == 0)
      {
        "1/6/2000"
      } else {
        convertDates(as.Date(input$daterange[1]) )
      }
    })

    tEnd <- reactive({
      if(length(input$daterange) == 0)
      {
        "1/30/2016"
      } else {
        convertDates(as.Date(input$daterange[2]) )
      }
    })

    output$tStart <- renderText(tStart())
    output$tEnd <- renderText(tEnd())
    output$tRange <- renderText(paste(tStart(), " to ", tEnd()))

    # Stock data
    dat <- reactive({
      ticker <- toupper(trimws(input$ticker))

      if(is.null(ticker)) {
        defaultStock
      } else if(nchar(ticker) != 0) {
        GetYFData(ticker = input$ticker,
                  start = tStart(),
                  end = tEnd())
      } else { defaultStock }

    })

    # Stock ticker label
    ticklab <- reactive({
      if(nchar(input$ticker) == 0) {
        "AAPL"
      } else { input$ticker }
    })

    # Market index
    MKT <- reactive({
      tick <- with(marketInfo, marketInfo[Label == input$index,1])
      if(tStart() == default_tStart &
        tEnd() == default_tEnd &
        tick == default_tick) {
          VTI } else {
            GetYFData(ticker = tick,
                      start = tStart(),
                      end = tEnd())
      }
    })

    # Market index label

    # Bind price data tables
    custPrices <- reactive({
      t1 <- MKT()[,c(1,7)]
      t2 <- dat()[,c(1,7)]

      bindTables(t1, t2)
    })

    HPRs <- reactive({
      temp <- na.omit(build.HPRMatrix(custPrices()))
      colnames(temp) <- c("date", "index", "stock")
      temp
    })

    lmfit <- reactive({ lm(stock ~ index, data = HPRs()) })


    plotlab <- reactive({
      paste(ticklab(), "Beta =",
              round(coefficients(lmfit())[[2]], 2))
    })


    output$tick <- renderText({ticklab()})

    output$beta <- renderText(coefficients(lmfit())[[2]])
    output$alpha <- renderText(coefficients(lmfit())[[1]])
    output$pval.intercept <- renderText(summary(lmfit())$coefficients[,4][[2]])

    output$pval.interpretation <- renderText({
       if(summary(lmfit())$coefficients[,4][[2]]) {
      paste("The p-value of ",
            format(round(summary(lmfit())$coefficients[,4][[2]], 5), nsmall = 5),
            " is significant at a level of .05. This indicates ",
            " that ",
            percent(exp(coefficients(lmfit())[[1]])-1),
            "  (",
            percent(exp(coefficients(lmfit())[[1]]*12)-1),
            ") of ",
            ticklab(),
            "'s simple monthly (annual) return is not
            explained by the index return.",
            sep = "")
    } else {
      paste("The p-value of ",
            format(round(summary(lmfit())$coefficients[,4][[2]], 5), nsmall = 5),
            " is not significantly different than 0 ",
            " at a significance level of .05. This indicates ",
            " that ",
              ticklab(),
            " has no statistical ",
            "evidence of an alpha value different than 0.",
            sep = ""
      )
    }})

    output$summary <- renderPrint(summary(lmfit()))

    output$plot <- renderPlot(
      ggplot(HPRs(), aes(x = index, y = stock)) +
        geom_point() +
        stat_smooth(method = 'lm') +
        labs(x = input$index, y = ticklab(), title=plotlab()) +
        theme(plot.title = element_text(size = 20),
              axis.title = element_text(size = 15)) +
        scale_x_continuous(labels = percent) +
        scale_y_continuous(labels = percent)
    )
  }
)
