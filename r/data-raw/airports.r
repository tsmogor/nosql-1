library(dplyr)
library(readr)
library(purrr)

if (!file.exists("data-raw/airports.dat")) {
  download.file(
    "https://raw.githubusercontent.com/jpatokal/openflights/master/data/airports.dat",
    "data-raw/airports.dat"
  )
}

# see also docs/airports.r and http://openflights.org/data.html for file format
#
# the last three fields:
#   tz -- hours offset from UTC
#               fractional hours are expressed as decimals,
#               eg. India is 5.5
#   dst -- daylight savings time
#          one of E (Europe), A (US/Canada), S (South America), O (Australia),
#          Z (New Zealand), N (None) or U (Unknown)
#   tzone database time zone -- tz Olson format

raw <- read_csv("data-raw/airports.dat",
  col_names = c("id", "name", "city", "country", "faa", "icao", "lat", "lon", "alt", "tz", "dst", "tzone")
)

airports <- raw %>%
  filter(country == "United States", faa != "") %>%
  select(faa, name, lat, lon, alt, tz, dst, tzone) %>%
  group_by(faa) %>% slice(1) %>% ungroup() # take first if duplicated

# no geonamesUsername set. See http://geonames.wordpress.com/2010/03/16/ddos-part-ii/
# and set one with options(geonamesUsername="foo") for some services to work
# options(geonamesUsername="wbzyl")

# find time zones
# get_tz <- function(lat, lon) {
#  cat(".")
#  GNtimezone(lat, lon)
# }
# tz <- map2(airports$lat, airports$lon, safely(get_tz))
# tz <- transpose(tz)

# ok <- tz$error %>% map_lgl(is.null)
# airports[!ok, ]
# airports = airports[ok, ]

# airports$tzone <- tz$result[ok] %>%
#  map("timezoneId", .null = NA) %>%
#  map_chr(as.character)

# Verify the results: possibly misaligned Charleston or Savannach
library(ggplot2)
airports %>%
  filter(lon < 0) %>%
  ggplot(aes(lon, lat)) +
    geom_point(aes(colour = factor(tz)), show.legend = FALSE) +
    coord_quickmap()

# write_csv(airports, bzfile("data-raw/airports.csv.bz2"))         -- does not work
# write_csv(airports, "data-raw/airports.csv", compress = "bzip2")
write.csv(airports, bzfile("data-raw/airports.csv.bz2"))
save(airports, file = "data/airports.rda", compress = "bzip2")
