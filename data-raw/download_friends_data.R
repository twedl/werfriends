
library(tidyverse)
library(rvest)

get_ep_data <- function(ep_url, url) {
  # given a show url (for the session), and an episode url (relative to the show url)
  # follow the link to the episode and download the episode data
  print(paste0("S:", stringr::str_extract(url, "(\\d*)$"), " E:", stringr::str_extract(ep_url, "(\\d*)$")))
  print(ep_url)

  session <- html_session(paste0(url)) %>%  jump_to(ep_url)
  page <- session %>% read_html()
  title <- page %>% html_nodes("div h1[itemprop=\"name\"]") %>% html_text() %>% trimws()
  rating <- page %>% html_nodes('span[itemprop="ratingValue"]') %>% html_text() %>% as.numeric()
  n_ratings <- page %>% html_nodes('span[itemprop="ratingCount"]') %>% html_text() %>% gsub(pattern = ",", replacement = "") %>% as.numeric()

  # get writer / director info.
  cast_table <- session %>% follow_link(i = "See full cast & crew") %>%
    html_nodes(".simpleCreditsTable") %>%
    html_table()

  director <- cast_table %>% .[[1]] %>% .[,1] # the director is first in the list of tables.

  # nope! sometimes it says "teleplay by" and "story by". use those too.
  writers <- cast_table %>% .[[2]] %>% # I think the writers are in the second table in the list of tables?
    filter(grepl("writer|written|teleplay|story", X3)) %>%  .[,1]

  tibble(
    season = stringr::str_extract(url, "(\\d*)$") %>% as.numeric(), #substring(url, nchar(url)),
    episode = stringr::str_extract(ep_url, "(\\d*)$") %>% as.numeric(), #substring(ep_url, nchar(ep_url)),
    title = title,
    rating = rating,
    n_ratings = n_ratings,
    director = lst(director),
    writers = lst(writers)
  )
}

get_season_data <- function(url) {
  # given the show url, download episode data for every episode in every season

  html <- read_html(url)

  # get links to all episodes.
  ep_list <- html %>% html_nodes(css = 'strong a[itemprop="name"]') %>% html_attr('href')

  # for each episode in the list, safely get the data
  safe_get_ep_data <- possibly(get_ep_data, otherwise = NULL)

  # return a dataframe of all episode data
  ep_list %>% map(safe_get_ep_data, url = url) %>% bind_rows()
}

url <- "http://www.imdb.com/title/tt0108778/episodes?season="

urls <- map_chr(1:10, function(n) {paste0(url, n)})
friends_episodes <- urls %>% map(get_season_data) %>% bind_rows()
friends_episodes[grepl("They're Up All Night", friends_episodes$title), ]$writers <- lst("Zachary Rosenblatt")

devtools::use_data(friends_episodes, overwrite = TRUE)



