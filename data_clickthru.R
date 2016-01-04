library(readr)
library(data.table)
source("utils.R")

# 10:49 ebernhardson: basically the wmf.webrequest table contains an x_analytics_map field,
#   within that field we have a marker that indicates which bucket the click came from...
# ... x_analytics_map['wprov'] = 'iwsw4' is the multilang-accept-lang-b bucket, and iwsw5
#   is the multilang-accept-lang-c bucket...
# ... basically every interwiki link we generated for the test had the wprov=iwswN attached
#   to it. You might be able to normalize down to per user via ip/user-agent/something, so
#   it's not the cleanest data out there but it's hopefully better than nothing...
# ... those were not attached to the intrawiki links though, so for bucket c which could
#   show 2 intrawiki links and then a bunch of interwiki links, only the interwiki links
#   have the marker...
# ... easiest might be to create a table in hive in your own database based on the result
#   of just sucking out everything with iwsw and then later querying that in different ways

"CREATE TABLE bearloga.multilang_accept AS
 SELECT *,
   CASE WHEN x_analytics_map['wprov'] = 'iwsw4' THEN 'multilang-accept-lang-b'
        WHEN x_analytics_map['wprov'] = 'iwsw5' THEN 'multilang-accept-lang-c'
   END AS group
 FROM wmf.webrequest
 WHERE year = 2015 AND month = 12 AND day > 12
   AND (x_analytics_map['wprov'] = 'iwsw4' OR x_analytics_map['wprov'] = 'iwsw5');"

temp <- query_hive("SELECT *, CASE WHEN x_analytics_map['wprov'] = 'iwsw4' THEN 'multilang-accept-lang-b'
  WHEN x_analytics_map['wprov'] = 'iwsw5' THEN 'multilang-accept-lang-c'
  END AS group
FROM wmf.webrequest
WHERE year = 2015 AND month = 12 AND day = 12 AND hour = 12
  AND (x_analytics_map['wprov'] = 'iwsw4' OR x_analytics_map['wprov'] = 'iwsw5')
LIMIT 100;")

fetch <- function() {
  query <- "USE bearloga;
  SELECT *, CONCAT(ip, user_agent, x_forwarded_for, x_analytics_map['wprov']) AS identity, 
  FROM multilang_accept
  GROUP BY year, month, day, CONCAT(ip, user_agent, x_forwarded_for, x_analytics_map['wprov'])"
}

data <- fetch()

readr::write_csv(data, "~/AcceptLangTestData2.csv")
