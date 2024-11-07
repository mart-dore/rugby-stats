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
               shiny::selectInput("columns", "Choose column", choices = NULL)
             ),
             
             # Show a plot of the generated distribution
             mainPanel(
               textOutput("distPlot")
             )
           )
  )
)




