#' ---
#' title: "Forum text analyses"
#' output:
#'   pdf_document:
#'     toc: true
#'     toc_depth: 2
#'     fig_width: 7
#'     fig_height: 7
#' header-includes:
#'   \usepackage{float}
#' ---

#+ label1, include = FALSE
knitr::opts_chunk$set(
    include = FALSE, 
    warning = FALSE, 
    message = FALSE,
)
here::i_am("code/init.r")
library(here)
options(max.print = 10000)
library(tidyverse)
library("writexl")
library("stopwords")
library(data.table)

# Text analyses packages
# https://quanteda.io/articles/quickstart.html
library("spacyr")
# spacy_install()
# conda activate spacy_condaenv
Sys.setenv(RETICULATE_PYTHON = "/Users/knguyen/opt/miniconda3/envs/spacy_condaenv/bin/python")
spacy_initialize()
# spacy_download_langmodel("de_core_news_sm")
# https://spacy.io/models/de#de_dep_news_trf
library("quanteda")
library("quanteda.textplots")
library(magrittr)
devtools::load_all('~/Code/R/ktools/')

#' # Read and basic processing
forum <- readRDS(here("data/forum.rds"))

# forum <- list.files(here("data/new")) |>
#     map_dfr(\(x) read_csv(here('data/new', x))) |>
#     mutate(
#         date = gsub(',', '', date),
#         date = as.Date(date, '%d.%m.%Y')
#     )
# saveRDS(forum, here('data/forum.rds'))

#+ include=TRUE
forum

# writexl::write_xlsx(forum, here('data/forum.xlsx'))

#' ## Activity over time
#' 
#+ cache = TRUE
sc <- read_csv(
    "https://raw.githubusercontent.com/OxCGRT/covid-policy-tracker/master/data/timeseries/c1_school_closing.csv"
) %>%
    filter(country_code == "DEU") %>%
        select(-X1, -country_code) |>
        pivot_longer(-country_name, values_to = 'n_school_closure') %>%
        mutate(date = as.Date(name, "%d%b%Y")) %>%
        select(-name)
sc

forum %<>%
    rename(id = X1) %>% 
    mutate(id = gsub('post_message_', '', mid)) %>% 
    arrange(id)

#+ count_per_day, fig.cap = 'Count number of responses per day', include=TRUE
forum |>
    group_by(date) %>%
    count() %>%
    pivot_longer(-date) %>%
    ggplot(aes(date, value)) +
    facet_wrap(~name, 2, scales = 'free_y') +
    geom_col() +
    labs(title = "Number of messages per day")
savePNG(here('fig', 'numMessPerDay'), 7, 4)

# Document features
tk <- tokens(
    forum$text, 
    remove_punct = TRUE, 
    remove_numbers = TRUE, 
    remove_symbols = TRUE, 
    remove_url = T
) %>%
    tokens_remove(stopwords("de", source = "stopwords-iso"))

tk <- lapply(tk, function(x) tolower(x)) %>% as.tokens()

# Docuement features matrix
dfmat <- dfm(tk)

dim(dfmat)
nrow(forum)

# Token long form - this is slow
tk_long <- purrr::map_dfr(
    names(tk), 
    function(x) bind_cols(text = x, as_tibble(tk[[x]])))

tk_long %>%
    rename(word = value) %>%  
    allot(tk_long)
saveRDS(tk_long, here('data', 'tk_long.rds'))


#' ## Word clouds
#' 
#+ word_cloud_500p, fig.cap = 'Word clouds (500+)', include=TRUE
textplot_wordcloud(dfmat,
    min_count = 500, random_order = FALSE, rotation = 0.25,
    color = RColorBrewer::brewer.pal(8, "Dark2")
)

#' \newpage
#+ word_cloud_100_500, fig.cap = 'Word clouds (100-500)', include=TRUE
dfmat %>%
    dfm_trim(max_termfreq = 499) |>
    textplot_wordcloud(
        min_count = 100, max_words = 100, random_order = FALSE, rotation = 0.25,
        min_size = .5, max_size = 2,
        color = RColorBrewer::brewer.pal(8, "Dark2")
    )

#' ## Word counts
#+ word_count_table, results = 'asis', include=TRUE
topfeatures(dfmat, 1000) %>%
    tibble(n = ., word = names(.)) %>%
    arrange(desc(n)) %>%
    knitr::kable(caption='\\label{tab:word_count}Word count')

