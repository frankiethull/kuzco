# Customized Vision using LLMs

Customized Vision using LLMs

## Usage

``` r
llm_image_custom(
  llm_model = "qwen2.5vl",
  image = system.file("img/test_img.jpg", package = "kuzco"),
  backend = "ellmer",
  system_prompt = "You are a terse assistant in computer vision sentiment.",
  image_prompt = "return JSON describing image, do not include json or backticks",
  example_df = NULL,
  provider = "ollama",
  ...
)
```

## Arguments

- llm_model:

  a local LLM model either pulled from ollama or hosted

- image:

  a local image path that has a jpeg, jpg, or png

- backend:

  either 'ollamar' or 'ellmer'

- system_prompt:

  overarching assistant description, *please note that the LLM should be
  told to return as JSON while kuzco will handle the conversions to and
  from JSON*

- image_prompt:

  anything you want to really remind the llm about.

- example_df:

  an example data.frame to show the llm what you want returned *note
  this will be converted to JSON for the LLM*.

- provider:

  for `backend = 'ollamar'`, `provider` is ignored. for
  `backend = 'ellmer'`, `provider` refers to the `ellmer::chat_*`
  providers and can be used to switch from "ollama" to other providers
  such as "perplexity"

- ...:

  a pass through for other generate args and model args like temperature

## Value

a customized return based on example_df for custom control
