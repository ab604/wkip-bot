repost <- function(post_uri, text = NULL, username, app_password, created_at = Sys.time()) {
  library(httr)
  library(jsonlite)
  
  cli::cli_progress_step(
    msg = "Attempting to repost {.emph {post_uri}}",
    msg_done = "Reposted successfully",
    msg_failed = "Repost failed"
  )
  
  # Sanitize username
  sanitize_username <- function(name) {
    name <- gsub("^@", "", name)  # Remove leading @
    if (!grepl("\\.bsky\\.social$", name)) {
      name <- paste0(name, ".bsky.social")  # Append .bsky.social if not present
    }
    return(name)
  }
  
  username <- sanitize_username(username)
  
  # Authenticate
  auth_url <- "https://bsky.social/xrpc/com.atproto.server.createSession"
  auth_body <- list(identifier = username, password = app_password)
  auth_response <- POST(auth_url, body = auth_body, encode = "json")
  
  if (http_status(auth_response)$category != "Success") {
    stop("Authentication failed: ", content(auth_response, "text", encoding = "UTF-8"))
  }
  
  auth_data <- content(auth_response, "parsed")
  access_token <- auth_data$accessJwt
  did <- auth_data$did
  
  # Create a function to make authenticated requests
  make_auth_request <- function(url, method = "GET", body = NULL, query = list()) {
    headers <- add_headers(Authorization = paste("Bearer", access_token))
    if (method == "GET") {
      response <- GET(url, query = query, headers)
    } else if (method == "POST") {
      response <- POST(url, body = body, encode = "json", headers)
    }
    if (http_status(response)$category != "Success") {
      stop(paste("API request failed:", content(response, "text", encoding = "UTF-8")))
    }
    return(response)
  }
  
  # Fetch post information
  post_info_url <- "https://bsky.social/xrpc/app.bsky.feed.getPosts"
  post_info_response <- make_auth_request(post_info_url, query = list(uris = post_uri))
  post_info <- content(post_info_response, "parsed")
  
  if (length(post_info$posts) == 0) {
    stop("Could not fetch information for the provided post URI")
  }
  
  post_uri <- post_info$posts[[1]]$uri
  post_cid <- post_info$posts[[1]]$cid
  
  # Create the repost record
  record <- list(
    `$type` = "app.bsky.feed.repost",
    subject = list(
      uri = post_uri,
      cid = post_cid
    ),
    createdAt = format(as.POSIXct(created_at, tz = "UTC"), "%Y-%m-%dT%H:%M:%OS6Z")
  )
  
  # If text is provided, add it as a quote
  if (!is.null(text)) {
    record$text <- text
  }
  
  # Create the repost
  create_record_url <- "https://bsky.social/xrpc/com.atproto.repo.createRecord"
  create_record_body <- list(
    repo = did,
    collection = "app.bsky.feed.repost",
    record = record
  )
  create_record_response <- make_auth_request(create_record_url, method = "POST", body = create_record_body)
  
  invisible(content(create_record_response, "parsed"))
}