# filter_ngrams.R
# This script filters down the results by choosing bigrams/trigrams that occur more than 1 time.

setwd("~/Github/final_shiny_code")
trigrams <- readRDS("trigrams.Rda")
trigrams2 <- as.data.frame(trigrams)
object.size(trigrams2)
sum(trigrams$Freq == 1) / dim(trigrams)[1]
trigrams3 <- trigrams[trigrams$Freq > 1 ,]
object.size(trigrams3)
saveRDS(trigrams3, "flt_trigrams.Rda")

bigrams <- readRDS("bigrams.Rda")
bigrams2 <- as.data.frame(bigrams)
object.size(bigrams2)
sum(bigrams$Freq == 1) / dim(bigrams)[1]
bigrams3 <- bigrams2[bigrams2$Freq > 1, ]
object.size(bigrams3)
saveRDS(bigrams3, "flt_bigrams.Rda")
