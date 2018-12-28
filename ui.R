#################################################
#               Basic Text Analysis             #
#################################################

library(shiny)
library(text2vec)
library(tm)
library(tokenizers)
library(wordcloud)
library(slam)
library(stringi)
library(magrittr)
library(tidytext)
library(dplyr)
library(tidyr)


shinyUI(fluidPage(
  
 titlePanel("Apple Iphone Reviews text Analysis"),
  
  # Input in sidepanel:
  sidebarPanel(
    
    fileInput("file", "Choose CSV file", accept=c("text/csv",
                                                  "text/comma-separated-values,text/plain",
                                                  ".csv")),
    checkboxGroupInput("siteGroup", "E-commerce Site", 
                       c("BestBuy" = "BestBuy",  
                         "Amazon" = "Amazon"), selected = c("Amazon"),inline=TRUE),
    
    checkboxGroupInput("prodGroup", "Product", 
                       c("Iphone 5S" = "Iphone 5S",
                         "Iphone 6S" = "Iphone 6S",
                         "Iphone 6Plus" = "Iphone 6Plus", 
                         "Iphone 6" = "Iphone 6",
                         "Iphone 7" = "Iphone 7",
                         "Iphone 8" = "Iphone 8",
                         "Iphone SE" = "Iphone SE",
                         "Iphone X" = "Iphone X",
                         "Iphone XR" = "Iphone XR"
                         
                         ), selected = c("Iphone 6","Iphone 7"),inline=TRUE),
    
    checkboxGroupInput("checkGroup", "rating", 
                       c("5" = "5", "4" = "4", 
                         "3" = "3","2" = "2", 
                         "1" = "1"), selected = c("5","4"),inline=TRUE),
    
    checkboxGroupInput("yearGroup", "Year", 
                       c("2014" = "2014", "2015" = "2015", 
                         "2016" = "2016","2017" = "2017", 
                         "2018" = "2018"), selected = c("2016","2017"),inline=TRUE),
    
    textInput("stopw", ("Enter stop words separated by comma(,)"), value = "will,can"),
    
    selectInput("ws", "Weighing Scheme", 
                c("weightTf","weightTfIdf"), selected = "weightTf"), # weightTf, weightTfIdf, weightBin, and weightSMART.
    
   textInput("concord.word",('Enter word for which you want to find concordance'),value = 'good'),
    sliderInput("window",'Concordance Window',min = 2,max = 100,5),
    
    submitButton(text = "Apply Changes", icon("refresh"))
    
  ),
  
  # Main Panel:
  mainPanel( 
        tabsetPanel(type = "tabs",
                #
                tabPanel("Overview",h4(p("How to use this App")),
                         
                         p("To use this app you need iphone reviews corpus in csv format. To do basic Text Analysis of amazon reviews, click on Browse in left-sidebar panel and upload the csv file. 
                            Once the file is uploaded it will do the computations in back-end with default inputs for Product(iphone model),Rating(1-5),Year(2014-2018) and other sliders.
                             and accordingly results will be displayed in various tabs.", align = "justify"),
                         p("If you wish to change the input, modify the input in left side-bar panel and click on Apply changes. Accordingly results in other tab will be refreshed
                           ", align = "Justify"),
                         p("Please refer to the link below for sample input file."),
                         a(href="https://github.com/sumaar1981/FirstRep/blob/master/iphone_reviews.csv"
                           ,"Sample data input file"),  
                         br(),
                         h5("Note"),
                         p("You might observe no change in the outputs after clicking 'Apply Changes'. Wait for few seconds. As soon as all the computations
                           are over in back-end results will be refreshed",
                           align = "justify"),
                          #, height = 280, width = 400
                         verbatimTextOutput("start"))
                ,
               
                tabPanel("TDM & Word Cloud",
                         h4("Word Cloud"),
                         plotOutput("wordcloud",height = 700, width = 700),
                         h4("Weights Distribution of Wordcloud"),
                         verbatimTextOutput("dtmsummary1")),
                tabPanel("Term Co-occurrence",
                         plotOutput("cog.dtm",height = 700, width = 700)
                         ),
                tabPanel("Bigram",
                         h4('Collocations Bigrams'),
                          p('If a corpus has n word tokens, then it can have at most (n-1) bigrams. However, most of
                                    these bigram are uninteresting. The interesting ones - termed collocations bigrams - comprise
                                    those bigrams whose occurrence in the corpus is way more likely than would be true if the 
                                    constituent words in the bigram randomly came together. Below is the list of all collocations 
                                    bigrams (top 100, if collocations bigrams are above 100) from the corpus you uploaded on 
                                    this App',align = "Justify"),
                         verbatimTextOutput("bi.grams")
                         ),
                tabPanel("Concordance",
                         h4('Concordance'),
                         p('Concordance allows you to see the local context around a word of interest. It does so by building a moving window of words before and after the focal word\'s every instance in the corpus. Below is the list of all instances of concordance in the corpus for your word of interest entered in the left side bar panel of this app. You can change the concordance window or word of interest in the left side bar panel.',align = "Justify"),
                         
                         
                         
                         verbatimTextOutput("concordance"))
                )
           )
       )
    )

