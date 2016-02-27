


Shiny App: Getting "Beta" and "Alpha" for a stock
========================================================
author: equinaut
date: 2-24-2016

Useful Statistics for Stock Returns
========================================================

**Beta** and **Alpha** are two commonly referenced statistics
to describe a stock's return. *Beta* is a measure of volatility:
how much a stock's return is influenced by movements in a broader
index. *Alpha* is a measure of excess (positive or negative) return
not explained by that index.

Both of these parameters can be derived from the regression of
the stock's **Holding Period Returns (HPRs)** against a given market index's
HPRs.

Sample Regression - Apple, VTI:
========================================================

Below we get our estimates by regressing Apple's (AAPL)
monthly HPRs against Vanguard's Total U.S. Stock Market
Index's (VTI) HPRs for the period ranging from Jan 2006
to Jan 2016.


```r
regression <- lm(AAPL ~ VTI, data = HPRs)
coefficients(regression)
```

```
(Intercept)         VTI 
-0.01323424  1.28336998 
```

The slope of the regression is our *beta*, while the intercept
is *alpha*.


Shiny App: Run, Visualize
========================================================

This Shiny App allows you to quickly run and visualize
this analysis. Users may enter any valid stock ticker they wish
for any time period and compare it against a variety of indices.

![plot of chunk unnamed-chunk-3](StockRegressionPitch-figure/unnamed-chunk-3-1.png)


Resources
========================================================

**Project**

Shiny App: https://equinaut.shinyapps.io/StockPriceRegression/

GitHub Repo: https://github.com/equinaut/DDP_StockRegression

**Financial Data & Info**

Stocks - http://www.google.com/finance/

Vanguard ETFs - https://investor.vanguard.com/etf/list



