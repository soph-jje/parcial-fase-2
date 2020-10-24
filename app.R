library(shiny)
library(shinydashboard)
library(leaflet)
library(dplyr)
library(readr)
library(tidyverse)
library(leaflet.extras)
library(plotly)

# Juan Jose y Sophia


getwd()

gtd <- read_csv("gtd_clean.csv")

gtd_top_targets <- gtd %>% 
    filter(target_type_txt %in% c('Citizens', 'Military', 'Police', 
                                  'Government', 'Business', 'Religious Institutions', 'Airports','Journalists'))

gtd_19_17 <- gtd %>% 
    filter(year %in% c(1970, 2017))


header <- dashboardHeader(title = "Terrorismo Global")


sidebar <- dashboardSidebar(
    sidebarMenu(
        menuItem("Análisis", tabName = "dashboard", icon = icon("map"))))

body <-dashboardBody(
    tabItems(
        tabItem(tabName ="dashboard",
                        fluidRow(
                            valueBoxOutput("value1")
                            ,valueBoxOutput("value2")
                            ,valueBoxOutput("value3")
                        ),
                
            tabItem(tabName ="dashboard",
             
                   sidebarLayout(
                    sidebarPanel(
                        h1("Terrismo Global"),
                        h3("Filtros:"),
                        selectInput(inputId = "country",
                                    label = "Pais:",
                                    choices = unique(as.character(gtd$country)),
                                    multiple = TRUE),
                        sliderInput("year_slider", "Year:",
                                    min = min(gtd$year,na.rm = TRUE ), max = max(gtd$year, na.rm = TRUE),
                                    value = c(min(gtd$year,na.rm = TRUE ),max(gtd$year, na.rm = TRUE))),
                        sliderInput("deaths_slider", "Deaths:",
                                    min = min(gtd$nkill,na.rm = TRUE ), max = max(gtd$nkill, na.rm = TRUE),
                                    value = c(min(gtd$nkill,na.rm = TRUE ),max(gtd$nkill, na.rm = TRUE)))
                    ),
                    mainPanel(
                        DT::dataTableOutput("table")
                    )
                )
        
    
    
),
   tabItem(tabName ="dashboard",
            fluidRow( 
                box(title = "Comparación en el tiempo"
                    ,status = "primary"
                    ,solidHeader = TRUE 
                    ,collapsible = TRUE
                    ,leafletOutput("mymap", height = "300px")
                    ,sliderInput("slider", "Years:", 1970, 2017, 2000))
                ,box(
                    title = "Número de muertes por tipo de ataque"
                    ,status = "primary"
                    ,solidHeader = TRUE 
                    ,collapsible = TRUE 
                    ,plotOutput("Killbyattacktype", height = "300px"),
                    selectInput("selector", h3("Seleccionar región"), 
                                choices = list("Australasia" = "Australasia & Oceania", "Central America" = "Central America & Caribbean", 
                                               "Central Asia" = "Central Asia", "East Asia" = "East Asia", "Eastern Europe" = "Eastern Europe", 
                                               "MENA" = "Middle East & North Africa", "North America" = "North America",
                                               "South America" = "South America", "South Asia" = "South Asia", "Southeast Asia" = "Southeast Asia", 
                                               "Sub-Saharan Africa" = "Sub-Saharan Africa", "Western Europe" = "Western Europe"), selected = 1))),
            
            fluidRow( 
                box(
                    title = "Quiénes fueron los principales objetivos"
                    ,status = "primary"
                    ,solidHeader = TRUE 
                    ,collapsible = TRUE
                    ,plotOutput("targetkilled", height = "300px")
                    ,radioButtons("radio", h3("Seleccionar Año"),
                                  choices = list("1970" = 1970, "1975" = 1975, "1980" = 1980, "1985" = 1985, 
                                                 "1990" = 1990, "1995" = 1995, "2000" = 2000, "2005" = 2005, 
                                                 "2010" = 2010,"2015" = 2015, "2017" = 2017),selected = 1970, inline = T))
                ,box(
                    title = "Número de muertes por Región"
                    ,status = "primary"
                    ,solidHeader = TRUE 
                    ,collapsible = TRUE
                    ,plotOutput("killbyregion", height = "300px")
                    ,radioButtons("yearsradio", h3("Seleccionar año"), choices = list("1970" = 1970, "1975" = 1975, 
                                                                                  "1980" = 1980, "1985" = 1985, "1990" = 1990, "1995" = 1995, "2000" = 2000, "2005" = 2005, 
                                                                                  "2010" = 2010,"2015" = 2015, "2017" = 2017), selected = 1970, inline = T))
                
                ,box(
                    title = "Número de muertes por arma utilizada"
                    ,status = "primary"
                    ,solidHeader = TRUE 
                    ,collapsible = TRUE
                    ,plotOutput("killbyweapon", height = "300px")
                    ,radioButtons("yearsradio2", h3("Seleccionar año"), choices = list("1970" = 1970, "1975" = 1975, 
                                                                                  "1980" = 1980, "1985" = 1985, "1990" = 1990, "1995" = 1995, "2000" = 2000, "2005" = 2005, 
                                                                                  "2010" = 2010,"2015" = 2015, "2017" = 2017), selected = 1970, inline = T))),
             fluidRow( 
                
                tabBox(
                width = NULL,
                title = "Mundialmente",
                selected = "Incidents",
                tabPanel("Muertes",
                         plotlyOutput("lineCas")
                )
            )), 

))
))







