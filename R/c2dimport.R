#' Import row data from a Cyclus2 .c2d file.
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This function is currently experimental.
#' The function loads the data Header and Rows from .c2d files.
#'
#' @param path Path to a C2D file (i.e., a gzipped XML file).
#'
#' @returns dataframe containing the row data.
#' @export
#'
#' @examples
#' # rowdata <- c2dimport("path/to/your/example.c2d")
#'
c2dimport <- function(path = "path/to/your/example.c2d") {
  lifecycle::signal_stage("experimental", "c2dimport()")
  # read in a .c2d file (i.e., a gzipped XML file)
  xml_content <- xml2::read_xml(gzcon(file(path, "rb")))
  # extract the <Header> node, containing the column names for <Rows> data,
  # something like "<Header>idStageIndex;idTime;idDistance;...</Header>"
  header_node <- xml2::xml_find_first(xml_content, ".//Header")
  # extract column names from the <Header> node
  column_names <- unlist(strsplit(xml2::xml_text(header_node), ";"))
  # extract the <Rows> node
  rows_node <- xml2::xml_find_first(xml_content, ".//Rows")
  # extract all <R*> nodes within <Rows>
  r_nodes <- xml2::xml_children(rows_node)
  # convert each <R*> node to a data frame row
  data_list <- lapply(r_nodes, function(node) {
    as.numeric(unlist(strsplit(xml2::xml_text(node), ";")))
  })
  # combine all rows into a single data frame
  data_df <- do.call(rbind, data_list)
  # assign column names to the data frame
  colnames(data_df) <- column_names
  # return the resulting data frame
  return(as.data.frame(data_df))
}
