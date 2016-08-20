# final_shiny_code

Presentation is at -> http://rpubs.com/bthomas-ds/196807

## mc_bigrams_trigrams.R
This code uses the quanteda, parallel, Matrix, tidyr, doParallel, and foreach modules. The code was executed on a laptop running a VMWare Linux instance with 21 gbs and a quad core. Using the Linux utility, htop, I discovered that 3 of my 4 cores were being used less than 3% of time. Many of our classmates notes that long processing time as did I. Knowwing that 3 of the 4 cores were under utilized I searched and found the doparallel library that allowed parallel processing. Stackoverflow.com recommendations were to use one less than the total core. I used 3 cores and then divided the work into 3 partitions by using mcLappy to do the cleaning. The problem for the term frequency was divided into 3 partitions and then aggreagated. The cleaning ran in 4 to 6 minutes. Bigrams completed in 6 to 8 minutes. Trigrams completed in under 15 minutes. 

# cleanDoc.R
The goal of this file is to apply all of the text cleanup to the data files by using the mclapply parallel function and then save the cleaned data to a file.

# filter_ngrams.R
This file keeps the top count for each bigram and trigram. This saves file space by not loading bigrams or trigrams that are not the most frequently occurring ngram.

# search_hit.R
The logic for search trigrams and then bigrams was experiemnted in this file. A sample Twitter of 6 random lines was tested against the logic. The 6 random lines cleaned and tokenized hit on an exact match 2 of the 6 lines during the last simulation. Hits were proposed for the other 4 but they were not direct hits.

[1] "niallhoranisperfect" "im"                  "sayin"               "wearing"             "stereo"              "hearts"              "shirt"              
stereo hearts hit:  shirt

[1] "dolphins"   "add"        "another"    "seam"       "stretching" "tight"      "end"       
stretching tight hit:  across

 [1] "every"      "charitable" "act"        "stepping"   "stone"      "towards"    "heaven"     "henry"      "ward"       "beecher"   
henry ward hit:  beecher

[1] "get"      "mad"      "look"     "somebody" "n"        "already"  "looking" 
n already hit:  hav

[1] "just"     "finished" "fifty"    "shades"   "freed"    "now"      "nothing"  "look"     "forward"  "life"     "lost"     "meaning" 
life lost hit:  day

 [1] "former"  "spur"    "ian"     "mahinmi" "getting" "playing" "time"    "mavs"    "heat"    "lead"    "rd"      "quarter"
lead rd hit:  us

# bigrams.R
File dedeicated to creating the bigrams using Quanteda.

# trigrams.R
Creation of the trigrams.