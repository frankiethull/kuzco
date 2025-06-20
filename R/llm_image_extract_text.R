#' Image OCR for Text Extraction using LLMs
#'
#' @param llm_model         a local LLM model pulled from ollama
#' @param image             a local image path that has a jpeg, jpg, or png
#' @param backend           either 'ellmer' or 'ollamar', note that 'ollamar' suggests structured outputs while 'ellmer' enforces structured outputs
#' @param additional_prompt text to append to the image prompt
#' @param ...               a pass through for other generate args and model args like temperature. set the temperature to 0 for more deterministic output
#'
#' @return a df with text and a confidence score
#' @export
llm_image_extract_text <- \(
	llm_model = "llava-phi3",
	image = system.file("img/text_img.jpg", package = "kuzco"),
	backend = 'ellmer',
	additional_prompt = "",
	...
) {
	system_prompt <- base::readLines(paste0(.libPaths()[1], "/kuzco/prompts/system-prompt-extraction.md")) |> paste(collapse = "\n")
	image_prompt <- base::readLines(paste0(.libPaths()[1], "/kuzco/prompts/image-prompt.md")) |> paste(collapse = "\n")
	image_prompt <- paste0(additional_prompt, image_prompt)

	if (backend == 'ollamar') {
		kuzco:::ollamar_image_extract_text(
			llm_model = llm_model,
			image_prompt = image_prompt,
			image = image,
			system_prompt = system_prompt,
			...
		)
	} else if (backend == 'ellmer') {
		kuzco:::ellmer_image_extract_text(
			llm_model = llm_model,
			image_prompt = image_prompt,
			image = image,
			system_prompt = system_prompt,
			...
		)
	} else {
		print('incorrect backend selection')
	}
}


ollamar_image_extract_text <- \(
	llm_model = llm_model,
	image_prompt = image_prompt,
	image = image,
	system_prompt = system_prompt,
	...
) {
	llm_json <- ollamar::generate(
		model = llm_model,
		prompt = image_prompt,
		images = image,
		system = system_prompt,
		output = "text",
		...
	)

	llm_parsed <- llm_json |>
		jsonlite::parse_json()

	llm_df <- llm_parsed |>
		as.data.frame() |>
		dplyr::select("text" = dplyr::contains("text"),
		              "confidence_score" = dplyr::contains("confiden"))

	return(llm_df)
}

ellmer_image_extract_text <- \(llm_model = llm_model, image_prompt = image_prompt, image = image, system_prompt = system_prompt, ...) {
	# add a switch for other llm providers ?
	chat <- ellmer::chat_ollama(
		model = llm_model,
		system_prompt = system_prompt,
		...
	)

	type_image_class <- ellmer::type_object(
		text = ellmer::type_string(),
		confidence_score = ellmer::type_number()
	)

	image_summary <- ellmer::type_object(
		img_class = ellmer::type_array(items = type_image_class)
	)

	llm_df <- chat$chat_structured(
		image_prompt,
		ellmer::content_image_file(image),
		type = image_summary
	)

	return(llm_df$img_class)
}
