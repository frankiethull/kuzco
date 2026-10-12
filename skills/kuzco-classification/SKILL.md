---
name: kuzco-classification
description: Classify an image and describe its contents with a local vision LLM. Wraps kuzco's tool_llm_image_classification() ellmer tool. Use when the task needs image classification, object identification, or a structured description of what an image contains.
---

# kuzco-classification

Classify an image and describe its contents using a local vision language model,
exposed as an [ellmer](https://ellmer.tidyverse.org/) tool by the kuzco R package.

## When to use

The user wants to know what an image shows: its category, the primary and secondary
objects, a description, dominant colors, or class probabilities. This is the default
skill for "what is in this image?" questions.

## Setup

```r
library(kuzco)
library(ellmer)

chat <- chat_ollama(model = "qwen2.5vl")
chat$register_tool(tool_llm_image_classification())
```

## Tool arguments (LLM-controlled)

- `image` (required): local file path to a jpeg, jpg, or png image.
- `additional_prompt` (optional): extra instructions, e.g. "pay special attention to text on signs".
- `language` (optional): output language, e.g. "English".

## Result

Compact JSON text with `image_classification`, `primary_object`, `secondary_object`,
`image_description`, `image_colors`, and `image_proba_names` / `image_proba_values`.
Summarize the key fields for the user; quote the description verbatim when asked for detail.

## Example

> User: "What animal is in img/puppy.jpg?"
> 1. Call `kuzco_image_classification` with `image = "img/puppy.jpg"`.
> 2. Answer from `primary_object` and `image_description`, mentioning the classification and confidence.
