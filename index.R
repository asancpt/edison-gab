#!/SYSTEM/R/3.3.3/bin/Rscript

library(magrittr)

# init ----

if (grepl('linux', R.version$os)) .libPaths(c("./lib", '/SYSTEM/R/3.3.3/lib64/R/library')) %>% print()

print(lapply(.libPaths(), dir))

if (length(intersect(dir(), 'result')) == 0) system('mkdir result')

# setup ----

libraries <- c('dplyr', 'purrr', 'wnl', 'NonCompart', 'rmarkdown') # lapply(libraries, install.packages)

lapply(libraries, library, character.only = TRUE)

render('README.Rmd', output_file = 'result/README.html')
