require(shiny)

source("Markets.R")

shinyUI(fluidPage(
  titlePanel(textOutput("tick")),
  h3(textOutput("tRange")),

  sidebarLayout(
    sidebarPanel(
      "Enter a single ticker below",
      textInput(inputId="ticker", label="Stock Ticker", placeholder="e.g. AAPL, HP, RE"),
      selectInput("index","Market Index",
                  c("VTI - Total U.S. Stock Market Index",
                    "VOO - U.S. S&P 500",
                    "VT - Total World Stock Market Index",
                    "VXUS - International Stock excl. U.S.",
                    "VGK - Developed Europe Stock Index",
                    "VPL - Developed Asia Pacific Stock Index"
                  )),
      dateRangeInput("daterange",
                     "Timeframe",
                     start = "2006-01-06",
                     end = "2016-01-30"),
      submitButton("Run Regression")
    ),

    mainPanel(
      tabsetPanel(
        tabPanel("Beta",
                 plotOutput("plot"),
                 br(), br(),
                 em(p("Plotted returns are a natural log transformation inclusive of dividends"))
        ),
        tabPanel("Alpha",
                 strong("Alpha"),
                 textOutput("alpha"),
                 strong("p-value"),
                 textOutput("pval.intercept"),
                 br(),
                 textOutput("pval.interpretation")
        ),
        tabPanel("Full Summary Statistics",
                 verbatimTextOutput("summary")
        ),
        tabPanel("Documentation",
                 h4("Useful Links"),
                 p(a(href="https://investor.vanguard.com/etf/list","ETFs", target="_blank"), " | ",
                   a(href="http://www.google.com/finance/","Google Finance", target="_blank"), " | ",
                   a(href="http://finance.yahoo.com/", "Yahoo! Finance", target="_blank"), " | ",
                   a(href="http://www.investopedia.com/terms/b/beta.asp","Beta Explained", target="_blank"), " | ",
                   a(href="http://www.investopedia.com/terms/a/alpha.asp", "Alpha Explained", target="_blank")),

                 h4("Project Commentary"),
                 strong("What is it?"),
                 p("This Shiny app calculates the popular Beta and Alpha statistics for
            stock returns (explained below)."),
                 strong("How do I use it?"),
                 p("Enter a single stock ticker -- you can reference websites such as
            Google and Yahoo! Finance to get the ticker for a particular company.
            Select an appropriate market index to compare the stock to and specify
            the timeframe for which you'd like to pull the monthly holding period
            returns."),
                p("By default Apple (AAPL) is compared against Vanguard's Total U.S. Market
            Index for the time period ranging from January 6, 2006 to January 30, 2016."),

                 h4("Statistical Parameters"),
                 h5('Stock "Beta"'),
                 p("Beta represents the expected asset return given price movements
            in an underlying index. For instance, a beta of 1.20 would indicate that
            for every 1% an index appreciates, one would expect a 1.20% return
            in the given stock."),
                 h5('Stock "Alpha"'),
                 p("Alpha is the return performance of an asset as compared to an index, or
            in other words the excess return. An alpha value of 2% for instance indicates
            that 2% of the stock returns were not directly attributable to
            returns in the broader index.")
        )
      )
    )
  )
))
