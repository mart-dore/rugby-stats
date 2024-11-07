library(shiny)
library(bslib)
# Define UI 
navbarPage(
  # theme selection
  theme = bs_theme(),
  
  # Application title
  titlePanel("Rugby Stats"),
  # -- Introduction -- 
  tabPanel("Introduction"),
  
  # -- Stats Globales -- 
  tabPanel("Competitions"),
  
  # -- Stats par joueur -- 
  tabPanel("PLOTS1",
           # Sidebar with a slider input for number of bins
           sidebarLayout(
             sidebarPanel(
               shiny::selectInput("var_top10", "Choose column", choices = NULL),
               shiny::selectInput("order_top10", "Choose order", choices = c('ASC', 'DESC'))
             ),
             
             # Show a plot of the generated distribution
             mainPanel(
               plotOutput("plot_top10_var")
             )
           )
  )
)




