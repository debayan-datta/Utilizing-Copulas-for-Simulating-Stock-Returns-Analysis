# Quant Copula Playground: Simulating Stock Returns Analysis with Copulas
<div align="center">
  <a href="https://freakonometrics.hypotheses.org/files/2010/10/copula-density-proj_m-300x188.jpg">
    <img src="https://freakonometrics.hypotheses.org/files/2010/10/copula-density-proj_m-300x188.jpg" alt="" width="300" height="300">
  </a>
</div>

[Link to App](https://maxmlang.shinyapps.io/copula-playground/)
## Overview

The Quant Copula Playground is a Shiny application designed for financial analysts, researchers, and enthusiasts interested in exploring the dependencies between stock returns using various copula models. It leverages the power of copulas to model and simulate the joint distribution of stock returns, offering insights beyond traditional correlation measures. This application is inspired by seminal works in the field of copulas, particularly "An Introduction to Copulas" by Roger B. Nelsen.

## Features

- Selection of stock pairs from a predefined list for analysis.
- Comparison of actual stock return distributions against simulated distributions using selected copula models.
- Interactive selection of copula types including Gaussian, Frank, Clayton, Gumbel, Joe, and Ali-Mikhail-Haq copulas, along with their rotated versions.
- Date range selection for historical data analysis.
- Visualization of correlation and simulated versus actual return distributions.

## Installation

To run the Quant Copula Playground locally, you will need R installed on your system along with the Shiny, quantmod, copula, ggplot2, ggExtra, and shinythemes packages. Follow these steps:

1. Install R from [CRAN](https://cran.r-project.org/).
2. Open R and install the necessary packages using the following commands:

```r
install.packages("shiny")
install.packages("quantmod")
install.packages("copula")
install.packages("ggplot2")
install.packages("ggExtra")
install.packages("shinythemes")
```

3. Clone this repository to your local machine.
4. Set your working directory to the repository's location and run the app with the following R commands:

```r
setwd("path/to/repository")
shiny::runApp()
```

## Usage

Upon launching the Quant Copula Playground, follow these steps to analyze stock returns:

1. Select the first and second stock from the dropdown menus.
2. Choose a copula type to model the dependency structure between the selected stocks.
3. Set the start and end dates for historical data analysis.
4. The application will display the correlation coefficient and generate plots comparing real and simulated correlated returns.

## Acknowledgements

This project is inspired by "An Introduction to Copulas" by Roger B. Nelsen. The application aims to make complex statistical concepts in finance more accessible through interactive visualization and simulation. Special thanks to the authors and contributors of the R packages used in this project, which made this application possible.

## References

- Nelsen, R. B. (2006). *An Introduction to Copulas*. Springer.
- The developers and contributors of the Shiny, quantmod, copula, ggplot2, ggExtra, and shinythemes packages.
