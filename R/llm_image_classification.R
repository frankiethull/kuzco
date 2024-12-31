#' Image Classification using LLMs
#'
#' @param llm_model  a local LLM model pulled from ollama
#' @param image      a local image path that has a jpeg, jpg, or png
#' @param ...        a pass through for other generate args and model args like temperature
#'
#' @return a df with image_classification, primary_object, secondary_object, image_description, image_colors, image_proba_names, image_proba_values
#' @export
llm_image_classification <- \(llm_model = "llava-phi3",
                              image = system.file("img/test_img.jpg", package = "kuzco"),
                              ...){

  system_prompt <- base::readLines(paste0(.libPaths()[1], "/kuzco/prompts/system-prompt-classification.md")) |> paste(collapse = "\n")
  image_prompt  <- base::readLines(paste0(.libPaths()[1], "/kuzco/prompts/image-prompt.md"))  |> paste(collapse = "\n")

  json_format <- list(
    type = "object",
    properties = list(
      image_classification = list(type = "string"),
      primary_object       = list(type = "string"),
      secondary_object     = list(type = "string"),
      image_description    = list(type = "string"),
      image_colors         = list(type = "array", items = list(type = "string")),
      image_proba_names    = list(type = "array", items = list(type = "string")),
      image_proba_scores   = list(type = "array", items = list(type = "number"))
    ),
    required = list("image_classification", "primary_object", "secondary_object", "image_desciption", "image_proba_names", "image_proba_scores")
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

  # llm_df <- llm_json |>
  #   as.data.frame() |>
  #   dplyr::select(image_classification:image_colors)
  #
  # image_proba_nms <- llm_parsed$image_proba_names
  # image_proba_val <- llm_parsed$image_proba_values
  #
  # llm_df <- llm_df |>
  #   dplyr::mutate(
  #     image_proba_names  = list(image_proba_nms),
  #     image_proba_values = list(image_proba_val)
  #   )

  return(llm_json)

}
