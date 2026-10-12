---
name: kuzco-alt-text
description: Generate accessibility alt text for an image with a local vision LLM. Wraps kuzco's tool_llm_image_alt_text() ellmer tool. Use when the task needs a short textual description of an image, e.g. for accessibility, captions, or image indexing.
---

# kuzco-alt-text

Generate alt text for an image using a local vision language model, exposed as an
[ellmer](https://ellmer.tidyverse.org/) tool by the kuzco R package.

## When to use

The user wants a textual description of an image: accessibility alt text, a caption,
or a quick summary of image contents for indexing or search.

## Setup

Register the tool on an ellmer chat. The model and provider are fixed at registration;
the LLM controls the image path, extra prompt text, and output language per call.

```r
library(kuzco)
library(ellmer)

chat <- chat_ollama(model = "qwen2.5vl")
chat$register_tool(tool_llm_image_alt_text())
```

To use a different model or a hosted provider, pass them to the constructor:

```r
chat$register_tool(tool_llm_image_alt_text(
  llm_model = "qwen2.5vl",
  provider = "ollama"
))
```

## Tool arguments (LLM-controlled)

- `image` (required): local file path to a jpeg, jpg, or png image.
- `additional_prompt` (optional): extra instructions appended to the image prompt,
  e.g. "focus on the people in the foreground".
- `language` (optional): output language, e.g. "English", "Spanish".

## Result

Compact JSON text describing the image, returned to the model as the tool result.
Relay the description to the user; do not invent details beyond what the tool returned.

## Example

> User: "Write alt text for img/photo.jpg"
> 1. Call `kuzco_image_alt_text` with `image = "img/photo.jpg"`.
> 2. Return the description as the alt text.
