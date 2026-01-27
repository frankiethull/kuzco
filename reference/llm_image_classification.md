# Image Classification using LLMs

Image Classification using LLMs

## Usage

``` r
llm_image_classification(
  llm_model = "qwen2.5vl",
  image = system.file("img/test_img.jpg", package = "kuzco"),
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

  either 'ollamar' or 'ellmer', note that 'ollamar' suggests structured
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

  a pass through for other generate args and model args like temperature

## Value

a df with image_classification, primary_object, secondary_object,
image_description, image_colors, image_proba_names, image_proba_values

## Examples

``` r
# \donttest{
llm_image_classification(
 llm_model = "qwen2.5vl",
 image = system.file("img/test_img.jpg", package = "kuzco"),
 backend = 'ellmer',
 additional_prompt = "",
provider = "ollama",
language = "English"
)
#> Ollama local server not running or wrong server.
#> Download and launch Ollama app to run the server. Visit https://ollama.com or https://github.com/ollama/ollama
#> Error: Could not connect to the local Ollama server via ollamar::test_connection().
#> Make sure the Ollama server is running (default: http://localhost:11434).
# }
```
