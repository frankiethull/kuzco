# ellmer tools for kuzco computer vision functions

Lite-weight wrappers that expose each kuzco computer vision function as
an [`ellmer::tool()`](https://ellmer.tidyverse.org/reference/tool.html)
so they can be registered on a chatbot, e.g.

    chat <- ellmer::chat_ollama(model = "qwen2.5vl")
    chat$register_tool(tool_llm_image_classification())
    chat$chat("What is in this image?", ellmer::content_image_file("img/photo.jpg"))

Each constructor fixes the model and provider at registration time and
exposes only the arguments an LLM should control (`image`,
`additional_prompt`, `language`, plus function-specific ones). The tools
always use the `"ellmer"` backend, which enforces structured outputs.
Results (single-row data frames) are collapsed to compact JSON text so
the model gets a clean, readable result.

## Usage

``` r
tool_llm_image_alt_text(
  llm_model = "qwen2.5vl",
  provider = "ollama",
  name = "kuzco_image_alt_text"
)

tool_llm_image_classification(
  llm_model = "qwen2.5vl",
  provider = "ollama",
  name = "kuzco_image_classification"
)

tool_llm_image_custom(
  llm_model = "qwen2.5vl",
  provider = "ollama",
  name = "kuzco_image_custom"
)

tool_llm_image_extract_text(
  llm_model = "qwen2.5vl",
  provider = "ollama",
  name = "kuzco_image_extract_text"
)

tool_llm_image_recognition(
  llm_model = "qwen2.5vl",
  provider = "ollama",
  name = "kuzco_image_recognition"
)

tool_llm_image_sentiment(
  llm_model = "qwen2.5vl",
  provider = "ollama",
  name = "kuzco_image_sentiment"
)
```

## Arguments

- llm_model:

  a local LLM model either pulled from ollama or hosted

- provider:

  for `backend = "ellmer"`, `provider` refers to the `ellmer::chat_*`
  providers, e.g. `"ollama"`, `"openai"`, `"claude"`

- name:

  tool name registered with the chatbot; defaults are
  `"kuzco_image_<task>"`

## Functions

- `tool_llm_image_alt_text()`: Tool: generate alt text for an image

- `tool_llm_image_classification()`: Tool: classify an image

- `tool_llm_image_custom()`: Tool: run a custom image prompt

- `tool_llm_image_extract_text()`: Tool: extract text from an image
  (OCR)

- `tool_llm_image_recognition()`: Tool: recognize objects in an image

- `tool_llm_image_sentiment()`: Tool: analyze image sentiment
