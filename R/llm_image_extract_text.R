#' Image OCR for Text Extraction using LLMs
#'
#' @param llm_model         a local LLM model either pulled from ollama or hosted
#' @param image             a local image path that has a jpeg, jpg, or png
#' @param backend           either 'ellmer' or 'ollamar', note that 'ollamar' suggests structured outputs while 'ellmer' enforces structured outputs
#' @param additional_prompt text to append to the image prompt
#' @param provider   for `backend = 'ollamar'`, `provider` is ignored. for `backend = 'ellmer'`,
#'                   `provider` refers to the `ellmer::chat_*` providers and can be used to switch
#'                   from "ollama" to other providers such as "perplexity"
#' @param language          a language to guide the LLM model outputs
#' @param ...               a pass through for other generate args and model args like temperature. set the temperature to 0 for more deterministic output
#'
#' @return a df with text and a confidence score
#' @export
llm_image_extract_text <- \(
	llm_model = "qwen2.5vl",
	image = system.file("img/text_img.jpg", package = "kuzco"),
	backend = "ellmer",
	additional_prompt = "",
	provider = "ollama",
	language = "English",
	...
) {
	system_prompt <- base::readLines(paste0(.libPaths()[1], "/kuzco/prompts/system-prompt-extraction.md")) |> paste(collapse = "\n")
	image_prompt <- base::readLines(paste0(.libPaths()[1], "/kuzco/prompts/image-prompt.md")) |> paste(collapse = "\n")
	image_prompt <- paste0(additional_prompt, image_prompt)

	image_prompt <- base::gsub(
	  pattern = "[INPUT_LANGUAGE]",
	  replacement = language,
	  x = image_prompt
	)


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
			provider = provider,
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

ellmer_image_extract_text <- \(llm_model = llm_model,
                               image_prompt = image_prompt,
                               image = image,
                               system_prompt = system_prompt,
                               provider = provider,
                               ...) {

  chat_provider <- chat_ellmer(provider = provider)

  chat <- chat_provider(
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
