#' ellmer tools for kuzco computer vision functions
#'
#' @description
#' Lite-weight wrappers that expose each kuzco computer vision function as an
#' [ellmer::tool()] so they can be registered on a chatbot, e.g.
#'
#' ```r
#' chat <- ellmer::chat_ollama(model = "qwen2.5vl")
#' chat$register_tool(tool_llm_image_classification())
#' chat$chat("What is in this image?", ellmer::content_image_file("img/photo.jpg"))
#' ```
#'
#' Each constructor fixes the model and provider at registration time and
#' exposes only the arguments an LLM should control (`image`,
#' `additional_prompt`, `language`, plus function-specific ones). The tools
#' always use the `"ellmer"` backend, which enforces structured outputs.
#' Results (single-row data frames) are collapsed to compact JSON text so the
#' model gets a clean, readable result.
#'
#' @param llm_model a local LLM model either pulled from ollama or hosted
#' @param provider for `backend = "ellmer"`, `provider` refers to the
#'   `ellmer::chat_*` providers, e.g. `"ollama"`, `"openai"`, `"claude"`
#' @param name tool name registered with the chatbot; defaults are
#'   `"kuzco_image_<task>"`
#' @name kuzco-tools
NULL

#' Collapse a kuzco result data frame to compact JSON text for tool results
#' @noRd
.tool_result_json <- function(df) {
  if (is.data.frame(df) && nrow(df) >= 1L) {
    df <- df[1L, , drop = FALSE]
  }
  # as.list() keeps list-columns intact; auto_unbox keeps scalars scalar
  jsonlite::toJSON(as.list(df), auto_unbox = TRUE, pretty = FALSE)
}

#' @describeIn kuzco-tools Tool: generate alt text for an image
#' @export
tool_llm_image_alt_text <- function(
    llm_model = "qwen2.5vl",
    provider = "ollama",
    name = "kuzco_image_alt_text") {
  fun <- function(image, additional_prompt = "", language = "English") {
    res <- llm_image_alt_text(
      llm_model = llm_model,
      image = image,
      backend = "ellmer",
      additional_prompt = additional_prompt,
      provider = provider,
      language = language
    )
    .tool_result_json(res)
  }
  ellmer::tool(
    fun,
    name = name,
    description = paste(
      "Generate accessibility alt text for an image.",
      "Returns JSON text describing the image contents."
    ),
    arguments = list(
      image = ellmer::type_string(
        "Local file path to a jpeg, jpg, or png image."
      ),
      additional_prompt = ellmer::type_string(
        "Extra instructions appended to the image prompt.",
        required = FALSE
      ),
      language = ellmer::type_string(
        "Language to guide the model output, e.g. 'English'.",
        required = FALSE
      )
    )
  )
}

#' @describeIn kuzco-tools Tool: classify an image
#' @export
tool_llm_image_classification <- function(
    llm_model = "qwen2.5vl",
    provider = "ollama",
    name = "kuzco_image_classification") {
  fun <- function(image, additional_prompt = "", language = "English") {
    res <- llm_image_classification(
      llm_model = llm_model,
      image = image,
      backend = "ellmer",
      additional_prompt = additional_prompt,
      provider = provider,
      language = language
    )
    .tool_result_json(res)
  }
  ellmer::tool(
    fun,
    name = name,
    description = paste(
      "Classify an image and describe its contents.",
      "Returns JSON text with image_classification, primary_object,",
      "secondary_object, image_description, image_colors, and",
      "image_proba_names / image_proba_values."
    ),
    arguments = list(
      image = ellmer::type_string(
        "Local file path to a jpeg, jpg, or png image."
      ),
      additional_prompt = ellmer::type_string(
        "Extra instructions appended to the image prompt.",
        required = FALSE
      ),
      language = ellmer::type_string(
        "Language to guide the model output, e.g. 'English'.",
        required = FALSE
      )
    )
  )
}

