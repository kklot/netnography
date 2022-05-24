here::i_am('code/init.r')
library(here)
library(tidyverse)
library("writexl")
library("stopwords")

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

forum <- readxl::read_xlsx(here("data/forum_extract_with date and time.04.2022.xlsx"))

#' processing umlaut
forum <- forum %>%
    mutate(
        post = gsub("Ã¤", "ä", post),
        post = gsub("Ã¶", "ö", post),
        post = gsub("Ã¼", "ü", post),
        post = gsub("ÃŸ", "ß", post),
        post = gsub('Ãœ', 'Ü', post),
        post = gsub('\"', "", post),
        post = gsub('[zZ]itat von', "", post)
    )
forum

writexl::write_xlsx(forum, here('data/forum.xlsx'))

# corpus
cp <- corpus(forum$post)
summary(cp)

cp_st <- tokens(cp, "sentence")

# keyword in context
cptk <- tokens(cp, remove_punct = TRUE)

#' ## Vaccine related discussion
kwic(cptk, pattern = "vaccine", valuetype = "regex") %>%
    print(n = Inf)

#' ## Home-schooling related discussion
kwic(cptk, pattern = phrase("home school"), valuetype = "regex") %>%
    print(n = Inf)

