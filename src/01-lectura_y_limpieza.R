# Librerías ====
library(tidyverse)

# Parámetros 
anios_a_evaluar = 3


# Lectura ====
delitos <- read_csv("data/raw/Municipal-Delitos-2015-2020_nov2020.csv", 
                     locale = locale(encoding = 'latin1'))

# Limpieza ====
delitos_long <- delitos %>% 
    janitor::clean_names() %>%
    select(ano, entidad, tipo_de_delito, enero:diciembre) %>%
    pivot_longer(enero:diciembre, 
                 names_to = 'mes', 
                 values_to = 'delitos')

delitos_long <- delitos_long %>%
    mutate(entidad = parse_factor(entidad), 
           tipo_de_delito = parse_factor(tipo_de_delito))

# Podría cambiar los factores muy rápido
delitos_long %>% 
    mutate(entidad = fct_recode(entidad,
                                centro = 'Aguascalientes', 
                                norte = 'Zacatecas'))
# Ejemplo
x <- factor(c("apple", "bear", "banana", "dear"))
fct_recode(x, fruit = "apple", fruit = "banana")

#delitos_long %>% 
#  distinct(entidad) %>%
#  .$entidad

#lista = list(entidad = c(1, 2, 4))
#lista

# Escritura =====
# El análisis se hará por estado
entidad_vec <- delitos_long %>% 
    distinct(entidad)

# Este ciclo solo corre una vez
for (i in entidad_vec) {
    print(i)
    print('\n')
}

seq_along(entidad_vec) # aquí podemos ver que es un solo elemento en la seq

# Corregimos
entidad_vec <- delitos_long %>% 
    distinct(entidad) %>%
    pull()

for (i in entidad_vec) {
    print(i)
}

# Ahora metemos dentro del ciclo la escritura
for (i in entidad_vec) {
    print(i)
    delitos_long %>%
        filter(entidad == i) %>%
        write_csv('data/interim/delitos_{estado}.csv')

}

# El ciclo sobreescribe en el mismo archivo
# Para distintos nombres, usamos glue
nombre <- 'carlos'
last_anios <- delitos_long %>% 
                distinct(ano) %>%
                arrange(desc(ano)) %>%
                slice_head(n = anios_a_evaluar) %>%
                pull()

glue::glue('mi nombre es: {str_to_upper(nombre)}')

for (i in entidad_vec) {
    tictoc::tic()
    print(i)
    delitos_long %>%
        filter(entidad == i, 
               ano %in% last_anios) %>%
        write_csv(glue::glue('data/interim/delitos_{i}.csv'))
    tictoc::toc()
}

# Los fors son bien conocidos por ser engorrosos y lentos
purrr::map(entidad_vec, 
            ~ print(.x))

escritura_multiple <- function(x) {
    # Time sobre cada escritura de entidad
    tictoc::tic()
    print(x)
    delitos_long %>%
        filter(entidad == x, 
               ano %in% last_anios) %>%
        write_csv(glue::glue('data/interim/delitos_{x}.csv'))
    tictoc::toc()
}

purrr::walk(entidad_vec, 
            ~ delitos_long %>%
                    filter(entidad == .x, 
                        ano %in% last_anios) %>%
                write_csv(glue::glue('data/interim/delitos_{.x}.csv')))

purrr::walk(entidad_vec, escritura_multiple))

purrr::walk2(entidad_vec[1:30], rep(last_anios, 10), 
             ~ print(paste(.x, .y, sep = " ", " ")))

