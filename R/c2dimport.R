#' Import Data from a Cyclus2 `.c2d` File
#'
#' Reads a Cyclus2 ergometer `.c2d` file (a gzipped XML document) and returns
#' its contents as a tidy tibble. The output merges athlete metadata, cycle
#' configuration data, and row‑level measurement records into a single table.
#'
#' The function is currently marked as experimental and may change in future
#' versions of the package.
#'
#' @param path A file path to a `.c2d` file. Must be a single string.
#'
#' @return
#' A tibble with:
#' - athlete metadata columns
#' - cycle metadata columns
#' - row‑level measurement data
#'
#' Columns are ordered as:
#' 1. athlete fields
#' 2. cycle fields
#' 3. measurement variables
#'
#' @section File Structure:
#' A `.c2d` file typically contains the following XML sections:
#' - `<Athlete>`: athlete metadata
#' - `<CycleData>`: ergometer configuration
#' - `<Header>`: column names for row data
#' - `<Rows>` with child `<R*>` nodes: measurement rows
#'
#' @section Error Handling:
#' The function stops with an informative error message if:
#' - the file does not exist
#' - the XML cannot be parsed
#' - required nodes (`<Athlete>`, `<CycleData>`, `<Header>`, `<Rows>`) are missing
#'
#' @seealso
#' - \code{xml2::read_xml()}
#' - \code{tibble::as_tibble()}
#'
#' @examples
#' \dontrun{
#'   data <- c2dimport("example.c2d")
#'   print(data)
#' }
#'
#' @export
c2dimport <- function(path) {
  lifecycle::signal_stage("experimental", "c2dimport()")

  # Validate input
  if (!is.character(path) || length(path) != 1) {
    stop("`path` must be a single file path.", call. = FALSE)
  }
  if (!file.exists(path)) {
    stop("File does not exist: ", path, call. = FALSE)
  }

  # Read gzipped XML
  con <- gzcon(file(path, "rb"))
  xml <- tryCatch(
    xml2::read_xml(con),
    error = function(e) stop("Failed to read .c2d file: ", e$message, call. = FALSE)
  )
  close(con)

  # Extract the text content of a named child node
  xml_text_field <- function(node, field) {
    child <- xml2::xml_find_first(node, paste0("./", field))
    xml2::xml_text(child)
  }

  # Athlete metadata
  athlete_fields <- c("Firstname", "Name", "Sex", "DoB",
                      "Area", "Weight", "Height", "Cw")

  athlete_node <- xml2::xml_find_first(xml, ".//Athlete")
  if (is.na(xml2::xml_name(athlete_node))) {
    stop("Missing <Athlete> node in .c2d file.", call. = FALSE)
  }

  athlete_values <- lapply(
    athlete_fields,
    function(f) xml_text_field(athlete_node, f)
  )
  names(athlete_values) <- athlete_fields

  # Convert selected athlete fields to numeric
  for (nm in c("Area", "Weight", "Height", "Cw")) {
    athlete_values[[nm]] <- as.numeric(athlete_values[[nm]])
  }
  athlete_values[["Sex"]] <- as.integer(athlete_values[["Sex"]])

  # Cycle metadata
  cycle_fields <- c("crank", "perim", "weight", "front",
                    "rear", "vfront", "vrear")

  cycle_node <- xml2::xml_find_first(xml, ".//CycleData")
  if (is.na(xml2::xml_name(cycle_node))) {
    stop("Missing <CycleData> node in .c2d file.", call. = FALSE)
  }

  cycle_values <- lapply(
    cycle_fields,
    function(f) as.numeric(xml_text_field(cycle_node, f))
  )
  names(cycle_values) <- cycle_fields

  # Row measurement data
  header_node <- xml2::xml_find_first(xml, ".//Header")
  if (is.na(xml2::xml_name(header_node))) {
    stop("Missing <Header> node in .c2d file.", call. = FALSE)
  }
  col_names <- strsplit(xml2::xml_text(header_node), ";")[[1]]

  rows_node <- xml2::xml_find_first(xml, ".//Rows")
  if (is.na(xml2::xml_name(rows_node))) {
    stop("Missing <Rows> node in .c2d file.", call. = FALSE)
  }

  row_nodes <- xml2::xml_children(rows_node)

  # Convert each <R*> to a tibble row
  row_list <- lapply(
    row_nodes,
    function(node) {
      values <- strsplit(xml2::xml_text(node), ";")[[1]]
      numeric_vals <- as.numeric(values)
      tibble::as_tibble_row(stats::setNames(as.list(numeric_vals), col_names))
    }
  )

  # Combine measurement rows
  data_tbl <- tibble::as_tibble(do.call(rbind, row_list))

  # Append metadata (recycles across rows)
  for (nm in athlete_fields) data_tbl[[nm]] <- athlete_values[[nm]]
  for (nm in cycle_fields)   data_tbl[[nm]] <- cycle_values[[nm]]

  # Final column order: Athlete → Cycle → Measurements
  ordered_cols <- c(
    athlete_fields,
    cycle_fields,
    setdiff(names(data_tbl), c(athlete_fields, cycle_fields))
  )

  tibble::as_tibble(data_tbl[ordered_cols])
}
