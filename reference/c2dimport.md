# Import row data from an (unpacked) c2d file.

**\[experimental\]**

This function is for basic testing. The goal is to load directly from
C2D files, not just unpacked XML.

## Usage

``` r
c2dimport(path = "path/to/your/example.xml")
```

## Arguments

- path:

  Path to an XML file (i.e., an unpacked c2d file).

## Value

dataframe containing the row data.

## Examples

``` r
# data <- c2dimport("path/to/your/example.xml")
```
