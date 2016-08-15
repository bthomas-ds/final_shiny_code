# filter_ngrams.R
# This script filters down the results by choosing bigrams/trigrams that occur more than 1 time

rm(list=ls())

setwd("/home/bthomas/Github/final_shiny_code")
trigrams <- readRDS("flt_trigrams.Rda")
trigrams2 <- as.data.frame(trigrams)
trigrams3 <- trigrams2 %>% group_by(W1, W2) %>% top_n(1, Freq)
saveRDS(trigrams3, "flt_trigrams.Rda")

setwd("/home/bthomas/Github/final_shiny_code")
bigrams <- readRDS("bigrams.Rda")
bigrams2 <- as.data.frame(bigrams)
bigrams3 <- bigrams2 %>% group_by(W1) %>% top_n(1, Freq)
setkey(bigrams3, W1)
object.size(bigrams3)
saveRDS(bigrams3, "flt_bigrams.Rda")


