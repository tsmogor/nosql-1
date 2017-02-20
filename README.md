# Technologie NoSQL

Terminarz rozliczania się z [projektów](http://wbzyl.inf.ug.edu.pl/nosql/zadania):

| projekt              | zadanie                  | deadline    |
|----------------------|--------------------------|-------------|
| przygotowanie danych | EDA (0, 1, 2)            |             |
| zaliczenie           | Aggregation Pipeline (3) | 23.04.2017  |
| egzamin              | MapReduce (4)            | 21.05.2017  |

Link do **prywatnego** repozytorium z rozwiązaniami zadań należy wpisać odpowiednio
w pliku [projects.md](projects.md).

[Link do szablonu repozytorium](https://github.com/egzamin/solutions-nosql).


## Podręczne linki

1. [Git Tips](https://github.com/git-tips/tips) – most commonly used git tips and tricks
1. [Awesome Public Datasets](https://github.com/caesar0301/awesome-public-datasets)
1. [Emoji cheat sheet](http://www.webpagefx.com/tools/emoji-cheat-sheet) –
  do wykorzystania w dokumentacji.

Więcej danych:

* [Watching Our World Unfold](http://www.gdeltproject.org):
  - [Querying, Analyzing and Downloading](http://www.gdeltproject.org/data.html);
    [raw data files](http://www.gdeltproject.org/data.html)
* [NOAA](https://www.ncdc.noaa.gov/data-access) –
  National Centers for Environmental Information (US)


## Simple Rules for Reproducible Computations

Provide public access to scripts, runs, and results:

1. Version control all custom scripts:
  - avoid writing code
  - **write thin scripts** and use standard tools and use standard UNIX
    commands to chain things together.
1. Avoid manual data manipulation steps:
  - use a build system, for example [**make**](http://bost.ocks.org/mike/make/),
    and have all results produced automatically by build targets
  - if it’s not automated, it’s not part of the project,
    i.e. have an idea for a graph or an analysis?
    automate its generation
1. Use a markup, for example
   [**Markdown**](http://daringfireball.net/projects/markdown/syntax), or
   [**AsciiDoctor**](http://asciidoctor.org)
   to create reports for analysis and presentation output products.

Plus two more rules:

1. Record all intermediate results, when possible in standardized formats.
1. Connect textual statements to underlying results.

Three more links:

* [The Quartz guide to bad data](https://github.com/Quartz/bad-data-guide) –
  an exhaustive reference to problems seen in real-world data along
  with suggestions on how to resolve them.
* [How to share data with a statistician](https://github.com/jtleek/datasharing) –
  it is critical that you include the rawest form of the data that you have access to.
* Przykładowy (i interesujący) projekt w SQL:
  Georgios Gousios.
  [Assessment of the pull based development model, as implemented by Github](https://github.com/gousiosg/pullreqs)


## Gigabajtowe pliki z danymi

Spakowany plik _RC_2015-01.bz2_ zajmuje na dysku 5_452_413_560 B,
czyli ok. 5.5 GB. Każda linijka pliku to jeden obiekt JSON, komentarz
z serwisu Reddit, z tekstem komentarza, autorem, itd.
Wszystkich komentarzy/JSON-ów powinno być 53_851_542.

```bash
bunzip2 --stdout RC_2015-01.bz2 | head -1 | jq .
time bunzip2 --stdout RC_2015-01.bz2 | rl --count 1000 > RC_2015-01_1000.json
# real   ∞ s
# user   ∞ s
# sys	0m12 s
time bunzip2 -c RC_2015-01.bz2 | mongoimport --drop --host 127.0.0.1 -d test -c reddit
# 2015-10-09T19:49:35.698+0200	test.reddit	29.5 GB
# 2015-10-09T19:49:35.698+0200	imported 53851542 documents

# real  38m40.629s
# user  56m37.200s
# sys   1m17.074s
```

![RC mongoimport](images/RC_mongoimport_WiredTiger.png)


Plik _primer-dataset.json_ informacje o restauracjach w Nowym Jorku.

```bash
wget https://raw.githubusercontent.com/mongodb/docs-assets/primer-dataset/dataset.json
cat dataset.json | gzip --stdout > primer-dataset.json.gz
rm dataset.json

gunzip -c primer-dataset.json.gz | shuf -n 1
gunzip -c primer-dataset.json.gz | rl   -c 1
```
