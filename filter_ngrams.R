# filter_ngrams.R
# This script filters down the results by choosing bigrams/trigrams with the highest count

rm(list=ls())
library(dplyr)
library(data.table)

setwd("/home/bthomas/Github/final_shiny_code")
trigrams <- readRDS("flt_trigrams.Rda")
trigrams <- as.data.frame(trigrams)
trigrams <- trigrams %>% group_by(W1, W2) %>% top_n(1, Freq)
saveRDS(trigrams, "flt_trigrams.Rda")

setwd("/home/bthomas/Github/final_shiny_code")
bigrams <- readRDS("bigrams.Rda")
bigrams <- as.data.frame(bigrams)
bigrams <- bigrams %>% group_by(W1) %>% top_n(1, Freq)
saveRDS(bigrams, "flt_bigrams.Rda")


