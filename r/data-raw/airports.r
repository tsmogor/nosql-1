library(dplyr)
library(readr)
library(purrr)
library(ggplot2)

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

# verify the results: possibly misaligned Charleston or Savannach
airports %>%
  filter(lon < 0) %>%
  ggplot(aes(lon, lat)) +
    geom_point(aes(colour = factor(tz)), show.legend = FALSE) +
    coord_quickmap()

# write_csv(airports, bzfile("data-raw/airports.csv.bz2"))         -- does not work
# write_csv(airports, "data-raw/airports.csv", compress = "bzip2") -- does not work, too

write.csv(airports, gzfile("data-raw/airports.csv.gz"))
save(airports, file = "data/airports.rda", compress = "bzip2")

# Polish airports
airports_pl <- raw %>%
  filter(country == "Poland", faa != "") %>%
  select(faa, name, lat, lon, alt, tz, dst, tzone) %>%
  group_by(faa) %>% slice(1) %>% ungroup() # take first if duplicated

write.csv(airports_pl, gzfile("data-raw/airports_pl.csv.gz"))
save(airports_pl, file = "data/airports_pl.rda", compress = "bzip2")

# Russia airports
airports_ru <- raw %>%
  filter(country == "Russia", faa != "") %>%
  select(faa, name, lat, lon, alt, tz, dst, tzone) %>%
  group_by(faa) %>% slice(1) %>% ungroup() # take first if duplicated

airports_ru %>%
  filter(lon > 18) %>%
  ggplot(aes(lon, lat)) +
  geom_point(aes(colour = factor(tz)), size = 4) +
  scale_colour_discrete(name = "tz") +
  coord_quickmap()

write.csv(airports_ru, gzfile("data-raw/airports_ru.csv.gz"))
save(airports_ru, file = "data/airports_ru.rda", compress = "bzip2")
