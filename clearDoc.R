# 8/6/2016
# This should be run from the commandline. There are numerous warning in the mclapply documentation to not run it from a gui.
# Script: cleanDoc.R
# Goal: Clean data and create a term frequency table
# 
library(quanteda)
library(parallel)
library(Matrix)
# library(tidyr)
# library(doParallel)
# library(foreach)

# This code uses Quanteda to clean the source files 

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
print(paste("Number of cores: ", cl, ""))
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
  data.sample <- mclapply(data.sample, cleanDoc, mc.cores = no_cores, mc.cleanup = TRUE)
})

saveRDS(data.sample, "clean.data.sample.Rda")
#  user  system elapsed 
# 704.144  20.060 724.505 
stopCluster(cl)
