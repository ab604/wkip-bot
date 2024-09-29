# Bluesky post script
library(atrrr)
library(glue)
library(dplyr)
library(readr)
library(lubridate)
library(stringr)

# Import data
df <- read_csv("wkip-articles-2024-09-28.csv")

# Get this weeks article
this_week <- df |> 
  arrange(post_week) |> 
  filter(post_week >= today() & post_week < today()+7)

# Get the issue number of the article
IN <- str_extract(this_week$issue_num,"(?<=issue-).*")

# Path to article screenshot
this_weeks_screenshot <- glue("img/{this_week$screen_shot_prefix}.png")

# Create the post
post_text <- glue("{this_week$title}.\nRead the article: {this_week$post_article_url}\nFrom Works in Progress Issue {IN}: {this_week$post_issue_url}")

# Authenticate 
auth(user = "wkipbot.bsky.social",
     password = Sys.getenv("WIP_PW"),
     overwrite = TRUE)

# Post skeet
post(post_text,
     image = this_weeks_screenshot,
     image_alt = this_week$title)
