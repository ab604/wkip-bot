# Tuesday repost
library(atrrr)
library(glue)
library(dplyr)
library(readr)
library(lubridate)
library(stringr)
source("R/get-post-uri-by-date.R")
source("R/repost.R")

# Authenticate 
auth(user = "wkipbot.bsky.social",
     password = Sys.getenv("WIP_PW"),
     overwrite = TRUE)

# Get Sunday post
post_uri <- get_post_uri_by_date(
  handle = "@wkipbot.bsky.social", 
  target_date = Sys.Date() - 1,  # yesterday's date
  username =  "@wkipbot.bsky.social", 
  app_password =  Sys.getenv("WIP_PW"))

# Repost
repost(
  post_uri, 
  username = "@wkipbot.bsky.social", 
  app_password = Sys.getenv("WIP_PW"))