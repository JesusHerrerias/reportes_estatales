# Library
library(tidyverse)

list_archivos <- list.files(here::here('data/interim'), pattern = '*.csv')

walk(list_archivos, 
     ~ rmarkdown::render('src/03-reporte.Rmd', 
                         params = list(estado = .x), 
                         output_file = glue::glue('{.x}.html'), 
                         output_dir = 'reports'))

