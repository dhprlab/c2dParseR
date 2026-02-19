# Import data from a Cyclus2 .c2d file.

**\[experimental\]**

Load the Athlete data, CycleData, and the Row data from a .c2d file into
a single tidyverse tibble. This function is currently experimental, but
hopefully already useful.

## Usage

``` r
c2dimport(path = "path/to/your/example.c2d")
```

## Arguments

- path:

  Path to a C2D file (i.e., a gzipped XML file).

## Value

A tibble containing the Athlete, Cycle, and Row data.

## Examples

``` r
# data <- c2dimport("path/to/your/example.c2d")
```
