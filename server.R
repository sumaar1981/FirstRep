#################################################
#               Basic Text Analysis             #
#################################################

shinyServer(function(input, output,session) {
  set.seed=2092014   

dataset <- reactive({
    if (is.null(input$file)) {return(NULL)}
      else {
        Document = read.csv(input$file$datapath)
        return(Document)}
      })

dtm_tcm =  reactive({
  dataset = dataset()
  fildata = dataset %>% subset(., (rating %in% c(input$checkGroup)) 
                               & (Product %in% c(input$prodGroup))
                               & (paste0("20",substr(review_date,8,10)) %in% c(input$yearGroup))
                               & (Source  %in% c(input$siteGroup)))
                               
  textb = fildata$review_text
  ids = seq(1:nrow(fildata))
  

  dtm.tcm = dtm.tcm.creator(text = textb,
                            id = ids,
                            std.clean = TRUE,
                            std.stop.words = TRUE,
                            stop.words.additional = unlist(strsplit(input$stopw,",")),
                            bigram.encoding = TRUE,
                            # bigram.min.freq = 20,
                            min.dtm.freq = 2,
                            skip.grams.window = 10)
  if (input$ws == "weightTf") {
    dtm = as.matrix(dtm.tcm$dtm)  
  } 
  
  if (input$ws == "weightTfIdf"){
    model_tfidf = TfIdf$new()
    dtm = as.matrix(model_tfidf$fit_transform(dtm.tcm$dtm))
    
    tempd = dtm*0
    tempd[dtm > 0] = 1
    dtm = dtm + tempd
  }  
  
  # tcm = dtm.tcm$tcm
  dtm_tcm_obj = list(dtm = dtm)#, tcm = tcm)
})

wordcounts = reactive({
  
  return(dtm.word.count(dtm_tcm()$dtm))
  
}) 

output$wordcloud <- renderPlot({
  tsum = wordcounts()
  tsum = tsum[order(tsum, decreasing = T)]
  dtm.word.cloud(count = tsum,max.words = 50,title = 'Term Frequency Wordcloud')
  
      })
      
output$cog.dtm <- renderPlot({
  
  distill.cog.tcm(mat1=dtm_tcm()$dtm, # input TCM MAT
                  mattype = "DTM",
                  title = "COG from DTM Adjacency", # title for the graph
                  s=4,    # no. of central nodes
                  k1 =5)  # No. of Connection with central Nodes
      })


output$dtmsummary1  <- renderPrint({
  if (is.null(input$file)) {return(NULL)}
  else {
    data.frame(Counts = wordcounts()[order(wordcounts(), decreasing = T)][1:50])
  }
})

output$concordance = renderPrint({
  dataset = dataset()
  fildata = dataset %>% subset(., (rating %in% c(input$checkGroup)) 
                               & (Product %in% c(input$prodGroup))
                               & (paste0("20",substr(review_date,8,10)) %in% c(input$yearGroup))
                               & (Source  %in% c(input$siteGroup)))
  
  textb = fildata$review_text
  a0 = concordance.r(textb,input$concord.word, input$window)
  concordance = a0$concordance
  concordance
})

output$bi.grams = renderPrint({
  dataset = dataset()
  fildata = dataset %>% subset(., (rating %in% c(input$checkGroup)) 
                               & (Product %in% c(input$prodGroup))
                               & (paste0("20",substr(review_date,8,10)) %in% c(input$yearGroup))
                               & (Source  %in% c(input$siteGroup)))
  
  textb = fildata$review_text
  a0 = bigram.collocation(textb)
  a0 = a0[order(a0$n, decreasing = T),]
  if (nrow(a0) > 100){
    a1 = a0[1:100,]
  } else {
    a1 = a0
  }
  a1
})

})