#' @describeIn kuzco-tools Tool: run a custom image prompt
#' @export
tool_llm_image_custom <- function(
    llm_model = "qwen2.5vl",
    provider = "ollama",
    name = "kuzco_image_custom") {
  fun <- function(image, image_prompt, system_prompt = "You are a terse assistant in computer vision.") {
    res <- llm_image_custom(
      llm_model = llm_model,
      image = image,
      backend = "ellmer",
      system_prompt = system_prompt,
      image_prompt = image_prompt,
      provider = provider
    )
    .tool_result_json(res)
  }
  ellmer::tool(
    fun,
    name = name,
    description = paste(
      "Run a custom computer-vision prompt against an image.",
      "Use when none of the specialized image tools fit the task.",
      "Returns JSON text with the model's structured response."
    ),
    arguments = list(
      image = ellmer::type_string(
        "Local file path to a jpeg, jpg, or png image."
      ),
      image_prompt = ellmer::type_string(
        "The prompt describing what to extract or describe about the image."
      ),
      system_prompt = ellmer::type_string(
        "System prompt steering the model's persona and output style.",
        required = FALSE
      )
    )
  )
}

#' @describeIn kuzco-tools Tool: extract text from an image (OCR)
#' @export
tool_llm_image_extract_text <- function(
    llm_model = "qwen2.5vl",
    provider = "ollama",
    name = "kuzco_image_extract_text") {
  fun <- function(image, additional_prompt = "", language = "English") {
    res <- llm_image_extract_text(
      llm_model = llm_model,
      image = image,
      backend = "ellmer",
      additional_prompt = additional_prompt,
      provider = provider,
      language = language
    )
    .tool_result_json(res)
  }
  ellmer::tool(
    fun,
    name = name,
    description = paste(
      "Extract text visible in an image (OCR).",
      "Returns JSON text with the extracted text and a confidence score."
    ),
    arguments = list(
      image = ellmer::type_string(
        "Local file path to a jpeg, jpg, or png image."
      ),
      additional_prompt = ellmer::type_string(
        "Extra instructions appended to the image prompt.",
        required = FALSE
      ),
      language = ellmer::type_string(
        "Language to guide the model output, e.g. 'English'.",
        required = FALSE
      )
    )
  )
}

#' @describeIn kuzco-tools Tool: recognize objects in an image
#' @export
tool_llm_image_recognition <- function(
    llm_model = "qwen2.5vl",
    provider = "ollama",
    name = "kuzco_image_recognition") {
  fun <- function(image, recognize_object = "face", additional_prompt = "", language = "English") {
    res <- llm_image_recognition(
      llm_model = llm_model,
      image = image,
      recognize_object = recognize_object,
      backend = "ellmer",
      additional_prompt = additional_prompt,
      provider = provider,
      language = language
    )
    .tool_result_json(res)
  }
  ellmer::tool(
    fun,
    name = name,
    description = paste(
      "Recognize and locate instances of an object in an image.",
      "Returns JSON text with object_recognized, object_count,",
      "object_description, and object_location."
    ),
    arguments = list(
      image = ellmer::type_string(
        "Local file path to a jpeg, jpg, or png image."
      ),
      recognize_object = ellmer::type_string(
        "The object to recognize, e.g. 'face', 'car', 'dog'.",
        required = FALSE
      ),
      additional_prompt = ellmer::type_string(
        "Extra instructions appended to the image prompt.",
        required = FALSE
      ),
      language = ellmer::type_string(
        "Language to guide the model output, e.g. 'English'.",
        required = FALSE
      )
    )
  )
}

#' @describeIn kuzco-tools Tool: analyze image sentiment
#' @export
tool_llm_image_sentiment <- function(
    llm_model = "qwen2.5vl",
    provider = "ollama",
    name = "kuzco_image_sentiment") {
  fun <- function(image, additional_prompt = "", language = "English") {
    res <- llm_image_sentiment(
      llm_model = llm_model,
      image = image,
      backend = "ellmer",
      additional_prompt = additional_prompt,
      provider = provider,
      language = language
    )
    .tool_result_json(res)
  }
  ellmer::tool(
    fun,
    name = name,
    description = paste(
      "Analyze the sentiment or mood conveyed by an image.",
      "Returns JSON text with image_sentiment, image_score,",
      "sentiment_description, and image_keywords."
    ),
    arguments = list(
      image = ellmer::type_string(
        "Local file path to a jpeg, jpg, or png image."
      ),
      additional_prompt = ellmer::type_string(
        "Extra instructions appended to the image prompt.",
        required = FALSE
      ),
      language = ellmer::type_string(
        "Language to guide the model output, e.g. 'English'.",
        required = FALSE
      )
    )
  )
}
