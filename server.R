#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(data.table)
require(quanteda)
require(dplyr)

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
  x
}

trigrams2 <- readAndIndex()
bigrams <- readAndIndex2()

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    output$textoutput<- renderText({
      hit <- "france"
      if ((sapply(gregexpr("\\W+", input$text), length) + 1) > 2) {  
      newSample <- cleanDoc(input$text)
      t <- tokenize(newSample )
      newSample.matrix <- matrix(unlist(t), byrow = TRUE)
      
      if (nrow(newSample.matrix) > 2) {
        key1 <- newSample.matrix[nrow(newSample.matrix)-2]
        key2 <- newSample.matrix[nrow(newSample.matrix)-1]
        hit <- trigrams2[.(key1, key2), mult = "first"]$W3
      }
      
      if (identical("france", hit)) { 
        
        key1 <- newSample.matrix[nrow(newSample.matrix)]
        hit <- bigrams[.(key1)]$W2[1]
      }
      if (is.na(hit)) { hit <- "Fahrvergnügen"}
      hit} else
      {"Type more than 2 words please"}
    
  })
  
     
  
  
  
})
