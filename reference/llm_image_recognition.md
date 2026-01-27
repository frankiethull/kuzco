# Image Recognition using LLMs

Image Recognition using LLMs

## Usage

``` r
llm_image_recognition(
  llm_model = "qwen2.5vl",
  image = system.file("img/test_img.jpg", package = "kuzco"),
  recognize_object = "face",
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

- recognize_object:

  an item you want to LLM to look for

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

  a pass through for other generate args and model args like
  temperature. set the temperature to 0 for more deterministic output

## Value

a df with object_recognized, object_count, object_description,
object_location

## Examples

``` r
# \donttest{
llm_image_recognition(
 llm_model = "qwen2.5vl",
 image = system.file("img/test_img.jpg", package = "kuzco"),
  recognize_object = "nose",
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
