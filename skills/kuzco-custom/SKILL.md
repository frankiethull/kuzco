---
name: kuzco-custom
description: Run a custom computer-vision prompt against an image with a local vision LLM. Wraps kuzco's tool_llm_image_custom() ellmer tool. Use when none of the specialized kuzco image skills (classification, OCR, recognition, sentiment, alt text) fit the task.
---

# kuzco-custom

Run an arbitrary computer-vision prompt against an image using a local vision
language model, exposed as an [ellmer](https://ellmer.tidyverse.org/) tool by the
kuzco R package. This is the escape hatch for image tasks the specialized skills
do not cover.

## When to use

The task needs something from an image that classification, OCR, object recognition,
sentiment analysis, or alt text do not capture — e.g. "count the windows", "is anyone
wearing a red hat?", "describe the chart axes". Prefer a specialized skill when one fits;
use this one otherwise.

## Setup

```r
library(kuzco)
library(ellmer)

chat <- chat_ollama(model = "qwen2.5vl")
chat$register_tool(tool_llm_image_custom())
```

## Tool arguments (LLM-controlled)

- `image` (required): local file path to a jpeg, jpg, or png image.
- `image_prompt` (required): the prompt describing what to extract or describe about
  the image. Be specific: state exactly what to look for and what shape the answer
  should take.
- `system_prompt` (optional): persona/style steering, defaults to a terse computer
  vision assistant.

## Result

Compact JSON text with the model's structured response to the custom prompt.
Present it directly; do not reformat structured fields the user asked for.

## Example

> User: "How many bicycles are in img/street.jpg?"
> 1. Call `kuzco_image_custom` with `image = "img/street.jpg"` and
>    `image_prompt = "Count the bicycles visible in the image. Return the count and briefly describe where each one is."`.
> 2. Report the count and locations.
