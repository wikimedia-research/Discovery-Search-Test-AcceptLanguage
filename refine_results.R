load("AcceptLangTest.RData")

library(magrittr)
library(tidyr)
import::from(dplyr, select, mutate, rename, arrange, group_by, summarize, keep_where = filter)

data_web %<>% keep_where(events < 7) # 99% of the data

web <- data_web %>%
  group_by(group, accept_language, less_than_3, results) %>%
  summarize(events = sum(events)) %>%
  dplyr::ungroup()

api_light <- data_api %>%
  keep_where(events < 113) %>% # 99.9% of the data
  group_by(group, accept_language, less_than_3, results) %>%
  summarize(events = sum(events)) %>% # add individual events
  dplyr::ungroup()

api_heavy <- data_api %>%
  keep_where(events > 112) %>% # top 0.1% of the data
  group_by(date, group, accept_language, less_than_3, results) %>%
  summarize(users = n()) %>% # count how many users had the outcome
  # this is done because so many api users had thousands of events
  dplyr::ungroup()

rm(data_web, data_api)


