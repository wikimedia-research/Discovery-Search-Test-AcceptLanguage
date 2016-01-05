source('utils.R')
# source('refine_results.R')

library(BCDA)
library(purrr) # install.packages("purrr")

web %>%
  group_by(accept_language) %>%
  dplyr::do(
    group_by(., group, results) %>%
      summarize(events = sum(events)) %>%
      as.matrix(ncol = 2)
  )

web %>%
  group_by(., group, results) %>%
  summarize(events = sum(events)) %>%
  xtabs(events ~ group + results, data = .) %>%
  # { .[-3, ] } %>% # exclude "AL + es-plugin when <3 results"
  prop.table(margin = 1)
