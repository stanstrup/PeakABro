#' Prepare peaklist for interactive browser
#' 
#' This function adds some html that is needed for the interactive browser.
#' It adds a plus button to open the first nesting (collapse_col) and a View button to view the second nesting (modal_col).
#'
#' @param peaklist A \code{\link{tibble}} peaklist with nested columns for pcgroup and the feauture annotations
#' @param collapse_col A string. The first nesting for pcgroups.
#' @param modal_col  A string. The second nesting for feature annotations.
#'
#' @return A \code{\link{tibble}} containing the same columns as the input table but with extra hmtl.
#'
#' @export
#'
#' @importFrom dplyr %>% mutate select bind_cols
#' @importFrom magrittr %<>%
#' @importFrom tibble data_frame
#' @importFrom rlang := sym
#' @importFrom purrr map_int map map2
#'
#'

peaklist_browser_prep <- function(peaklist, collapse_col = "features", modal_col = "anno"){
    
    # make check happy
    . <-
    rows <-
    offset <-
    pcgroup <-
    NULL
    
    # add the + button
    peaklist %<>% {bind_cols(data_frame(' ' = rep('&oplus;',nrow(.))),.)}
    
    # add view button and remove it again when there are nothing to show
    peaklist %<>% mutate(rows := map_int(!!sym(collapse_col), nrow)) %>% 
              mutate(offset = cumsum(rows)-rows) %>% 
              mutate(!!collapse_col := map2(!!sym(collapse_col), offset, ~add_view_col(..1,..2, modal_col=modal_col))) %>% 
              mutate(!!collapse_col := map(!!sym(collapse_col), ~ mutate(..1, View = ifelse(sapply(!!sym(modal_col),nrow)>0,View,""))     )) %>% 
              select(-rows,-offset)
    
    # make pcgroup a character so we can do text search
    peaklist %<>% mutate(pcgroup = as.character(pcgroup)) 
    
    return(peaklist)
}



#' Datatables callback function to modify peakbrowser table
#' 
#' Internal function for the database callback
#'
#' @param modal_col  A string. The second nesting for feature annotations.
#'
#' @return Callback stript.
#'
#' @keywords internal
#'
#'

BP_callback <- function(modal_col){
  paste0("
    table.column(1).nodes().to$().css({cursor: 'pointer'})
    
    // Format child object into another table
    var format = function(d) {
      if(d != null){ 
        var result = ('<table id=\"' + d[1] + '\"><thead><tr>').replace('.','_')
        for (var col in d[d.length - 1][0]){
          result += '<th>' + col + '</th>'
        }
        result += '</tr></thead></table>'
        return result
      }else{
        return ''
      }
    }
    
    var format_datatable = function(d) {
      if(d != null){
        if ('SOME CHECK' == 'LAST SET OF CHILD TABLES') {
          var subtable = $(('table#' + d[1]).replace('.','_')).DataTable({
            'data': d[d.length - 1].map(Object.values),
            'autoWidth': false, 
            'deferRender': true, 
            'stripeClasses': [],
            'info': false, 
            'lengthChange': false, 
            'ordering': false, 
            'paging': false, 
            'scrollX': false, 
            'scrollY': false, 
            'searching': false
          }).draw()
        }else{
          var subtable = $(('table#' + d[1]).replace('.','_')).DataTable({
            'data': d[d.length - 1].map(Object.values),
            'autoWidth': false, 
            'deferRender': true,
            'stripeClasses': [],
            'info': false, 
            'lengthChange': false, 
            'ordering': false, 
            'paging': false, 
            'scrollX': false, 
            'scrollY': false, 
            'searching': false,
            'columnDefs': [
                            //{'orderable': false, 'className': 'details-control', 'targets': 0},
                            {'visible': false, 'targets': -",modal_col,"}
                          ]
          }).draw()
        }
      }
    }
    
    table.on('click', 'td.details-control', function() {
      var table = $(this).closest('table')
      var td = $(this)
      var row = $(table).DataTable().row(td.closest('tr'))
      if (row.child.isShown()) {
        row.child.hide()
        td.html('&oplus;')
      } else {
        row.child(format(row.data())).show()
        format_datatable(row.data())
        td.html('&CircleMinus;')
      }
    })
    
    "
  )
}


#' Function to add the View button
#' 
#' Internal function for the datatables View button that opens the modal
#'
#' @param X  The table to add buttons to.
#' @param offset A numeric vector. Offset for the button id for each row.
#' @param modal_col A string. The second nesting for feature annotations.
#' @param FUN The shiny Input function to create.
#' @param len Integer How many buttons to make.
#' @param id String. Prefix for the id.
#' @param label A character vector. The text to but on each button. Should have the same length as the number of rows in X.
#' @param ...
#'
#' @return Callback stript.
#'
#' @keywords internal
#'
#' @importFrom shiny actionButton
#'

