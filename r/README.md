## nycflights14

Scripts and docs are from the
[_nycflights13_](https://github.com/hadley/nycflights13).
data package containing all out-bound flights in 2014 + useful metdata.

Skompresowane pobrane dane są zapisane w katalogu **data**,
dokumentacja jest w katalogu *docs*.

## r & mongodb

* [Getting started with MongoDB in R](https://cran.r-project.org/web/packages/mongolite/vignettes/intro.html)

```r
library(mongolite)

load("data/flights-2014.rda")

m = mongo(collection = "flights14")
m$insert(flights)

# check records
m$count()
nrow(diamonds)
```
