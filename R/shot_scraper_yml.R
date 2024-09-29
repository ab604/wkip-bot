# Shot-scraper yaml writer
# A.Bailey 2024-09-29
library(yaml)
library(glue)

write_custom_yaml <- function(yolns, yulns, selectors, output_file = "output.yaml") {
  # Function to ensure strings are quoted
  quote_strings <- function(x) {
    if (is.character(x)) {
      return(paste0('"', gsub('"', '\\"', x), '"'))
    }
    return(x)
  }
  
  # Create a list to hold the YAML data
  yaml_data <- list()
  
  # Create the data structure
  for (i in seq_along(yolns)) {
    yaml_data[[i]] <- list(
      output = quote_strings(as.character(yolns[i])),
      url = quote_strings(as.character(yulns)),
      selectors = list(quote_strings(as.character(selectors[i]))),
      padding = 10
    )
  }
  
  # Convert to YAML
  yaml_output <- as.yaml(yaml_data, indent.mapping.sequence = TRUE, handlers = list(
    character = function(x) x
  ))
  
  # Remove any remaining single quotes
  yaml_output <- gsub("'\"", "\"", yaml_output)
  yaml_output <- gsub("\"'", "\"", yaml_output)
  
  # Write YAML to file
  writeLines(yaml_output, output_file)
  
  cat("YAML file has been written to:", output_file, "\n")
}
