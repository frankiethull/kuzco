#' Customized Vision using LLMs
#'
#' @param llm_model  a local LLM model either pulled from ollama or hosted
#' @param image      a local image path that has a jpeg, jpg, or png
#' @param backend    either 'ollamar' or 'ellmer'
#' @param system_prompt overarching assistant description, *please note that the LLM should be told to return as JSON while kuzco will handle the conversions to and from JSON*
#' @param image_prompt anything you want to really remind the llm about.
#' @param example_df an example data.frame to show the llm what you want returned *note this will be converted to JSON for the LLM*.
#' @param provider   for `backend = 'ollamar'`, `provider` is ignored. for `backend = 'ellmer'`,
#'                   `provider` refers to the `ellmer::chat_*` providers and can be used to switch
#'                   from "ollama" to other providers such as "perplexity"
#' @param ...        a pass through for other generate args and model args like temperature
#'
#' @return a customized return based on example_df for custom control
#' @export
llm_image_custom <- \(
	llm_model = "qwen2.5vl",
	image = system.file("img/test_img.jpg", package = "kuzco"),
	backend = "ellmer",
	system_prompt = "You are a terse assistant in computer vision sentiment.",
	image_prompt = "return JSON describing image, do not include json or backticks",
	example_df = NULL,
	provider = "ollama",
	...
) {
	system_prompt <- system_prompt
	image_prompt <- image_prompt

	if (!is.null(example_df) && inherits(example_df, "data.frame")) {
		example_json <- jsonlite::toJSON(example_df) |> jsonlite::prettify()
		system_prompt <- paste0(system_prompt, '\n', "example given:", "\n", example_json) # |> cat()
	}

	if (backend == 'ollamar') {
		ollamar_image_custom(
			llm_model = llm_model,
			image_prompt = image_prompt,
			image = image,
			system_prompt = system_prompt,
			...
		)
	} else if (backend == 'ellmer') {
		ellmer_image_custom(
			llm_model = llm_model,
			image_prompt = image_prompt,
			image = image,
			system_prompt = system_prompt,
			example_df = example_df,
			provider = provider,
			...
		)
	} else {
		print('incorrect backend selection')
	}
}

# implementations ---------------------------------------------------

ollamar_image_custom <- \(
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
		as.data.frame()

	return(llm_df)
}

ellmer_image_custom <- \(
	llm_model = llm_model,
	image_prompt = image_prompt,
	image = image,
	system_prompt = system_prompt,
	example_df = example_df,
	provider = provider,
	...
) {
	chat_provider <- chat_ellmer(provider = provider)

	chat <- chat_provider(
		model = llm_model,
		system_prompt = system_prompt,
		...
	)
	if (!is.null(example_df) && inherits(example_df, "data.frame")) {
		# @@@@ dynamic custom schema struct @@@@ -----
		# columns and types ~
		cols_and_types <- sapply(example_df, class)
		col_names <- cols_and_types |> names()
		# json hacks ---
		# schema header ~
		prefix_schema <- paste0(
			'{
		"type": "object",
		"description": "",
		"properties": {'
		)
		# schema footer ~
		suffix_schema <- paste0(
			'
		},
		"required":',
			col_names |> jsonlite::toJSON(),
			',
		"additionalProperties": false
		}'
		)
		# dynamically write cols + types ~
		middle_schema <- ""
		for (i in 1:length(cols_and_types)) {
			col_name <- col_names[[i]]
			#TODO, case_when for many types (?)
			col_type <- ifelse(cols_and_types[[i]] == "character", "string", "number")

			middle_schema <-
				paste0(
					middle_schema,
					'"',
					col_name,
					'": {',
					'"type": "',
					col_type,
					'",',
					'"description": ""
				},'
				)
		}
		middle_schema <- sub(",$", "", middle_schema)
		customized_schema <- paste0(prefix_schema, middle_schema, suffix_schema)
		# issues arraying types from type schema,
		# will return a list from ellmer and convert to df.
		type_customized_schema <- ellmer::type_from_schema(customized_schema)
	} else {
		type_customized_schema <- ellmer::type_object(reply = ellmer::type_string())
	}

	llm_list <- chat$chat_structured(
		image_prompt,
		ellmer::content_image_file(image),
		type = type_customized_schema
	)

	llm_df <- llm_list |> list2DF()

	return(llm_df)
}
