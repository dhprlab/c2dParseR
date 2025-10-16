#' Import row data from an (unpacked) c2d file.
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This function is for basic testing.
#' The goal is to load directly from C2D files, not just unpacked XML.
#'
#' @param path Path to an XML file (i.e., an unpacked c2d file).
#'
#' @returns dataframe containing the row data.
#' @export
#'
#' @examples
#' # data <- c2dimport("path/to/your/example.xml")
#'
c2dimport <- function(path = "path/to/your/example.xml") {
  lifecycle::signal_stage("experimental", "c2dimport()")
  # Read in a XML file (i.e., a unzipped .c2d file)
  xml_input <- xml2::read_xml(path)
  # Extract the <Rows> node
  rows_node <- xml2::xml_find_first(xml_input, ".//Rows")
  # Extract all <R*> nodes within <Rows>
  r_nodes <- xml2::xml_children(rows_node)
  # Convert each <R*> node to a data frame row
  data_list <- lapply(r_nodes, function(node) {
    as.numeric(unlist(strsplit(xml2::xml_text(node), ";")))
  })
  # Combine all rows into a single data frame
  data_df <- do.call(rbind, data_list)
}
