library(shiny)
library(quantmod)
library(copula)
library(ggplot2)
library(ggExtra)
library(shinythemes)
symbols_df <- read.csv("data/ticker_data.csv")
symbol_vectors <- symbols_df[["Symbol"]]
names(symbol_vectors) <- symbols_df[["Name"]]
# UI ----
ui <- fluidPage(
  theme = shinytheme("sandstone"),
  titlePanel("Utilizing Copulas for Simulating Stock Returns Analysis"),
  sidebarLayout(
    sidebarPanel(
      selectInput("stock1", "Select first stock:", choices = symbol_vectors, selectize = TRUE, selected = symbol_vectors[symbol_vectors == "AAPL"]),
      selectInput("stock2", "Select second stock:", choices = symbol_vectors, selectize = TRUE, selected = symbol_vectors[symbol_vectors == "MSFT"]),
      selectInput("copula_type", "Select copula type:",
                  choices = list("Gaussian" = "gaussian",
                                 "Frank" = "frank",
                                 "Clayton" = "clayton",
                                 "Gumbel" = "gumbel",
                                 "Joe" = "joe",
                                 "Ali-Mikhail-Haq" = "amh",
                                 "Copula with rotated versions" = "rotated"), # Example addition
                  selected = "gaussian"),
      dateInput("start_date", "Start date:", value = Sys.Date() - 365), # Yesterday one year ago
      dateInput("end_date", "End date:", value = Sys.Date() - 1)
    ),
    mainPanel(
      textOutput("correlationText"),
      plotOutput("combinedPlot"),
      br(),
      br(),
      br(),
      br(),
      code("Made by Anurag Debayan Diptesh Samapan "),
      #tags$a(href= "https://github.com/MaxMLang", icon("github", "fa-2x"))
    )
  )
)

# Server logic ----
server <- function(input, output) {
  # Reactive expression for fetching and preparing data
  returns_data_reactive <- reactive({
    stock1 <- input$stock1
    stock2 <- input$stock2
    start_date <- input$start_date
    end_date <- input$end_date
    
    if (is.null(stock1) || is.null(stock2)) {
      if (!is.null(previous_returns_data)) {
        return(previous_returns_data)  
      }
    }
    
    # Fetch historical data
    stock1_data <- getSymbols(stock1, src = "yahoo", from = start_date, to = end_date, auto.assign = FALSE)
    stock2_data <- getSymbols(stock2, src = "yahoo", from = start_date, to = end_date, auto.assign = FALSE)
    
    # Calculate daily returns for each stock
    returns_stock1 <- dailyReturn(stock1_data, type = "log")
    returns_stock2 <- dailyReturn(stock2_data, type = "log")
    
    # Prepare and return the merged returns data
    returns_data <- merge(returns_stock1, returns_stock2)
    colnames(returns_data) <- c(stock1, stock2)
    previous_returns_data <<- returns_data
    returns_data
  })
  
  # Reactive expression for simulated data based on chosen copula
  simulated_data_reactive <- reactive({
    returns_data <- returns_data_reactive() # Fetch the reactive returns data
    u_stock1 <- as.numeric(ecdf(returns_data[,1])(returns_data[,1]))
    u_stock2 <- as.numeric(ecdf(returns_data[,2])(returns_data[,2]))
    cor_value <- cor(u_stock1, u_stock2)
    param_value <- switch(input$copula_type,
                          "frank" = cor_value, # Frank copula can take any real value, but adjustments might be needed based on your specific case
                          "clayton" = max(cor_value, -0.999), # Ensuring parameter > -1 for Clayton
                          "gumbel" = max(cor_value, 1), # Ensuring parameter >= 1 for Gumbel
                          "joe" = max(cor_value, 1), # Ensuring parameter >= 1 for Joe
                          "amh" = min(max(cor_value, -1), 1), # Ensuring parameter between -1 and 1 for AMH
                          cor_value # Default case, suitable for Gaussian and others if applicable
    )
    chosen_copula <- switch(input$copula_type,
                     "gaussian" = normalCopula(param = cor_value, dim = 2),
                     "frank" = frankCopula(param = param_value, dim = 2),
                     "clayton" = claytonCopula(param = param_value, dim = 2),
                     "gumbel" = gumbelCopula(param = param_value, dim = 2),
                     "joe" = joeCopula(param = param_value, dim = 2),
                     "amh" = amhCopula(param = param_value, dim = 2),
                     normalCopula(param = cor_value, dim = 2))
    
    # Simulate correlated uniform samples using the chosen copula
    set.seed(123) # For reproducibility
    n_samples <- 1000
    simulated_uniforms <- rCopula(n_samples, chosen_copula)
    
    # Transform the uniform samples back to the returns' domain
    simulated_returns_stock1 <- quantile(returns_data[,1], simulated_uniforms[,1], na.rm = TRUE)
    simulated_returns_stock2 <- quantile(returns_data[,2], simulated_uniforms[,2], na.rm = TRUE)
    
    # Combine real and simulated returns for plotting
    real_data <- data.frame(Returns1 = as.vector(returns_data[,1]), 
                            Returns2 = as.vector(returns_data[,2]), 
                            Type = 'Real')
    simulated_data <- data.frame(Returns1 = simulated_returns_stock1, 
                                 Returns2 = simulated_returns_stock2, 
                                 Type = 'Simulated')
    
    combined_data <- rbind(real_data, simulated_data)
    combined_data
  })
  
  
  
  output$combinedPlot <- renderPlot({
    # Use the reactive expression to get combined data for real and simulated returns
    combined_data <- simulated_data_reactive() # This correctly accesses the combined data
    
    # Joint scatter plot
    scatterPlot <- ggplot(combined_data, aes(x = Returns1, y = Returns2, color = Type)) +
      geom_point(alpha = 0.4) +
      scale_color_manual(values = c("Real" = "blue", "Simulated" = "red")) +
      theme_minimal() +
      labs(title = paste("Real and Simulated Correlated Returns of", input$stock1, "and", input$stock2),
           x = paste(input$stock1, "Log Returns"),
           y = paste(input$stock2, "Log Returns"))
    
    # Marginal distributions for Stock 1 (Real and Simulated)
    marginalDist1 <- ggplot(combined_data, aes(x = Returns1, fill = Type)) +
      geom_density(alpha = 0.5) +
      scale_fill_manual(values = c("Real" = "blue", "Simulated" = "red")) +
      theme_minimal() +
      labs(title = paste("Marginal Distribution of", input$stock1),
           x = paste(input$stock1, "Log Returns"))
    
    # Marginal distributions for Stock 2 (Real and Simulated)
    marginalDist2 <- ggplot(combined_data, aes(x = Returns2, fill = Type)) +
      geom_density(alpha = 0.5) +
      scale_fill_manual(values = c("Real" = "blue", "Simulated" = "red")) +
      theme_minimal() +
      labs(title = paste("Marginal Distribution of", input$stock2),
           x = paste(input$stock2, "Log Returns"))
    
    # Arrange the plots
    gridExtra::grid.arrange(scatterPlot, marginalDist1, marginalDist2, ncol = 1)
  })
}



# Run the app
shinyApp(ui = ui, server = server)
