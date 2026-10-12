---
name: kuzco-extract-text
description: Extract text visible in an image (OCR) with a local vision LLM. Wraps kuzco's tool_llm_image_extract_text() ellmer tool. Use when the task needs reading text from screenshots, documents, signs, labels, or any image containing writing.
---

# kuzco-extract-text

Extract text visible in an image (OCR) using a local vision language model, exposed
as an [ellmer](https://ellmer.tidyverse.org/) tool by the kuzco R package.

## When to use

The user wants the text content of an image: screenshots, scanned documents, photos
of signs or labels, memes, charts with annotations. If the task is about the image
as a whole rather than its text, use kuzco-classification instead.

## Setup

```r
library(kuzco)
library(ellmer)

chat <- chat_ollama(model = "qwen2.5vl")
chat$register_tool(tool_llm_image_extract_text())
```

## Tool arguments (LLM-controlled)

- `image` (required): local file path to a jpeg, jpg, or png image.
- `additional_prompt` (optional): extra instructions, e.g. "only transcribe the headline".
- `language` (optional): output language, e.g. "English".

## Result

Compact JSON text with the extracted text and a confidence score. Reproduce the
transcribed text faithfully; flag low confidence to the user rather than silently
"fixing" unclear passages.

## Example

> User: "What does the sign say in img/sign.jpg?"
> 1. Call `kuzco_image_extract_text` with `image = "img/sign.jpg"`.
> 2. Quote the extracted text and note the confidence.
