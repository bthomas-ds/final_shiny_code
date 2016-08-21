#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
shinyUI(navbarPage("Data Science Capstone",
                   tabPanel("Word Prediction",
                            sidebarLayout(
                              sidebarPanel(
                                
                                textInput("text", label=h3("Text input"),value = ""),
                                
                                submitButton("Update"),
                                helpText("Help Test: type your text into text input. Trigrams and bigrams will be used to
                                         find a word suggestion/
                                         An example: the wrecking ball")),
                              
                              mainPanel(
                                
                                h4("Tri-grams & Bi-grams Prediction Output"),
                                textOutput("textoutput")
                                
                              )
                                )
                              ),
                   
                   tabPanel("Background of N-Grams", HTML('
                                                                           <h3>What is n-gram? </h3>
                                                                           <p>The Markov model is the basis of the n-gram model that uses a probablistic language model for
                                                                           word prediction. Natural Language Processing and text mining leverage this model for tasks, such as,
                                                                           summarization, spell check, and word breaking. In computational linguistics and probability fields,
                                                                           an n-gram is a contiguous sequence of n items in the sequence of text or speech. The items can be 
                                                                           phonemes, syllables, or letters. I used the quanteda libary to generate the n-grams in this app. 
                                                                           words or base pairs according to the application. A training and testing set was used to confirm the
                                                                           hit ratio. Bigrams hit at 44% and trigrams hit at 59%.

                                                                      <ul>
                                                                          <li>Blogs, Twitter, and news was randomly sampled at 30%. Using 30% for bigrams and trigrams posed no problems on a VM with 21 gbs.</li>
                                                                          <li>Quanteda was used to make a corpus, clean the corpus, tokenized corpus, then create termdocumentmatrix for bigrams and trigrams</li>
                                                                          <li>Convert dfm to a data frame for each gram type with a frequency count</li>
                                                                          <li>Create a function to predict and return terms that mostly will be the next word</li>

                                                                      </ul>
                                                                      <p> I am including a link to the Github repository below. It took a while to figure out how to get the multicore and parallel functions to work. 
                                                                          But now that I have it configured, I can repeat parallel processing over and over</p>
                                                                      <ul>
                                                                          <li><a href="https://github.com/bthomas-ds/final_shiny_code"> Github repository</a></li>
                                                                          <li> <a href="http://rpubs.com/bthomas-ds/196807">R Pub</a></li>

                                                                      </ul>
                                                                           <h3>Reference links </h3>
                                                                           <ol>
                                                                           <li><a href="https://english.boises                                                                          tate.edu/johnfry/files/2013/04/bigram-2x2.pdf</a></li>
                                                                           <li><a href="https://english.boisestate.edu/johnfry/files/2013/04/bigram-2x2.pdf>Text Analysis 101</a></li>                             
                                                                           </ol>
                                                                           ')),
                   tabPanel("Instructions", HTML('
                                                                      <h3>Project Task Sequence</h3>
                                                                      
                                                                      <h3>How to predict with this shiny app?</h3>
                                                                      <p>Type a sentence into the text box and press the Update button.</p>
                                                                      <p>I would like to improve the search accuaracy but after nearly a year I am ready to declare victory and move on.</p>
                                                                      <p>Inputting "McDonalds hamburger are the best" returns "now"</p>
                                                                      <p>Inputting "the music sounded much too" returns "video"</p>
                                                                      <p>Inputting "it was a long road trip" returns "back"</p>
                                                                      <p>Inputting "she was a really good cook" returns "idea"</p>
                                                                      <p>When there is no hits, the code offeres farfenugen as a word.</p>


                                                                                                         
                                                                      
                                                                      
                                                                      
                                                                      '))))