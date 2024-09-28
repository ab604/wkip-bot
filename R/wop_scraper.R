# Work in progress scraper
# A. Bailey 2024-09-28

# Set-up -----------------------------------------------------------------------
library(rvest)
library(dplyr)
library(purrr)
library(glue)
library(stringr)
library(readr)
library(tidyr)
library(lubridate)
set.seed(1914)

# Scrape data ------------------------------------------------------------------

# Works in Progress home
base_url <- "https://worksinprogress.co"

# Get issues
issues <- glue("{base_url}/archive") |> 
  read_html() |> 
  html_elements(".issue-card__title-bar") |> 
  html_attr("href") |> 
  unique()

# Create issues URLs
issues_url <- glue("{base_url}{issues}")

# Scrape the list of spotlight articles
spotlight_df <- issues_url |> 
  set_names() |>
  map(~{
    issue_num <- str_extract(.x, "(?<=/)[^/]+(?=/[^/]*$)") |>
      str_remove("/")
    
    html <- read_html(.x)
    
    list(
      url = base_url,
      issue_num = issue_num,
      
      # Spotlight card
      card_text = html |>
        html_elements(".spotlight-card") |>
        html_text(),
      # Spotlight slug
      card_slug = html |>
        html_elements(".spotlight-card__title") |>
        html_nodes("a") |>
        html_attr("href") |>
        str_extract("issue/.*")
    )
  }) |> 
  # Convert the list to a dataframe
  bind_rows()

## Scrape the list of all the other articles  
articles_df <- issues_url |>
  set_names() |>
  map(~{
    issue_num <- str_extract(.x, "(?<=/)[^/]+(?=/[^/]*$)") |>
      str_remove("/")
    
    html <- read_html(.x)
    
    list(
      url = base_url,
      issue_num = issue_num,
      # Read card
      card_text = html |> 
        html_elements("article.article-card") |> 
        html_text(),
      
      # Get slug
      card_slug = html |> 
        html_elements(".article-card__head") |> 
        html_nodes("a") |> 
        html_attr("href") |> 
        str_extract("issue/.*") |> 
        na.omit()
    )
  }) |> 
  # Convert the list to a dataframe
  bind_rows()

# Create a vector of weeks for posting one article a week. There are 115 articles
weeks_vector <- seq(ymd("2024-10-01"), by = "week", length.out = 115)

# Create articles tibble
all_articles <- bind_rows(spotlight_df, articles_df) |>
  mutate(
    title = case_when(
      str_detect(card_text, "Spotlight") ~ str_extract(card_text, "(?<=\\d\\d).*?\\w+(?=[A-Z])"),
      TRUE ~ str_extract(card_text, ".*?(?=Wor)")
    ),
    id = row_number(),
    post_week = sample(weeks_vector, replace = FALSE),
    post_article_url = glue("{url}/{card_slug}"),
    post_issue_url = glue("{url}/{issue_num}/")
  ) |>
  arrange(issue_num) |>
  mutate(screen_shot_prefix = glue("{issue_num}-{row_number()}"))

all_articles |> 
  write_csv("world-in-progress-articles-2024-09-28.csv")

# Create screenshot YAML -------------------------------------------------------
# All a bit manual!
library(clipr)
# Use screenshot prefix
prefix <- all_articles |> filter(issue_num == "issue-03") |> pull(screen_shot_prefix)
issue_num <- all_articles |> filter(issue_num == "issue-03") |> pull(issue_num)

output_ln <- glue("- output:  /mnt/c/Users/ab604/Documents/work-in-progress-bot/img/{prefix}.png")
issue_ln <- glue("url: https://worksinprogress.co/{issue_num}/")

output_ln |> write_clip()
issue_ln[1] |> write_clip()



