# Import Data from a Cyclus2 `.c2d` File

Reads a Cyclus2 ergometer `.c2d` file (a gzipped XML document) and
returns its contents as a tidy tibble. The output merges athlete
metadata, cycle configuration data, and row‑level measurement records
into a single table.

## Usage

``` r
c2dimport(path)
```

## Arguments

- path:

  A file path to a `.c2d` file. Must be a single string.

## Value

A tibble with:

- athlete metadata columns

- cycle metadata columns

- row‑level measurement data

Columns are ordered as:

1.  athlete fields

2.  cycle fields

3.  measurement variables

## Details

The function is currently marked as experimental and may change in
future versions of the package.

## File Structure

A `.c2d` file typically contains the following XML sections:

- `<Athlete>`: athlete metadata

- `<CycleData>`: ergometer configuration

- `<Header>`: column names for row data

- `<Rows>` with child `<R*>` nodes: measurement rows

## Error Handling

The function stops with an informative error message if:

- the file does not exist

- the XML cannot be parsed

- required nodes (`<Athlete>`, `<CycleData>`, `<Header>`, `<Rows>`) are
  missing

## See also

- [`xml2::read_xml()`](http://xml2.r-lib.org/reference/read_xml.md)

- [`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html)

## Examples

``` r
if (FALSE) { # \dontrun{
  data <- c2dimport("example.c2d")
  print(data)
} # }
```
