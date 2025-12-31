#' shiny kuzco app
#' @description
#' a simple wrapper of kuzco to make computer vision for everyone.
#' few-shot via frank hull and shiny assistant
#' (https://gallery.shinyapps.io/assistant/)
#'
#' @export
#' @returns a shiny app instance as a playground for local llms
#' @examples
#' \dontrun{
#' kuzco_app()
#' }
#'
kuzco_app <- \() {
	check_app()

	ui <- bslib::page_sidebar(
		title = "computer vision with LLMs",
		theme = bslib::bs_theme(brand = system.file(package = "kuzco", "brand/_brand.yml")),
		sidebar = bslib::sidebar(
			shiny::selectInput(
				"selected_function",
				"Select Function",
				choices = c(
					"llm_image_alt_text",
					"llm_image_classification",
					"llm_image_extract_text",
					"llm_image_recognition",
					"llm_image_sentiment"
				)
			),
			shiny::selectInput("backend", "Backend", choices = c("ellmer", "ollamar")),
			shiny::textInput("llm_model", "Model Name", placeholder = "a local llm"),
			shiny::fileInput("image", "Upload Image", accept = c("image/jpeg", "image/png", "image/jpg")),
			shiny::actionButton("run", "Run LLM", class = "btn-primary")
		),

		bslib::layout_columns(
			bslib::card(
				bslib::card_header("Image Preview"),
				shiny::plotOutput("image_preview")
			),
			bslib::card(
				bslib::card_header("Results"),
				gt::gt_output("results_table")
			)
		)
	)

	server <- function(input, output, session) {
		# Reactive value to store the image path
		image_path <- shiny::reactiveVal(NULL)

		# Reactive value to store analysis results
		results <- shiny::reactiveVal(NULL)

		# Handle file upload
		shiny::observeEvent(input$image, {
			shiny::req(input$image)
			# Create a temporary file path for the uploaded image
			temp_file <- file.path(tempdir(), input$image$name)
			file.copy(input$image$datapath, temp_file, overwrite = TRUE)
			image_path(temp_file)
		})

		# Image preview using the view_image function
		output$image_preview <- shiny::renderPlot({
			shiny::req(image_path())
			tryCatch(
				{
					kuzco::view_image(image_path())
				},
				error = function(e) {
					message("Error displaying image:", e$message)
					# Return an empty plot with error message
					plot(1, type = "n", axes = FALSE, xlab = "", ylab = "")
					text(1, 1, paste("Error displaying image:", e$message))
				}
			)
		})

		# Run the selected function when the button is clicked
		shiny::observeEvent(input$run, {
			shiny::req(image_path(), input$selected_function)

			# Show a notification that analysis is running
			shiny::showNotification("Running analysis...", type = "message", id = "analysis")

			# Get the selected function from kuzco package
			tryCatch(
				{
					# Safely get the function
					if (exists(input$selected_function, mode = "function", envir = asNamespace("kuzco"))) {
						selected_func <- get(input$selected_function, envir = asNamespace("kuzco"))

						# Call the function with the provided parameters
						result <- selected_func(
							backend = input$backend,
							llm_model = input$llm_model,
							image = image_path()
						)
						results(result)

						# Remove the notification
						shiny::removeNotification("analysis")
						shiny::showNotification("Analysis complete!", type = "message")
					} else {
						shiny::showNotification(
							paste("Function", input$selected_function, "not found in kuzco package"),
							type = "error"
						)
					}
				},
				error = function(e) {
					shiny::removeNotification("analysis")
					shiny::showNotification(paste("Error:", e$message), type = "error")
				}
			)
		})

		# Display results using the view_results function
		output$results_table <- gt::render_gt({
			shiny::req(results())
			kuzco::view_llm_results(results())
		})
	}

	shiny::shinyApp(ui, server)
}


check_app <- \() {
	if (!rlang::is_installed(c("shiny", "bslib"))) {
		rlang::abort("'shiny' and 'bslib' are required for kuzco::kuzco_app().")
	}
	loadNamespace("shiny")
	loadNamespace("bslib")
	invisible(NULL)
}
