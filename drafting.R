# PURPOSE: Drafting script to read in a .c2d file and convert it to data frames.
#
# SPDX-FileCopyrightText: 2025 Johannes Keyser <johannes.keyser@uni-hamburg.de>
# SPDX-License-Identifier: EUPL-1.2

library(xml2)

# Read in a XML file (i.e., a unzipped .c2d file)
xml_input <- xml2::read_xml("path/to/your/example.xml")

# Read the XML snippet
xml_input <- xml2::read_xml(xml_input)
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
