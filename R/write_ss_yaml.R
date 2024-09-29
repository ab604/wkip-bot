# Write YAML files for shot scraper

# Set-up -----------------------------------------------------------------------
library(dplyr)
library(glue)
library(stringr)
library(readr)
library(purrr)
source('R/shot_scraper_yml.R')

# ------------------------------------------------------------------------------
# Read in article table
all_articles <- read_csv("world-in-progress-articles-2024-09-28.csv")
# Get issue numbers for yml
issues <- all_articles |> distinct(issue_num) 
# Get screenshot prefixes for yml
prfxs <- all_articles |> distinct(screen_shot_prefix) 
# Spotlight article selector
css_spot <- '.spotlight-card'
# Article selectors: Maximum articles is 8
css_art <- c('article.article-card:nth-child(1)',
             'article.article-card:nth-child(2)',
             'article.article-card:nth-child(3)',
             'article.article-card:nth-child(4)',
             'article.article-card:nth-child(5)',
             'article.article-card:nth-child(6)',
             'article.article-card:nth-child(7)')

# Function for yml screenshot output
yml_output_lns <- function(pfx){
  glue("/mnt/c/Users/ab604/Documents/work-in-progress-bot/img/{pfx}.png")
}

# Function for issue url
yml_url_lns <- function(isn){
  glue("https://worksinprogress.co/{isn}/")
}

# ------------------------------------------------------------------------------
# Create yml output lines (yolns) for each issue article
# Create yml issue url line (yulns) for each issue
# Create selector vector for each issue article
n_articles_per_issue <- all_articles |> group_by(issue_num) |> tally()

# Special issue has no spotlight article
yolns <- map_df(prfxs, yml_output_lns) 
yulns <- map_df(issues,yml_url_lns)
# ------------------------------------------------------------------------------
# Write YAML files
# write_custom_yaml <- function(yolns, yulns, selectors, output_file = "output.yaml")

for (i in 1:17) {
  # output lines
  yo <- yolns |>
    filter(str_detect(screen_shot_prefix,issues$issue_num[i])) |> pull()
  # issue line
  yu <- yulns |>
    filter(str_detect(issue_num,issues$issue_num[i])) 
  # number of articles in issue
  n_arts <- n_articles_per_issue |> 
    filter(str_detect(issue_num,issues$issue_num[i])) |> 
    mutate(articles = case_when(issue_num == "special-issue" ~ 6, TRUE ~ n-1))
  # selectors to match number of articles and issue
  if (n_arts$issue_num == "special-issue") {
    ys <- css_art[1:n_arts$n]
  } else {
    ys <- c(css_spot,css_art[1:n_arts$articles])
  }
  # file prefix
  f_pfx <- n_arts$issue_num
  
  # Write yml function
  write_custom_yaml(yolns = yo, yulns = yu, selectors = ys, output_file = glue("yml/{f_pfx}.yml"))
}
