#' Image OCR for Text Extraction using LLMs
#'
#' @param llm_model         a local LLM model pulled from ollama
#' @param image             a local image path that has a jpeg, jpg, or png
#' @param ...               a pass through for other generate args and model args like temperature. set the temperature to 0 for more deterministic output
#'
#' @return a df with text
#' @export
llm_image_extract_text <- \(llm_model = "llava-phi3",
                           image = system.file("img/text_img.jpg", package = "kuzco"),
                           ...){

  system_prompt <- base::readLines(paste0(.libPaths()[1], "/kuzco/prompts/system-prompt-extraction.md")) |> paste(collapse = "\n")
  image_prompt  <- base::readLines(paste0(.libPaths()[1], "/kuzco/prompts/image-prompt.md"))  |> paste(collapse = "\n")

  json_format <- list(
    type = "object",
    properties = list(
      text = list(type = "string")
    ),
    required = list("text")
  )

  llm_json <- ollamar::generate(
    model  = llm_model,
    prompt = image_prompt,
    images = image,
    system = system_prompt,
    output = "structured",
    format = json_format,
    ...
  )

  # llm_parsed <- llm_json |>
  #   jsonlite::parse_json()

  llm_df <- llm_json |>
    as.data.frame()

  return(llm_df)

}
