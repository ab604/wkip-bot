# Create screenshot YAML -------------------------------------------------------
# All a bit manual!
library(dplyr)
library(glue)
library(stringr)
library(clipr)
library(yaml)
library(readr)

all_articles <- read_csv("world-in-progress-articles-2024-09-28.csv")

issues <- all_articles |> distinct(issue_num) #|> pull()
prfxs <- all_articles |> distinct(screen_shot_prefix) #|> pull()
css_spot <- '.spotlight-card'
css_art <- c('article.article-card:nth-child(1)',
             'article.article-card:nth-child(2)',
             'article.article-card:nth-child(3)',
             'article.article-card:nth-child(4)',
             'article.article-card:nth-child(5)',
             'article.article-card:nth-child(6)',
             'article.article-card:nth-child(7)')

i2pfx <- prfxs |> filter(str_detect(screen_shot_prefix,"issue-02")) |> pull()


yml_output_lns <- function(pfx){
  glue("- output:  /mnt/c/Users/ab604/Documents/work-in-progress-bot/img/{pfx}.png")
}

yml_url_lns <- function(isn){
  glue("url: https://worksinprogress.co/{isn}/")
}

yml_css_lns <- function(css,cn = ''){
  glue("selectors:
        - {css}{cn}
        padding: 10")
}
  
yolns <- yml_output_lns(prfxs)
yulns <- yml_url_lns(issues)
yclns <- yml_css_lns(css = css_spot)
ych <- yml_css_lns(css = css_art,cn = '(1)')

glue("{yolns[1]} 
{yulns[4]}
{yclns}")

# ------------------------------------------------------------------------------
yml_output_lns <- function(pfx){
  glue("/mnt/c/Users/ab604/Documents/work-in-progress-bot/img/{pfx}.png")
}

yml_url_lns <- function(isn){
  glue("https://worksinprogress.co/{isn}/")
}

si_pfx <- prfxs |> filter(str_detect(screen_shot_prefix,"special-"))
sisn <- issues |> filter(str_detect(issue_num,"special-"))

yolns <- yml_output_lns(si_pfx$screen_shot_prefix)
yulns <- yml_url_lns(sisn$issue_num)
#yclns <- yml_css_lns(css = css_spot)

ydf <- tibble(output = yolns,
              url = rep(yulns,length(yolns)),
              selectors = c(css_spot,css_art[1:5]),
              padding =rep(10,length(yolns)),
              )

# ------------------------------------------------------------------------------
# Your vector of file paths
yolns <- yml_output_lns(si_pfx$screen_shot_prefix)
yulns <- yml_url_lns(sisn$issue_num)
#selectors <-  c(css_spot,css_art[2:5])
selectors <-  css_art[1:6]

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
writeLines(yaml_output, "yml/special-issue.yml")
