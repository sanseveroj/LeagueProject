source('Libraries.R')

League <- readr::read_csv('AllGames/0-9999.csv')

League %>% names()

League %>%
  arrange(gameId) %>%
  head(10) %>% View()

League %>%
  group_by(gameId) 

raw_match <- readr::read_csv('AllGames/raw_match.csv')

raw_match %>% str()
  select(info.gameVersion) %>% unique()
  mutate_if(is.character, as.factor) %>%
  summary()
