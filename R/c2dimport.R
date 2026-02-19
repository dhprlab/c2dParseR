#' Import data from a Cyclus2 .c2d file.
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Load the Athlete data, CycleData, and the Row data from a .c2d file
#' into a single tidyverse tibble.
#' This function is currently experimental, but hopefully already useful.
#'
#' @param path Path to a C2D file (i.e., a gzipped XML file).
#'
#' @returns A tibble containing the Athlete, Cycle, and Row data.
#' @export
#'
#' @examples
#' # data <- c2dimport("path/to/your/example.c2d")
#'
c2dimport <- function(path = "path/to/your/example.c2d") {
  lifecycle::signal_stage("experimental", "c2dimport()")
  # read in a .c2d file (i.e., a gzipped XML file)
  xml_content <- xml2::read_xml(gzcon(file(path, "rb")))
  # find Athlete node and extract all fields (except 'tp') into a list
  athlete_node <- xml2::xml_find_first(xml_content, ".//Athlete")
  athlete_fields <- c("Firstname", "Name", "Sex", "DoB", "Area",
                      "Weight", "Height", "Cw")
  athlete_node <- xml2::xml_find_first(xml_content, ".//Athlete")
  athlete_data <- purrr::map(athlete_fields, function(field) {
    field_xpath <- paste0("./", field)
    value <- xml2::xml_text(xml2::xml_find_first(athlete_node, field_xpath))
    # convert fields to appropriate types
    if (field == "Sex") {
      as.integer(value)  # FIXME: translate possible values to their meaning
    } else if (field %in% c("Area", "Weight", "Height", "Cw")) {
      as.numeric(value)
    } else {
      value
    }
  })
  names(athlete_data) <- athlete_fields
  # find CycleData node and extract all fields into a list
  cycle_node <- xml2::xml_find_first(xml_content, ".//CycleData")
  cycle_fields <- c("crank", "perim", "weight", "front",
                    "rear", "vfront", "vrear")
  cycle_data <- purrr::map(cycle_fields, function(field) {
    field_xpath <- paste0("./", field)
    value <- xml2::xml_text(xml2::xml_find_first(cycle_node, field_xpath))
    as.numeric(value)
  })
  names(cycle_data) <- cycle_fields
  # extract the <Header> node, containing the column names for <Rows> data
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
  # combine all rows into a tidyverse tibble
  row_tbl <- dplyr::as_tibble(do.call(rbind, data_list),
    .name_repair = "minimal"
  )
  # add the column names from the <Header> node
  colnames(row_tbl) <- column_names
  # add athlete and cycle data as columns, each with same value for all rows
  for (field in athlete_fields) {
    row_tbl[[field]] <- athlete_data[[field]]
  }
  for (field in cycle_fields) {
    row_tbl[[field]] <- cycle_data[[field]]
  }
  # reorder columns; 1) athlete data, 2) cycle data, 3) row data
  full_tbl <- row_tbl %>%
    dplyr::select(
      dplyr::all_of(athlete_fields),
      dplyr::all_of(cycle_fields),
      dplyr::everything()
    )
  return(full_tbl)
}
