# Image OCR for Text Extraction using LLMs

Image OCR for Text Extraction using LLMs

## Usage

``` r
llm_image_extract_text(
  llm_model = "qwen2.5vl",
  image = system.file("img/text_img.jpg", package = "kuzco"),
  backend = "ellmer",
  additional_prompt = "",
  provider = "ollama",
  language = "English",
  ...
)
```

## Arguments

- llm_model:

  a local LLM model either pulled from ollama or hosted

- image:

  a local image path that has a jpeg, jpg, or png

- backend:

  either 'ellmer' or 'ollamar', note that 'ollamar' suggests structured
  outputs while 'ellmer' enforces structured outputs

- additional_prompt:

  text to append to the image prompt

- provider:

  for `backend = 'ollamar'`, `provider` is ignored. for
  `backend = 'ellmer'`, `provider` refers to the `ellmer::chat_*`
  providers and can be used to switch from "ollama" to other providers
  such as "perplexity"

- language:

  a language to guide the LLM model outputs

- ...:

  a pass through for other generate args and model args like
  temperature. set the temperature to 0 for more deterministic output

## Value

a df with text and a confidence score
