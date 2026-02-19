# Import row data from a Cyclus2 .c2d file.

**\[experimental\]**

This function is currently experimental. The function loads the data
Header and Rows from .c2d files.

## Usage

``` r
c2dimport(path = "path/to/your/example.c2d")
```

## Arguments

- path:

  Path to a C2D file (i.e., a gzipped XML file).

## Value

dataframe containing the row data.

## Examples

``` r
# rowdata <- c2dimport("path/to/your/example.c2d")
```
