library(dplyr)
library(readr)

raw <- read_csv("http://www.transtats.bts.gov/Download_Lookup.asp?Lookup=L_UNIQUE_CARRIERS")

load("data/flights-2014.rda")

airlines <- raw %>%
  select(carrier = Code, name = Description) %>%
  semi_join(flights) %>%
  arrange(carrier)

write.csv(airlines, "data-raw/airlines.csv.gz")
save(airlines, file = "data/airlines.rda")
