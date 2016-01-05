source('utils.R')
# source('refine_results.R')

library(ggplot2)
library(ggthemes)

ggsave(plot = web %>%
         group_by(group, accept_language, results) %>%
         summarize(events = sum(events)) %>%
         get_props("events", "results") %>%
         ggplot(data = ., aes(x = results, y = proportion, fill = group)) +
         geom_bar(stat = "identity", position = "dodge") +
         scale_y_continuous(labels = scales::percent_format(), limits = c(0, 1)) +
         geom_text(aes(label = sprintf("%.1f%%", 100*proportion), y = proportion + 0.1),
                   position = position_dodge(width = 1), size = 6) +
         facet_grid(accept_language ~ .) +
         theme_fivethirtyeight(16) +
         ggtitle("Accept-Language A/B Test: Event Counts (Web Users)"),
       filename = "figures/web_events.png", width = 14, height = 7)

ggsave(plot = api_light %>%
         group_by(group, accept_language, results) %>%
         summarize(events = sum(events)) %>%
         get_props("events", "results") %>%
         ggplot(data = ., aes(x = results, y = proportion, fill = group)) +
         geom_bar(stat = "identity", position = "dodge") +
         scale_y_continuous(labels = scales::percent_format(), limits = c(0, 1)) +
         geom_text(aes(label = sprintf("%.1f%%", 100*proportion), y = proportion + 0.1),
                   position = position_dodge(width = 1), size = 6) +
         facet_grid(accept_language ~ ., scales = "free_y") +
         theme_fivethirtyeight(16) +
         ggtitle("Accept-Language A/B Test: Event Counts (Light API Users)"),
       filename = "figures/api_events.png", width = 14, height = 7)

ggsave(plot = api_heavy %>%
         group_by(group, accept_language, results) %>%
         summarize(users = sum(users)) %>%
         get_props("users", "results") %>%
         ggplot(data = ., aes(x = results, y = proportion, fill = group)) +
         geom_bar(stat = "identity", position = "dodge") +
         scale_y_continuous(labels = scales::percent_format()) +
         geom_text(aes(label = sprintf("%.1f%%", 100*proportion), y = proportion + 0.075),
                   position = position_dodge(width = 1), size = 6) +
         facet_grid(accept_language ~ ., scales = "free_y") +
         theme_fivethirtyeight(16) +
         ggtitle("Accept-Language A/B Test: User Counts (Heavy API Users)"),
       filename = "figures/api_users.png", width = 14, height = 7)
