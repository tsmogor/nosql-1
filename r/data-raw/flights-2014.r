library(dplyr)
library(readr)
library(lubridate)

flight_url <- function(year = 2014, month) {
  base_url <- "http://www.transtats.bts.gov/Download/"
  sprintf(paste0(base_url, "On_Time_On_Time_Performance_%d_%d.zip"), year, month)
}

download_month <- function(year = 2014, month) {
  url <- flight_url(year, month)

  temp <- tempfile(fileext = ".zip")
  download.file(url, temp)

  files <- unzip(temp, list = TRUE)
  # Only extract biggest file
  csv <- files$Name[order(files$Length, decreasing = TRUE)[1]]

  unzip(temp, exdir = "data-raw/flights", junkpaths = TRUE, files = csv)

  src <- paste0("data-raw/flights/", csv)
  dst <- paste0("data-raw/flights/", "2014-", month, ".csv")
  file.rename(src, dst)
}

months <- 1:12
needed <- paste0("2014-", months, ".csv")
missing <- months[!(needed %in% dir("data-raw/flights"))]

lapply(missing, download_month, year = 2014)

get_nyc <- function(path) {
  col_types <- cols(
    DepTime = col_integer(),         # local time: hhmm
    ArrTime = col_integer(),         # local time: hhmm
    CRSDepTime = col_integer(),      # local time: hhmm
    CRSArrTime = col_integer(),      # local time: hhmm
    Carrier = col_character(),
    UniqueCarrier = col_character()
    # AirTime = col_integer(),       # in minutes
    # DepDelay = col_integer(),
    # ArrDelay = col_integer(),
    # Distance = col_double()        # in miles
  )
  read_csv(path, col_types = col_types) %>%
    select(
      year = Year, month = Month, day = DayofMonth,
      dep_time = DepTime, sched_dep_time = CRSDepTime, dep_delay = DepDelay,
      arr_time = ArrTime, sched_arr_time = CRSArrTime, arr_delay = ArrDelay,
      carrier = Carrier,  flight = FlightNum, tailnum = TailNum,
      origin = Origin, dest = Dest,
      air_time = AirTime, distance = Distance
    ) %>%
    # filter(origin %in% c("JFK", "LGA", "EWR")) %>%
    mutate(
      hour = sched_dep_time %/% 100,
      minute = sched_dep_time %% 100,
      time_hour = lubridate::make_datetime(year, month, day, hour, 0, 0)
    ) %>%
    arrange(year, month, day, dep_time)
}

all <- lapply(dir("data-raw/flights", full.names = TRUE), get_nyc)
flights <- bind_rows(all)
flights$tailnum[flights$tailnum == ""] <- NA

make_datetime_100 <- function(year, month, day, time) {
  make_datetime(year, month, day, time %/% 100, time %% 100)
}

flights <- flights %>%
  filter(!is.na(dep_time), !is.na(arr_time), !is.na(dep_delay), !is.na(arr_delay), !is.na(air_time)) %>%
  mutate(
    dep_time = make_datetime_100(year, month, day, dep_time),
    arr_time = make_datetime_100(year, month, day, arr_time),
    sched_dep_time = make_datetime_100(year, month, day, sched_dep_time),
    sched_arr_time = make_datetime_100(year, month, day, sched_arr_time)
  ) %>%
  select(origin, dest, distance, ends_with("delay"), ends_with("time"), tailnum)

flights = flights %>%
  mutate(
    dep_delay = as.integer(dep_delay),
    arr_delay = as.integer(arr_delay),
    air_time = as.integer(air_time)
  )

save(flights, file = "data/flights-2014.rda", compress = "bzip2")
