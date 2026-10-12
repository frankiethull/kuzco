---
name: kuzco-recognition
description: Recognize and locate instances of an object in an image with a local vision LLM. Wraps kuzco's tool_llm_image_recognition() ellmer tool. Use when the task needs finding, counting, or locating specific objects (faces, cars, animals) in an image.
---

# kuzco-recognition

Recognize and locate instances of an object in an image using a local vision
language model, exposed as an [ellmer](https://ellmer.tidyverse.org/) tool by the
kuzco R package.

## When to use

The user wants to find a specific kind of object in an image: faces, cars, dogs,
text regions. Counting instances and describing/locating each one. For general
"what is in this image?" questions, use kuzco-classification instead.

## Setup

```r
library(kuzco)
library(ellmer)

chat <- chat_ollama(model = "qwen2.5vl")
chat$register_tool(tool_llm_image_recognition())
```

## Tool arguments (LLM-controlled)

- `image` (required): local file path to a jpeg, jpg, or png image.
- `recognize_object` (optional): the object to recognize, e.g. "face", "car", "dog".
  Defaults to "face".
- `additional_prompt` (optional): extra instructions, e.g. "only count adults".
- `language` (optional): output language, e.g. "English".

## Result

Compact JSON text with `object_recognized`, `object_count`, `object_description`,
and `object_location`. Report the count first, then describe/locate instances.
If the count is zero, say so plainly rather than hedging.

## Example

> User: "How many faces are in img/group.jpg and where?"
> 1. Call `kuzco_image_recognition` with `image = "img/group.jpg"`, `recognize_object = "face"`.
> 2. Report the count and describe each location.
