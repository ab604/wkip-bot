get_post_uri_by_date <- function(handle, target_date, username, app_password) {
  library(httr)
  library(jsonlite)
  library(lubridate)

  # Function to sanitize usernames
  sanitize_username <- function(name) {
    name <- gsub("^@", "", name)  # Remove leading @
    if (!grepl("\\.bsky\\.social$", name)) {
      name <- paste0(name, ".bsky.social")  # Append .bsky.social if not present
    }
    return(name)
  }

  # Sanitize inputs
  handle <- sanitize_username(handle)
  username <- sanitize_username(username)

  # Convert target_date to Date object if it's not already
  target_date <- as.Date(target_date)

  # Authenticate
  auth_url <- "https://bsky.social/xrpc/com.atproto.server.createSession"
  auth_body <- list(identifier = username, password = app_password)
  auth_response <- POST(auth_url, body = auth_body, encode = "json")
  
  if (http_status(auth_response)$category != "Success") {
    stop("Authentication failed: ", content(auth_response, "text", encoding = "UTF-8"))
  }
  
  auth_data <- content(auth_response, "parsed")
  access_token <- auth_data$accessJwt

  # Create a function to make authenticated requests
  make_auth_request <- function(url, query = list()) {
    response <- GET(url, query = query, add_headers(Authorization = paste("Bearer", access_token)))
    if (http_status(response)$category != "Success") {
      stop(paste("API request failed:", content(response, "text", encoding = "UTF-8")))
    }
    return(response)
  }

  # Get the user's DID
  profile_url <- "https://bsky.social/xrpc/app.bsky.actor.getProfile"
  profile_response <- make_auth_request(profile_url, query = list(actor = handle))
  profile_data <- content(profile_response, "parsed")

  did <- profile_data$did

  # Function to fetch a page of posts
  fetch_posts <- function(cursor = NULL) {
    posts_url <- "https://bsky.social/xrpc/app.bsky.feed.getAuthorFeed"
    query <- list(actor = did, limit = 100)
    if (!is.null(cursor)) {
      query$cursor <- cursor
    }
    posts_response <- make_auth_request(posts_url, query = query)
    return(content(posts_response, "parsed"))
  }

  cursor <- NULL
  found_post <- NULL

  repeat {
    posts_data <- fetch_posts(cursor)
    
    if (length(posts_data$feed) == 0) {
      break  # No more posts
    }

    for (post in posts_data$feed) {
      post_date <- as.Date(substr(post$post$record$createdAt, 1, 10))
      if (post_date == target_date) {
        found_post <- post$post$uri
        break
      } else if (post_date < target_date) {
        # We've gone past the target date, stop searching
        break
      }
    }

    if (!is.null(found_post) || post_date < target_date) {
      break
    }

    cursor <- posts_data$cursor
    if (is.null(cursor)) {
      break  # No more pages
    }
  }

  return(found_post)
}
