library(magrittr)
library(tidyr)
import::from(dplyr, select, mutate, rename, arrange, group_by, summarize, keep_where = filter)

query_hive <- function(query){
  
  # Write query out to tempfile and create tempfile for results.
  query_dump <- tempfile()
  cat(query, file = query_dump)
  results_dump <- tempfile()
  
  # Query and read in the results
  system(paste0("export HADOOP_HEAPSIZE=1024 && hive -f ", query_dump, " > ", results_dump))
  results <- readLines(results_dump) # includes a lot of hive garbage output we need to sanitize out
  
  # Clean up and return
  file.remove(query_dump, results_dump)
  
  results <- results %>%
    grep("parquet\\.hadoop", x = ., invert = TRUE, value = TRUE) %>%
    paste0(collapse = "\n") %>%
    readr::read_tsv(col_names = TRUE)
  
  return(results)
}

library(lazyeval)

get_props <- function(data, var, group) {
  return(data %>%
    dplyr::group_by_(.dots = as.list(setdiff(colnames(data), c(var, group)))) %>%
    dplyr::summarize_(total = interp(~sum(var), var = as.name(var))) %>%
    dplyr::left_join(data, .) %>%
    dplyr::group_by_(.dots = as.list(setdiff(colnames(data), var))) %>%
    dplyr::summarize_(proportion = interp(~var/total, var = as.name(var))))
}
