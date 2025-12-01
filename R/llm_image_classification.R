#' Image Classification using LLMs
#'
#' @param llm_model  a local LLM model either pulled from ollama or hosted
#' @param image      a local image path that has a jpeg, jpg, or png
#' @param backend    either 'ollamar' or 'ellmer', note that 'ollamar' suggests structured outputs while 'ellmer' enforces structured outputs
#' @param additional_prompt text to append to the image prompt
#' @param provider   for `backend = 'ollamar'`, `provider` is ignored. for `backend = 'ellmer'`,
#'                   `provider` refers to the `ellmer::chat_*` providers and can be used to switch
#'                   from "ollama" to other providers such as "perplexity"
#' @param language          a language to guide the LLM model outputs
#' @param ...        a pass through for other generate args and model args like temperature
#'
#' @return a df with image_classification, primary_object, secondary_object, image_description, image_colors, image_proba_names, image_proba_values
#' @export
llm_image_classification <- \(
	llm_model = "qwen2.5vl",
	image = system.file("img/test_img.jpg", package = "kuzco"),
	backend = "ellmer",
	additional_prompt = "",
	provider = "ollama",
	language = "English",
	...
) {
	system_prompt <- base::readLines(paste0(.libPaths()[1], "/kuzco/prompts/system-prompt-classification.md")) |>
		paste(collapse = "\n")
	image_prompt <- base::readLines(paste0(.libPaths()[1], "/kuzco/prompts/image-prompt.md")) |> paste(collapse = "\n")
	image_prompt <- paste0(additional_prompt, image_prompt)

	image_prompt <- base::gsub(
		pattern = "[INPUT_LANGUAGE]",
		replacement = language,
		x = image_prompt
	)

	if (backend == 'ollamar') {
		ollamar_image_classification(
			llm_model = llm_model,
			image_prompt = image_prompt,
			image = image,
			system_prompt = system_prompt,
			...
		)
	} else if (backend == 'ellmer') {
		ellmer_image_classification(
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

ollamar_image_classification <- \(
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
		dplyr::select(image_classification:image_colors)

	image_proba_nms <- llm_parsed$image_proba_names
	image_proba_val <- llm_parsed$image_proba_values

	llm_df <- llm_df |>
		dplyr::mutate(
			image_proba_names = list(image_proba_nms),
			image_proba_values = list(image_proba_val)
		)

	return(llm_df)
}

ellmer_image_classification <- \(
	llm_model = llm_model,
	image_prompt = image_prompt,
	image = image,
	system_prompt = system_prompt,
	provider = provider,
	...
) {
	chat_provider <- chat_ellmer(provider = provider)

	chat <- chat_provider(
		model = llm_model,
		system_prompt = system_prompt,
		...
	)

	type_image_class <- ellmer::type_object(
		image_classification = ellmer::type_string(),
		primary_object = ellmer::type_string(),
		secondary_object = ellmer::type_string(),
		image_description = ellmer::type_string(),
		image_colors = ellmer::type_string(),
		image_proba_names = ellmer::type_string(),
		image_proba_values = ellmer::type_string()
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
