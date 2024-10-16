library(shiny)
library(bslib)
library(quarto)
library(gapminder)


ui <- page_fluid(
  titlePanel("Gapminder PDF Report Generator"),
  selectInput("country_focus", 
              "Select Country:",
              choices = unique(gapminder$country),
              selected = "United States"),
  sliderInput("date_range",
              "Select Data Range:",
              min = 1952,
              max = 2007,
              value = c(1952, 2007),
              step = 5,
              sep = ""),
  radioButtons("type",
               "Select Format:",
               choices = c("Document", "Poster"),
               selected = "Document"),
  downloadButton("downloadPDF", "Download PDF Report")
)

server <- function(input, output) {
  
  filename <- reactive({
    paste(input$country_focus, "-", Sys.Date(), ".pdf", sep = "")
  })
  
  output$downloadPDF <- downloadHandler(
    
    filename = function() filename(),
    content = function(file) {
      # Use withProgress to show a progress bar
      withProgress(message = "Creating Report: ", value = 0, {
        
        # Stage 1: Increment progress
        incProgress(0.3, detail = "Collecting inputs...")
        
        # Generate the Quarto file
        params <- list(country_focus = input$country_focus, date_range = input$date_range)
        
        incProgress(0.3, detail = "Building...")
        
        if (input$type == "Document") {
          
          # Use Quarto's render function to create the PDF
          quarto_render(input = "quarto-doc.qmd", 
                        output_format = "typst",
                        output_file = filename(),
                        execute_params = params)
        } else if (input$type == "Poster") {
          quarto_render(input = "quarto-poster.qmd", 
                        output_format = "poster-typst",
                        output_file = filename(),
                        execute_params = params)
        }
        incProgress(1, detail = "Downloading report...")
        file.copy(filename(), file)
      })
    }
  )
}

shinyApp(ui = ui, server = server)
