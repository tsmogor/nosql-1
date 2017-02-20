# From https://mesonet.agron.iastate.edu/request/download.phtml?network=NY_ASOS
# From:
#   https://mesonet.agron.iastate.edu/request/download.phtml?network=PL__ASOS#

library(httr)
library(dplyr)
library(lubridate)
library(readr)

get_asos <- function(station, first_year, last_year) {
  url <- "http://mesonet.agron.iastate.edu/cgi-bin/request/asos.py?"
  query <- list(
    station = station, data = "all",
    year1 = as.character(first_year), month1 = "1", day1 = "1",
    year2 = as.character(last_year), month2 = "12", day2 = "31", tz = "GMT",
    format = "comma", latlon = "no", direct = "yes")

  dir.create("data-raw/weather_ep", showWarnings = FALSE, recursive = TRUE)
  r <- GET(url, query = query, write_disk(paste0("./data-raw/weather_ep/", station, ".csv")))
  stop_for_status(r)
}

# Gdańsk Rębiechowo, Kraków Balice, Warszawa Okęcie
stations <- c("EPGD", "EPKK", "EPWA")
paths <- paste0(stations, ".csv")
missing <- stations[!(paths %in% dir("data-raw/weather_ep/"))]
missing

lapply(missing, get_asos, 2015, 2015)

unused_cols = cols(
  X12 = col_character(), # Can not automatically convert from numeric to character in column "X12" (gust)
  X13 = col_character(),
  X14 = col_character(),
  X15 = col_character(),
  X16 = col_character(),
  X17 = col_character(),
  X18 = col_character(),
  X19 = col_character(),
  X20 = col_character(),
  X21 = col_character(),
  X22 = col_character()
)

paths <- dir("data-raw/weather_ep", full.names = TRUE)
paths

# row col expected actual
# 802  X6 a double      M
all <- lapply(paths, read_csv, skip = 6, col_names = FALSE, col_types = unused_cols, na = "M")

raw <- bind_rows(all)
var_names <- c("station", "time", "tmpf", "dwpf", "relh", "drct", "sknt", "p01i", "alti", "mslp", "vsby", "gust",  # 1--12
  "skyc1", "skyc2", "skyc3", "skyc4", "skyl1", "skyl2", "skyl3", "skyl4", "presentwx", "metar") # 12--22
names(raw) <- var_names

length(var_names)

ep15 <- raw %>%
  select(
    station, time, temp = tmpf, dewp = dwpf, humid = relh, # 1--5
    wind_dir = drct, wind_speed = sknt, wind_gust = gust,  precip = p01i, pressure = mslp, # 6--10
    visib = vsby # 11
  ) %>%
  # see Difference Between Gust and Wind --
  #   http://www.differencebetween.net/science/nature/difference-between-gust-and-wind/
  mutate( # conversions
    time = as.POSIXct(strptime(time, "%Y-%m-%d %H:%M")),
    temp = round((32 - as.numeric(temp)) * 5/9, 2), # convert from °F to °C
    dewp = round((32 - as.numeric(dewp)) * 5/9, 2),
    # 1 knots = 0.514444444 meters / second = 1.85200 kilometers per hour
    wind_speed = round(as.numeric(wind_speed) * 0.514444444, 2), # convert to m/s
    wind_gust = round(as.numeric(wind_gust) * 0.514444444, 2),
    visib = round(as.numeric(visib) * 1.609344, 2) # convert to kilometers
  ) %>%
  mutate(
    year = year(time), month = month(time), day = mday(time), # 12--14
    hour = hour(time), minute = minute(time)                  # 15--16
  ) %>% group_by(station, year, month, day, hour) %>%
  filter(row_number() == 1) %>%
  ungroup() %>%
  filter(!is.na(time)) %>%
  mutate(
    time_hour = ISOdatetime(year, month, day, hour, 0, 0) # 17
  )
nrow(ep15)

save(ep15, file = "data/weather_ep_2015.rda", compress = "bzip2")

write.csv(ep15, gzfile("data-raw/weather_ep_2015.csv.gz"), row.names = FALSE, quote = FALSE, na = "")

# Read data back into R:
#   library(dplyr)
#   load("data/weather_ep_2015.rda")
#   ep15 %>% tbl_df()

# Import into MongoDB
# library(mongolite)
# m = mongo(collection = "ep15")
# m$insert(ep15)
