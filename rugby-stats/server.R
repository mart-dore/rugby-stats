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

num_features = names(stats_joueurs)[sapply(stats_joueurs, is.numeric)]
# remove id
num_features = num_features[num_features != "ID"]
# ---- end----

## SERVER ----
function(input, output, session) {
  
  observe({
    message("test")
    shiny::updateSelectInput(session,
                             inputId = "var_top10",
                             choices = num_features)
  })
  
  output$plot_top10_var = renderPlot({
    req(input$var_top10)
    req(input$order_top10)
    
    var = input$var_top10
    order = input$order_top10
    
    if (order == 'DESC'){
      top10var <- stats_joueurs %>%
        mutate(NomPrenom = paste(Nom, Prénom)) %>% 
        arrange(desc(get(var))) %>% 
        head(n=10)
      
      p = top10var %>%
        ggplot(aes(x = reorder(NomPrenom, get(var)), y = get(var), fill = Club)) +
        geom_bar(stat = "identity") +
        geom_text(aes(label = get(var)), hjust = +1.1) +
        coord_flip() +
        ylab(var) +
        xlab("") +
        ggtitle(paste("Top 10 des joueurs par", var, "décroissant")) +
        theme_classic() +
        theme(axis.text.x = element_text(angle = 90))
    }
    else {if (order == 'ASC'){
      top10var <- stats_joueurs %>%
        mutate(NomPrenom = paste(Nom, Prénom)) %>% 
        arrange(desc(get(var))) %>% 
        tail(n=10)
      
      p = top10var %>%
        ggplot(aes(x = reorder(NomPrenom, -get(var)), y = get(var), fill = Club)) +
        geom_bar(stat = "identity") +
        geom_text(aes(label = get(var)), hjust = +1.1) +
        coord_flip() +
        ylab(var) +
        xlab("") +
        ggtitle(paste("Top 10 des joueurs par", var, "croissant")) +
        theme_classic() +
        theme(axis.text.x = element_text(angle = 90))
    }
    }
    p
  })
  
}
