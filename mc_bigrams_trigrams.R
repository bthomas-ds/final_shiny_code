# 8/6/2016
# This should be run from the commandline. There are numerous warning in the mclapply documentation to not run it from a gui.
# Script: mc_bigrams_trigrams.R
# Goal: Clean data and create a term frequency table
# 
library(quanteda)
library(parallel)
library(Matrix)
library(tidyr)
library(doParallel)
library(foreach)
# This code uses Quanteda to create a document frequency matrix and then calculate the term frequency
# Quanteda was selected after trying TM. 
# Data was retrieved from
# https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip

# clean up environment and set to working directory
rm(list=ls())
gc(reset = TRUE)
setwd("~/Documents/Milestone_Report")

# Warning the multicore is configured for Linux. Consult the parallel man page for adaptation to Windows.
# Calculate the number of cores
no_cores <- max(1, detectCores() - 1)

# Initiate cluster
cl <- makeCluster(no_cores, type = "FORK")

#download
if (!file.exists("Coursera-SwiftKey.zip")) {
  download.file("https://d396qusza40orc.cloudfront.net/dsscapstone/dataset/Coursera-SwiftKey.zip", "Coursera-SwiftKey.zip")
  unzip("Coursera-SwiftKey.zip")
}

# The data set link is found in the syllabus and is composed of subsets that are in English, German, Finish, and Russian. I will be using
# the English set for the milestone report.

# load blogs, news, and Twitter into objects
print("Reading the files")
blogs <- readLines("final/en_US/en_US.blogs.txt", encoding = "UTF-8", skipNul = TRUE)
news <- readLines("final/en_US/en_US.news.txt", encoding = "UTF-8", skipNul = TRUE)
twitter <- readLines("final/en_US/en_US.twitter.txt", encoding = "UTF-8", skipNul = TRUE)
# Sample the data
set.seed(54321)
# 30% sample

ssize <- 0.3
data.sample <- c(sample(blogs, length(blogs) * ssize),
                 sample(news, length(news) * ssize),
                 sample(twitter, length(twitter) * ssize))

## take out after debugging
data.sample <- data.sample
data.sample <- as.matrix(data.sample)
# best of clean data function to remove non words from corpus
cleanDoc <- function(x) {
  x <- iconv(x, "latin1", "ASCII", sub="")
  x <- tolower(x)  # force to lowercase
  #remove offensive, controveral, profanity words
  getProfanityFile <- readLines("profanity1.txt")
  pattern <- paste0("\\b(?:", paste(getProfanityFile, collapse = "|"), ")\\b ?")
  x <- gsub(pattern, "", x, perl = TRUE)
  words <- stopwords("english")
  pattern <- paste0("\\b(?:", paste(words, collapse = "|"), ")\\b ?")
  x <- gsub(pattern, "", x, perl = TRUE)
  #
  x <- gsub("'", "", x)  # remove apostrophes
  x <- gsub("[[:punct:]]", " ", x)  # replace punctuation with space *
  x <- gsub("[[:cntrl:]]", "", x)  # remove control characters
  x <- gsub("(f|ht)tp(s?)://(.*)[.][a-z]+", "", x) # replace urls with space *
  x <- gsub("RT |via ", "", x)  # remove twitter tags
  x <- gsub("@[^\\s]+", "", x)  # remove twitter accounts
  x <- gsub('[[:digit:]]+', "", x) #remove numbers (we lose things like 'number 1', 'no 1', though)
  x <- gsub("^[[:space:]]+", "", x) # remove whitespace at beginning
  x <- gsub("[[:space:]]+$", "", x) # remove whitespace at end
  x <- gsub("â", "a", x)  # replace 'â'
  x <- gsub("[[:space:]]+", " ", x) # replace multiple consecutive spaces with a single space
}
print("Starting mclapply")
system.time({
data.sample <- mclapply(data.sample, cleanDoc, mc.cores = no_cores, mc.preschedule = TRUE)
})


saveRDS(data.sample, "clean.data.sample.Rda")
# data.sample <- readRDS("clean.data.sample.Rda")
# test run was 717.384 / 60 = 11.9564
data.sample <- as.character(data.sample)
# saveRDS(data.sample, file = "data.sample.Rda", compress = TRUE)

# readRDS("data.sample.Rda")


# each loop should stake the begin and end, create the corpus and then do dfm
# data.sample.corpus <- corpus(data.sample)

