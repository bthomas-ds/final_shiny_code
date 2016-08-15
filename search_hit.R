library(data.table)
require(quanteda)
require(dplyr)
rm(list=ls())
setwd("~/Github/final_shiny_code")

readAndIndex <- function(){
trigrams <- readRDS("flt_trigrams.Rda")
trigrams2 <- as.data.table(trigrams)
trigrams2 <- trigrams2[order(W1, W2, -Freq)]
setkey(trigrams2, W1, W2 )

}

readAndIndex2 <- function(){
  bigrams <- readRDS("flt_bigrams.Rda")
  bigrams2 <- as.data.table(bigrams)
  bigrams2 <- bigrams2[order(W1, W2, -Freq)]
  setkey(bigrams2, W1)
  
}


getTwitterSample <-function(){
  sample(readLines("/home/bthomas/Documents/Milestone_Report/final/en_US/en_US.twitter.txt", encoding = "UTF-8", skipNul = TRUE), 6)
  
}

cleanDoc <- function(x) {
  x <- iconv(x, "latin1", "ASCII", sub="")
  x <- tolower(x)  # force to lowercase
  #remove offensive, controveral, profanity words
  getProfanityFile <- readLines("/home/bthomas/Documents/Milestone_Report/profanity1.txt")
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
  x
}

newTrigramWord <-function(x){
  
  
}


mySample <- getTwitterSample()
newSample <- cleanDoc(as.matrix(mySample))
newSample.tokenized <- tokenize(newSample )

trigrams2 <- readAndIndex()
bigrams <- readAndIndex2()

for (x in 1:6) {
  x <- 5
  t <- newSample.tokenized[[x]]
  if (length(t) > 2) {
    key1 <- t[length(t)-2]
    key2 <- t[length(t)-1]
    hit <- trigrams2[.(key1, key2), mult = "first"]$W3
    if (is.na(hit)) { 
      
      hit <- bigrams[.(key1)]$W2[1]
    }
    if (is.na(hit)) {
      hit <- "christmas"
      }
    print(t)
    print(cat(key1, key2, "hit: ", gsub("^\\s+|\\s+$", "", hit), sep = " "))
    print(" ")
  }
}
  