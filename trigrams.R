# trigrams
library(quanteda)
library(tidyr)
library(doParallel)

# clean up environment and set to working directory
rm(list=ls())
gc(reset = TRUE)
setwd("~/Documents/Milestone_Report")

# Warning the multicore is configured for Linux. Consult the parallel man page for adaptation to Windows.
# Calculate the number of cores
no_cores <- max(1, detectCores() - 1)

# Initiate cluster
cl <- makeCluster(no_cores, type = "FORK")
print(paste("Number of cores: ", cl, ""))

data.sample <- readRDS("clean.data.sample.Rda")

registerDoParallel(max(1, detectCores() - 1))
setwd("~/Github/final_shiny_code")
aThird <- round(length(data.sample) * 0.33)

print("Starting the foreach loop")
data.sample <- as.character(data.sample)
# data.sample <- data.sample[1:500]
aThird <- round(length(data.sample) * 0.33)

system.time({
  
  trigrams <- foreach(i=1:3, .export = c("data.sample"), .packages = c("quanteda", "tidyr"), .combine = rbind, .multicombine = TRUE) %dopar% {
    if (i==1) {
      slice1 <- data.sample[1:aThird]
      slice1 <- corpus(slice1)
      dfm1 <- dfm(slice1,
                  toLower = TRUE,
                  removeNumbers = TRUE,
                  removePunct = TRUE,
                  removeTwitter = TRUE,
                  # stem = TRUE, # stemming changes words to variants such as New York Citi
                  removeSeparators = TRUE,
                  language = "english",
                  ignoredFeature = stopwords("english"),
                  ngrams = 3)
      slice1.df <- data.frame(Trigrams = features(dfm1), Freq = quanteda::colSums(dfm1))
      # slice1.df <- separate(slice1.df, col = Bigrams, into = c("W1", "W2"), sep = "_") 
      return(slice1.df)
    }
    
    if (i==2) {
      slice2 <- data.sample[aThird + 1 : aThird * 2]
      slice2 <- corpus(slice2)
      dfm2 <- dfm(slice2,
                  toLower = TRUE,
                  removeNumbers = TRUE,
                  removePunct = TRUE,
                  removeTwitter = TRUE,
                  # stem = TRUE, # stemming changes words to variants such as New York Citi
                  removeSeparators = TRUE,
                  language = "english",
                  ignoredFeature = stopwords("english"),
                  ngrams = 3)
      slice2.df <- data.frame(Trigrams = features(dfm2), Freq = quanteda::colSums(dfm2))
      # slice2.df <- separate(slice2.df, col = Bigrams, into = c("W1", "W2"), sep = "_")
      return(slice2.df)
    }
    if (i==3) {
      ll <- (aThird * 2) + 1
      ul <- length(data.sample)
      slice3 <- data.sample[ll : ul]
      slice3 <- corpus(slice3)
      dfm3 <- dfm(slice3,
                  toLower = TRUE,
                  removeNumbers = TRUE,
                  removePunct = TRUE,
                  removeTwitter = TRUE,
                  # stem = TRUE, # stemming changes words to variants such as New York Citi
                  removeSeparators = TRUE,
                  language = "english",
                  ignoredFeature = stopwords("english"),
                  ngrams = 3)
      slice3.df <- data.frame(Trigrams = features(dfm3), Freq = quanteda::colSums(dfm3))
      # slice3.df <- separate(slice3.df, col = Bigrams, into = c("W1", "W2"), sep = "_") 
      return(slice3.df)
    }
    rbind(slice3.df, slice2.df, slice1.df)  
  }
  
  
})
stopImplicitCluster()
# processing time from parallel is 3.01 compared to 8.01
# bigrams$Freq <- aggregate(x = bigrams$Freq, by = list(bigrams$W1, bigrams$W2), FUN = sum)
# Summarize the Bigrams field as it is likely that a two word sequence in more than just one slice of the file
require(dplyr)
trigrams2 <- trigrams %>% group_by(Trigrams) %>% summarise(Freq = sum(Freq))
rm(trigrams)
trigrams <- trigrams2
rm(trigrams2)
# colnames(bigrams) <- c("Bigrams", "Freq")
trigrams <- separate(trigrams, col = Trigrams, into = c("W1", "W2", "W3"), sep = "_") 
saveRDS(bigrams, file = "trigrams.Rda")