rm(list=c(setdiff(ls(), "data.sample")))
gc(reset = TRUE)
registerDoParallel(max(1, detectCores() - 1))
setwd("~/Github/final_shiny_code")
aThird <- round(length(data.sample) * 0.33)


print("Starting the foreach loop")

system.time({
bigrams <- foreach(i=1:3, .packages = c("tidyr", "quanteda"), .combine = rbind, .multicombine = TRUE,   .verbose = TRUE) %dopar% {
  if (i == 1) {
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
                ngrams = 2)
    slice1.df <- data.frame(Bigrams = features(dfm1), Freq = quanteda::colSums(dfm1))
    # slice1.df <- separate(slice1.df, col = Bigrams, into = c("W1", "W2"), sep = "_") 
  }
  
  if (i == 2) {
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
                ngrams = 2)
    slice2.df <- data.frame(Bigrams = features(dfm2), Freq = quanteda::colSums(dfm2))
    # slice2.df <- separate(slice2.df, col = Bigrams, into = c("W1", "W2"), sep = "_") 
  }
  if (i == 3) {
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
                ngrams = 2)
    slice3.df <- data.frame(Bigrams = features(dfm3), Freq = quanteda::colSums(dfm3))
    # slice3.df <- separate(slice3.df, col = Bigrams, into = c("W1", "W2"), sep = "_") 
    
    }
  rbind(slice3.df, slice2.df, slice1.df)  
}
})
# processing time from parallel is 3.01 compared to 8.01
bigrams$Freq <- aggregate(x = bigrams$Freq, by = list(bigrams$Bigrams), FUN = sum)
bigrams$Freq <- tapply(X = bigrams, INDEX = bigrams$Bigrams, FUN = sum)
bigrams <- separate(bigrams, col = Bigrams, into = c("W1", "W2"), sep = "_") 

saveRDS(bigrams, file = "bigrams.Rda")
# 
# system.time({
# data.sample.corpus <- corpus(data.sample)
# testDFM <- dfm(data.sample.corpus,
#                      toLower = TRUE,
#                      removeNumbers = TRUE,
#                      removePunct = TRUE,
#                      removeTwitter = TRUE,
#                      # stem = TRUE, # stemming changes words to variants such as New York Citi
#                      removeSeparators = TRUE,
#                      language = "english",
#                      ignoredFeature = stopwords("english"),
#                      ngrams = 2)
# testDFM.df <- data.frame(Bigrams = features(testDFM), Freq = quanteda::colSums(testDFM))
# testDFM.df <- separate(testDFM.df, col = Bigrams, into = c("W1", "W2"), sep = "_") 
# })
# 
# system.time({
# bigram.30.dfm <- dfm(data.sample.corpus,
#                      toLower = TRUE,
#                      removeNumbers = TRUE,
#                      removePunct = TRUE,
#                      removeTwitter = TRUE,
#                      # stem = TRUE, # stemming changes words to variants such as New York Citi
#                      removeSeparators = TRUE,
#                      language = "english",
#                      ignoredFeature = stopwords("english"),
#                      ngrams = 2 # change to 2 or 3 depending on your need
# )})
# 
# 
# bigram.df <- data.frame(Bigrams = features(bigram.30.dfm), Freq = quanteda::colSums(bigram.30.dfm))
# bigram.df <- separate(bigram.df, col = Bigrams, into = c("W1", "W2"), sep = "_") 
# save(bigram.df, file = "bigrams.Rda", compress = TRUE)
# 
# # trigrams
# rm(list=c(setdiff(ls(), "data.sample.corpus")))
# gc(reset = TRUE)
# 
# system.time({
# trigram.30.dfm <- dfm(data.sample.corpus,
#                       toLower = TRUE,
#                       removeNumbers = TRUE,
#                       removePunct = TRUE,
#                       removeTwitter = TRUE,
#                       # stem = TRUE, # stemming changes words to variants such as New York Citi
#                       removeSeparators = TRUE,
#                       language = "english",
#                       ignoredFeature = stopwords("english"),
#                       ngrams = 3 # change to 2 or 3 depending on your need
# )})
# 
# trigram.df <- data.frame(Trigrams = features(trigram.30.dfm), Freq = quanteda::colSums(trigram.30.dfm))
# trigram.df <- separate(trigram.df, col = Trigrams, into = c("W1", "W2", "W3"), sep = "_") # change spilt for 2 or 3 words depending on your grams
# 
# save(trigram.df, file = "trigrams.Rda", compress = TRUE)
# stopCluster(cl)
# rm(list=ls())
# gc(reset = TRUE)
