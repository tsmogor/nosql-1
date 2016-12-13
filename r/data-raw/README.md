## NYC Flights, 2015

* Modified scripts from the [nycflights13](https://github.com/hadley/nycflights13)
  R package.
* [METAR Information for EPGD (12150) in Gdansk-Rebiechowo, Poland](http://weather.gladstonefamily.net/site/EPGD).

Importing data into databases:

* [The _dplyr_ vignette on Databases](https://cran.r-project.org/web/packages/dplyr/vignettes/databases.html)
* [Getting started with MongoDB in R](https://cran.r-project.org/web/packages/mongolite/vignettes/intro.html)

How to add **id** attribute to existing tibble?

First, generate migration and run it:
```sh
rails g migration CreateFlights \
  origin dest distance:integer dep_delay:integer arr_delay:integer \
  air_time:integer tailnum \
  dep_time:datetime sched_dep_time:datetime arr_time:datetime sched_arr_time:datetime
rails db:migrate
```
Add indexes:
```ruby
# migrate/006_create_flights.rb
class CreateFlights < ActiveRecord::Migration[5.0]
  def change
    create_table :flights do |t|
      t.string :origin
      t.string :dest
      t.integer :distance
      t.integer :dep_delay
      t.integer :arr_delay
      t.datetime :dep_time
      t.datetime :sched_dep_time
      t.datetime :arr_time
      t.datetime :sched_arr_time
      t.integer :air_time
      t.string :tailnum

      t.index ['origin'], name: 'index_flights_on_origin'
      t.index ['dest'], name: 'index_flights_on_dest'
    end
  end
end
```

Load data into RStudio:

```r
setwd("~/Repos/rails4/why_associations_5.0/db")
# source("data-raw/flights-2014.r")

library(tibble)
library(dplyr)
library(DBI)

load("data/flights-2014.rda")
ls()

flights <- flights %>%
  arrange(dep_time)
# A tibble: 5,690,183 × 11
#    origin  dest distance dep_delay arr_delay            dep_time      sched_dep_time
#     <chr> <chr>    <dbl>     <dbl>     <dbl>              <dttm>              <dttm>
# 1     PDX   ANC     1542        96        70 2014-01-01 00:01:00 2014-01-01 22:25:00
# 2     SFO   PHX      651       109       106 2014-01-01 00:01:00 2014-01-01 22:12:00
# ... with 5,690,173 more rows, and 4 more variables: arr_time <dttm>, sched_arr_time <dttm>,
#   air_time <dbl>, id <int>

# import into MongoDB
# https://cran.r-project.org/web/packages/mongolite/vignettes/intro.html
library(mongolite)
m <- mongo(collection = "flights")
m$insert(flights)
```


```r
my_db = src_sqlite("development.sqlite3", create = FALSE)
mydb <- dbConnect(RSQLite::SQLite(), "development.sqlite3")
dbWriteTable(mydb, "flights", flights)

# see http://www.sqlite.org/datatype3.html
# flights = flights %>%
#   mutate(
#     dep_time = as.character(dep_time),
#     sched_dep_time = as.character(sched_dep_time),
#     arr_time = as.character(arr_time),
#     sched_arr_time = as.character(sched_arr_time))

flights_sqlite = copy_to(
  my_db,
  flights,
  temporary = FALSE
  # indexes = list("origin", "dest")
)

select(flights_sqlite, dep_delay, arr_delay)
filter(flights_sqlite, dep_delay > 240)
arrange(flights_sqlite, dep_time)
mutate(flights_sqlite, speed = air_time / distance)
summarise(flights_sqlite, delay = mean(dep_delay))
```

Bash:
```sh
rails db:schema:dump
cat db/schema.rb
```
```ruby
create_table "flights", id: false, force: :cascade do |t|
  t.text    "origin"
  t.text    "dest"
  t.        "distance"
  t.        "dep_delay"
  t.        "arr_delay"
  t.        "dep_time"
  t.        "sched_dep_time"
  t.        "arr_time"
  t.        "sched_arr_time"
  t.        "air_time"
  t.integer "id"
  t.index ["dest"], name: "flights_dest"
  t.index ["id"], name: "flights_id"
  t.index ["origin"], name: "flights_origin"
end
```

Handling DateTimes on Rails console:
```ruby
f1 = Flight.first
DateTime.parse(f1.dep_time)
```

SQLite shell:
``````sh
sqlite3 development.sqlite3
sqlite> .schema --indent flights
```
```sql
CREATE TABLE `flights`(
  `origin` TEXT,
  `dest` TEXT,
  `distance` REAL,
  `dep_delay` REAL,
  `arr_delay` REAL,
  `dep_time` REAL,
  `sched_dep_time` REAL,
  `arr_time` REAL,
  `sched_arr_time` REAL,
  `air_time` REAL,
  `id` INTEGER
);
CREATE INDEX `flights_id` ON `flights`(`id`);
CREATE INDEX `flights_origin` ON `flights`(`origin`);
CREATE INDEX `flights_dest` ON `flights`(`dest`);
.q
```