ui <- dashboardPage(title = 'Dashboard de estadisticas de Terrorismo Global', header, sidebar, body, skin='black')    



server <- function(input, output) {
    
    total_kills <- sum(gtd$nkill)
    countries <- gtd %>% group_by(country) %>% summarise(value = sum(nkill)) %>% filter(value==max(value))
    weapon.type <- gtd %>% group_by(weapon_type) %>% summarise(value = sum(nkill)) %>% filter(value==max(value))
    attacker <- gtd %>% group_by(nationality) %>% summarise(value = sum(nkill)) %>% filter(value==max(value))
    
    
    
    
    output$value1 <- renderValueBox({
        valueBox(
            formatC(countries$value, format="d", big.mark=',')
            ,paste('Top País:',countries$country)
            ,icon = icon("stats",lib='glyphicon')
            ,color = "yellow")
        
        
    })
    
    
    
    output$value2 <- renderValueBox({
        
        valueBox(
            formatC(total_kills, format="d", big.mark=',')
            ,paste('Top nacionalidad:',attacker$nationality)
            ,icon = icon("stats",lib='glyphicon')
            ,color = "maroon")
        
    })
    
    
    
    output$value3 <- renderValueBox({
        
        valueBox(
            formatC(weapon.type$value, format="d", big.mark=',')
            ,paste('Top armas usadas:',weapon.type$weapon_type)
            ,icon = icon("stats",lib='glyphicon')
            ,color = "olive")
        
    })
    
    output$lineCas <- renderPlotly({
        gtd %>% 
            group_by(year) %>% 
            summarise(kill = sum(nkill, na.rm = T)) %>% 
            plot_ly(x = ~year, y = ~kill, type = "scatter", mode = "lines") %>% 
            layout(
                xaxis = list(title = "Año"),
                yaxis = list(title = "Número de muertes")
            )
    })
   
    
    datasetInput <- reactive({
        
        filter(gtd, gtd$year <= input$yearsradio)
        
    })
    
    output$killbyregion <- renderPlot({
        data_filter <- datasetInput()
        
        ggplot(data = data_filter, 
               aes(x=region, y=nkill)) + 
            geom_bar(position = "dodge", stat = "identity", fill="#634A70") + ylab("Num de muertes") + 
            xlab("Región") + theme(legend.position="bottom" 
                                   ,plot.title = element_text(size=15, face="bold"), axis.text.x=element_text(angle=90)) + 
            ggtitle("Muertes por Región")
    })
    
    
    datayear <- reactive({
        
        filter(gtd, gtd$year <= input$yearsradio2) 
        
    })
    output$killbyweapon <- renderPlot({
        data_weapon <- datayear()
        
        ggplot(data = data_weapon, 
               aes(x=weapon_type, y=nkill)) + 
            geom_bar(position = "dodge", stat = "identity", fill="#4A6E70") + ylab("Num de Muertes") + 
            xlab("Arma") + theme(legend.position="bottom" 
                                   ,plot.title = element_text(size=10, face="bold"), axis.text.x=element_text(angle=15)) + 
            ggtitle("Muertes por arma")
    })
    
    datasetregion <- reactive({
        
        filter(gtd, gtd$region <= input$selector)
    })
    
    output$Killbyattacktype <- renderPlot({
        data_region <- datasetregion()
        
        ggplot(data = data_region, 
               aes(x=attacktype_txt, y=nkill)) + 
            geom_bar(position = "dodge", stat = "identity", fill="#75A28A") + ylab("Num de Muertes") + 
            xlab("Tipo Ataque") + theme(legend.position="bottom" 
                                        ,plot.title = element_text(size=15, face="bold")) + 
            ggtitle("Num de muertes por tipo de ataque")
    })
    
    output$table <- DT::renderDataTable(DT::datatable({
        data <- gtd %>%
            select(year,
                   month,
                   country,
                   nkill,
                   city,
                   attacktype_txt,
                   target_type_txt) %>% 
            filter(between(year, input$year_slider[1],input$year_slider[2])) %>% 
            filter(between(nkill, input$deaths_slider[1],input$deaths_slider[2]))
        if (!is.null(input$country)) { 
            data <- data[data$country == input$country,]
        }
        data
    })
    )
    
    datasettarget <- reactive({
        
        filter(gtd_top_targets, gtd_top_targets$year %in% input$radio)
    })
    
    output$targetkilled <- renderPlot({
        data_target <- datasettarget()
        
        ggplot(data = data_target, 
               aes(x=target_type_txt, y=nkill)) + 
            geom_bar(position = "dodge", stat = "identity", fill="#4A704D") + ylab("Num de Muertes") + 
            xlab("Tipo Target") + theme(legend.position="bottom" 
                                        ,plot.title = element_text(size=15, face="bold")) + 
            ggtitle("Tipo de Target")
    })
    
    datasetyears <- reactive({
        
        filter(gtd, gtd$year %in% input$slider)
    })
    
    output$mymap <- renderLeaflet({
        data_years <- datasetyears()
        
        leaflet(data_years) %>% 
            setView(lng = 43.6793, lat = 33.2232, zoom = 2) %>% 
            addTiles() %>% 
            addCircles(data = data_years, lat = ~ latitude, lng = ~ longitude, weight = 1, 
                       radius = ~sqrt(nkill)*25000, popup = ~as.character(nkill), 
                       label = ~as.character(paste0("Muertes: ", sep = " ", nkill)), fillOpacity = 0.5)
    })
}
shinyApp(ui, server)
    
    
