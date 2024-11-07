library(shiny)
library(dplyr)
library(ggplot2)
library(plotly)
library(readr)
library(RColorBrewer)
library(forcats)
library(lubridate)
library(naniar)
library(gridExtra)
library(cowplot)


## DATA IMPORTATION ----
data <- read_csv("../data2024-2025.csv")
data = data[ , -c(1,ncol(data))]
data = data %>% filter(Saison == 2024)
# impute NAs
# in D,R, J, P, T, E -> replace by 0
data[c("D", "R", "J", "P", "T", "E")][is.na(data[c("D", "R", "J", "P", "T", "E")])] <- 0

# in FFR, Joueur Supplémentaire, Prêt --> replace by 'None'
data[c("FFR", "Joueur Supplémentaire", "Prêt")][is.na(data[c("FFR", "Joueur Supplémentaire", "Prêt")])] <- "None"

# in Taille -> replace by mean(data$Taille)
data$Taille[is.na(data$Taille)] <- mean(data$Taille, na.rm = TRUE)
data$Poids[is.na(data$Poids)] <- mean(data$Poids, na.rm = TRUE)
data$Âge[is.na(data$Âge)] <- mean(data$Âge, na.rm = TRUE)

stats_joueurs = data %>% 
  group_by(ID, Nom, Prénom) %>% 
  summarise(Nation = last(Nationalité),
            Age = max(Âge),
            Taille = max(Taille),
            Poids = max(Poids),
            Competition = last(Compétition),
            Club = last(Club),
            nbMatches = sum(Matchs),
            totalTps = sum(Temps),
            nbRed = sum(R),
            nbYellow = sum(J),
            nbTries = sum(E),
            nbPenalties = sum(P),
            nbTransfos = sum(T),
            nbDrops = sum(D),
            nbTitu = sum(`T/R` == 'T'),
            nbRempl = sum(`T/R` == 'R'),
            postes = paste(unique(Numéro), collapse = ", "))

# change char to categorical
stats_joueurs$Nation = as.factor(stats_joueurs$Nation)
stats_joueurs$Club = as.factor(stats_joueurs$Club)
stats_joueurs$Competition = as.factor(stats_joueurs$Competition)
# ---- end----

## SERVER ----
function(input, output, session) {
  
  observe({
    message("test")
    shiny::updateSelectInput(session, inputId = "columns", choices = colnames(data))
  })
  
  output$distPlot <- renderText({
    print(names(data))
    
  })
  
}
