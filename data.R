library(readr)
library(data.table)

fetch <- function() {
  files <- list.files("/a/mw-log/archive/CirrusSearchUserTesting",
                      pattern = "CirrusSearchUserTesting\\.log-201512",
                      full.names = TRUE)
  dates <- as.numeric(substr(files, 71, 78))
  files <- files[dates %in% seq(20151212, 20151227, 1)]
  
  results <- lapply(files, function(x) {
    file <- tempfile()
    system(paste("gunzip -c ", x, ">", file))
    data <- readr::read_tsv(file,
                            col_names = c("date", "group", "queries", "results", "source", "time_taken", "ip",
                                          "user_agent", "query_metadata", "identity"),
                            col_types = "cccicicccc")
    file.remove(file)
    data <- as.data.table(data[grepl(x = data$query_metadata, pattern = "full_text", fixed = TRUE), ])
    data <- data[!data$user_agent == "",]
    
    data$group <- factor(data$group,
                         paste0("multilang-accept-lang-", letters[1:3]),
                         c("control",
                           "AL + es-plugin when 0 results",
                           "AL + es-plugin when <3 results"))
    data$al_not_detect <- grepl(data$query_metadata, pattern = '"acceptLang":false', fixed = TRUE)
    data$al <- grepl(data$query_metadata, pattern = '"acceptLang":')
    data$accept_language <- as.character(NA)
    data$accept_language[data$al & !data$al_not_detect] <- "found valid language via AL"
    data$accept_language[data$al_not_detect] <- "didn't find a valid language via AL"
    data$accept_language <- factor(data$accept_language)
    data$esp_not_detect <- grepl(data$query_metadata, pattern = '"es-plugin":false', fixed = TRUE)
    data$esp <- grepl(data$query_metadata, pattern = '"es-plugin":', fixed = TRUE)
    data$es_plugin <- as.character(NA)
    data$es_plugin[data$esp & !data$esp_not_detect] <- "found valid language via es plugin"
    data$es_plugin[data$esp_not_detect] <- "didn't find a valid language via es plugin"
    data$es_plugin <- factor(data$es_plugin)
    data$misc <- as.character(NA)
    data$misc[grepl(data$query_metadata, pattern = '"failed":true', fixed = TRUE)] <- "Attempted to detect a language via accept-lang and es-plugin, but no language could be decided upon."
    data$less_than_3 <- data$results < 3
    data$results <- factor(data$results > 1, c(TRUE, FALSE), c("Some results", "Zero results"))
    
    data$date <- as.Date(substring(data$date, 0, 10))
    data <- data[, j = list(events = .N), by = c("date", "group", "source", "accept_language", "es_plugin", "misc", "less_than_3", "results", "identity")]
    gc()
    return(data)
  })
  return(do.call("rbind", results))
}

data <- fetch()

readr::write_tsv(data, "~/AcceptLangTestData.tsv")
