## nycflights14

Scripts and docs are from the
[_nycflights13_](https://github.com/hadley/nycflights13).
data package containing all out-bound flights in 2014 + useful metdata.

Skompresowane pobrane dane są zapisane w katalogu **data**,
dokumentacja jest w katalogu *docs*.

## r & mongodb

* [Getting started with MongoDB in R](https://cran.r-project.org/web/packages/mongolite/vignettes/intro.html)

```{r}
library(mongolite)
```

Import all flights from 2014 and NYC flights from 2014.
```{r}
load("data/flights-2014.rda")

m = mongo(collection = "flights14")
m$insert(flights)

mnyc = mongo(collection = "nycflights14")
mnyc$insert(nycflights14)

# check records
m$count()
nrow(flights)
mnyc$count()
nrow(nycflights14)
```