#' @describeIn add_view_col Generates all buttons
add_view_col <- function(X,offset, modal_col){
  
  bind_cols(X,
            View = shinyInput(actionButton, 
                              nrow(X),
                              'button_', 
                              offset,
                              label = paste0("View (", sapply(X[[modal_col]], nrow),")"),
                              onclick = 'Shiny.onInputChange(\"select_button\",  this.id)'
                              )
            )
}

#' @describeIn add_view_col generates multople shiny inputs with different labels
shinyInput <- function(FUN, len, id, offset, label, ...) {
                                                  inputs <- character(len)
                                                  for (i in seq_len(len)) {
                                                    inputs[i] <- as.character(FUN(paste0(id, i+offset), label[i], ...))}
                                                  inputs
}



#' Peaklist Browser
#' 
#' Open a peaklist browser for a peaklist prepared with \code{\link{peaklist_browser_prep}}.
#'
#' @param peaklist A \code{\link{tibble}} peaklist with nested columns for pcgroup and the feauture annotations
#' @param collapse_col A string. The first nesting for pcgroups.
#' @param modal_col  A string. The second nesting for feature annotations.
#'
#' @return Opens a shiny app with the peaklist browser
#'
#' @export
#' @references 
#' https://github.com/rstudio/shiny-examples/issues/9#issuecomment-295018270
#' 
#' https://stackoverflow.com/questions/38575655/shiny-modules-namespace-outside-of-ui-for-javascript-links
#' 
#' https://stackoverflow.com/questions/45739303/r-shiny-handle-action-buttons-in-data-table
#' 
#' https://stackoverflow.com/questions/40107022/r-shinybs-popup-window
#' 
#' https://stackoverflow.com/questions/46593607/datatable-with-nesting-child-rows-and-modal
#'
#' @importFrom dplyr bind_rows
#' @importFrom shiny fluidPage uiOutput reactive eventReactive observeEvent renderUI shinyApp tags column HTML
#' @importFrom shinyBS toggleModal bsModal
#' @importFrom DT dataTableOutput renderDataTable JS
#'

peaklist_browser <- function(peaklist, collapse_col, modal_col){

    # make check happy
    tags <- tags
    
    
    # find nested colums
    collapse_col_idx <- which(collapse_col == colnames(peaklist))
    modal_col_idx <-  which(modal_col == colnames(peaklist[[collapse_col]][[1]]))

    
    
    ui <- fluidPage(   tags$head(tags$style(HTML('
    
                            .modal-lg {
                           width: 95%;
    
                            }
                          '))),
        
        dataTableOutput('my_table'),
                     uiOutput("popup")
                     )
    
    
    server <- function(input, output, session) {
      
      my_data <- reactive(peaklist)  
      
      
    
      output$my_table <- renderDataTable(my_data(),
                                             options = list(columnDefs = list(
                                                                                list(visible = FALSE, targets = c(collapse_col_idx-1) ), # Hide row numbers and nested columns
                                                                                list(orderable = FALSE, className = 'details-control', targets = 0) # turn first column into control column
                                                                              )
                                                            ),
                                             server = TRUE,
                                             rownames = FALSE,
                                             escape = -c(1),
                                             callback = JS(BP_callback(ncol(my_data()[[collapse_col]][[1]])-modal_col_idx+1)),
                                             selection = "none",
                                             filter="top"
                                             )
    
    
      # Here I created a reactive to save which row was clicked which can be stored for further analysis
      SelectedRow <- eventReactive(input$select_button,
                                   as.numeric(strsplit(input$select_button, "_")[[1]][2])
                                  )
    
      # This is needed so that the button is clicked once for modal to show, a bug reported here
      # https://github.com/ebailey78/shinyBS/issues/57
      observeEvent(input$select_button, {
                                          toggleModal(session, "modalExample", "open")
                                        }
                   )
    
      DataRow <- eventReactive(input$select_button,
                               bind_rows(my_data()[[collapse_col]])[[modal_col]][[SelectedRow()]]
                               )
    
      output$popup <- renderUI({  
                                  input$select_button
                                  bsModal("modalExample",
                                          paste0("Data for Row Number: ", SelectedRow()),
                                          "",
                                          size = "large",
                                          column(12, 
                                                 renderDataTable(DataRow(),
                                                                     escape = -c(3,4), # escape name and inchi column
                                                                     filter="top",
                                                                     selection = "none"
                                                                     )
                                             )
                                        )
                              })
    
    }
    
    shinyApp(ui, server)

}
