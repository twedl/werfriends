#' Friends episode via IMDB.
#'
#' A dataset containing the season, episode, title, rating,
#' number of ratings, directors and writers of all Friends
#' episodes, S1E1 to S10E18.
#'
#' @format A data frame with 236 rows and 7 variables:
#' \describe{
#'   \item{season}{season number}
#'   \item{episode}{episode number}
#'   \item{title}{episode title}
#'   \item{rating}{user rating of episode}
#'   \item{n_ratings}{number of ratings for episode}
#'   \item{director}{list-col of episode directors}
#'   \item{writers}{list-col of episode writers}
#' }
#' @source \url{http://www.imdb.com/title/tt0108778/?ref_=ttep_ep_tt}
"friends_episodes"
