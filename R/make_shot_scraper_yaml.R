# Create screenshot YAML -------------------------------------------------------
# All a bit manual!
library(dplyr)
library(glue)
library(stringr)
library(clipr)
# Use screenshot prefix
prefix <- all_articles |> filter(issue_num == "issue-03") |> pull(screen_shot_prefix)
issue_num <- all_articles |> filter(issue_num == "issue-03") |> pull(issue_num)

output_ln <- glue("- output:  /mnt/c/Users/ab604/Documents/work-in-progress-bot/img/{prefix}.png")
issue_ln <- glue("url: https://worksinprogress.co/{issue_num}/")

output_ln |> write_clip()
issue_ln[1] |> write_clip()