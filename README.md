
Last Updated on 2024-09-29

<img src="img/fluent-emoji-high-contrast--man.png" width="100" />

# Weekly post of Work in Progrees articles to Bluesky

I enjoy reading [Work in Progress](https://worksinprogress.co), but each
article is long (20 to 40 minutes reading) and I often forget about an
issue once it’s published. Each issue has 6 or 7 articles.

So to help me keep up, I created a Bluesky bot to post a link and
description of one of the 115 articles (at the time of writing) from the
Work in Progress archive each week with a screenshot.

Bluesky bot:
[@wkipbot.bsky.social](https://bsky.app/profile/wkipbot.bsky.social)

## Scraping the articles with R

I used [rvest](https://rvest.tidyverse.org/) in R and the inspector tool
in Firefox to get the CSS selectors to scrape all the articles.

This yielded a table with 115 articles from 17 issues (one issue a
special issue). The table `wkip-articles-2024-09-28.csv` has 10 columns
with one row for each article.

``` markdown
Rows: 115
Columns: 10
$ url                <chr> "https://worksinprogress.co", "https://…
$ issue_num          <chr> "issue-01", "issue-01", "issue-01", "is…
$ card_text          <chr> "SpotlightIssue 01Epidemic disease and …
$ card_slug          <chr> "issue/epidemic-disease-and-the-state/"…
$ title              <chr> "Epidemic disease and the state", "Buil…
$ id                 <dbl> 16, 111, 112, 113, 114, 115, 15, 104, 1…
$ post_week          <date> 2025-07-01, 2024-10-01, 2025-11-11, 20…
$ post_article_url   <chr> "https://worksinprogress.co/issue/epide…
$ post_issue_url     <chr> "https://worksinprogress.co/issue-01/",…
$ screen_shot_prefix <chr> "issue-01-1", "issue-01-2", "issue-01-3…
```

The table is used for the posting bot for the text, alt-text and to
create the YAML for taking screenshots. I wanted to post one article a
week at random from the archive, so I created article `id` and date
`post_week` variable that was randomly assigned to each `id`.

## Getting the screenshots with shot-scraper

I used Simon Willison’s
[shot-scraper](https://shot-scraper.datasette.io/en/stable/) to create
images for each article to use with the post using the
`screen_shot_prefix` in the articles table.

To do this I needed a `YAML` file for each issue to input to
`shot-scraper`, so with help from Claude I wrote some more R to create
the 17 `YAML` files.

Out of laziness, I ran a short `bash` script of the form:

`for i in {1..16}; do shot-scraper multi issue-$i.yml --retina; done`

on my computer to generate the the 115 screenshots.

## Bluesky bot as per previous bots

See my [Our World in Data bot](https://github.com/ab604/owid-dd-bot) and
[Literature bot](https://github.com/ab604/prot-paper-bot) for details of
how the bot is set-up using R
[atrrr](https://jbgruber.github.io/atrrr/index.html) and Github Actions
to post to Bluesky.

I’ve set `cron` to post the same article on Sunday, Tuesday and Friday
each week at 0730 UTC. This might change if I can figure out how to
re-post or it’s too annoying.
