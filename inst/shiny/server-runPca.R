observe({
  runPcaReactive()
})

runPcaReactive <-
  eventReactive(input$runPca, {
    withProgress(message = "Processing , please wait",{
      print("Running PCA")

      if(input$sctransformOption == 'defaultPath')
        pbmc <- findVariableGenesReactive()$pbmc
      else
        pbmc <- sctransformReactive()$pbmc

      js$addStatusIcon("runPcaTab","loading")

      shiny::setProgress(value = 0.4, detail = "Performing PCA ...")

      pbmc <- RunPCA(object = pbmc, features = VariableFeatures(object = pbmc), verbose = FALSE)

      shinyjs::show(selector = "a[data-value=\"vizPcaPlot\"]")
      shinyjs::show(selector = "a[data-value=\"pcaPlot\"]")
      shinyjs::show(selector = "a[data-value=\"heatmapPlot\"]")
      shinyjs::show(selector = "a[data-value=\"jackStrawPlot\"]")
      shinyjs::show(selector = "a[data-value=\"runPcaTab\"]")

      js$addStatusIcon("runPcaTab","done")
      js$addStatusIcon("vizPcaPlot","graph")
      js$addStatusIcon("pcaPlot","graph")
      js$addStatusIcon("heatmapPlot","graph")
      js$addStatusIcon("jackStrawPlot","next")

      numCellsToUse = ifelse(ncol(x = pbmc) > 500, 500, ncol(x = pbmc))
      updateNumericInput(session, "cellsToUse", value = numCellsToUse)
      
      updateSelectizeInput(session, "clustPCDim", choices = 1:50, selected = 1:10)
      
      updateTabItems(session, "tabs", "runPcaTab")

      return(list('pbmc'=pbmc))
    })}
  )


output$pcsPrintAvailable <- reactive({
  if(is.null(runPcaReactive()$pbmc))
    return(FALSE)
  return(TRUE)
})
outputOptions(output, 'pcsPrintAvailable', suspendWhenHidden=FALSE)

output$pcsPrint <- renderText({

  pbmc <- runPcaReactive()$pbmc

  #printStr = capture.output(PrintPCA(object = pbmc, pcs.print = 1:input$numPCs, genes.print = input$numGenes, use.full = FALSE))
  
  printStr = capture.output(print(x = pbmc[['pca']], dims = 1:input$numPCs, nfeatures = input$numGenes, projected = FALSE))
  
  printStr = gsub("\\[1\\]","",printStr)
  printStr = paste(printStr, collapse = "<br>")

  HTML(printStr)
})

observeEvent(input$vizPca, {

  #updateTabItems(session, "tabs", "vizPcaPlot")
  GotoTab("vizPcaPlot")
})
