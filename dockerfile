#hola gg

FROM rocker/shiny-verse:latest

#instalar librerias
RUN R -e "install.packages('shiny', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shinydashboard', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('tidyverse', repos='http://cran.rstudio.com/')"

RUN R -e "devtools::install_github('andrewsali/shinycssloaders')"
RUN R -e "devtools::install_github('rstudio/httpuv')"
RUN R -e "install.packages('plotly', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('leaflet', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('leaflet.extras', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('dplyr', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('readr', repos='http://cran.rstudio.com/')"


   
## Instalar paquetes
RUN install2.r --error \
    -r 'http://cran.rstudio.com' \
    googleAuthR \
    ## install Github packages
    ## clean up
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds

## copiar los contenidos del directorio donde se encuentra el codigo al directorio  /srv/shiny-server/shiny/
COPY . /srv/shiny-server/shiny/
# exponer el puerto
EXPOSE 3838
# moverse al directorio
WORKDIR /srv/shiny-server/shiny
# run app
CMD R -e 'shiny::runApp("app.R", port = 3838, host = "0.0.0.0")'
