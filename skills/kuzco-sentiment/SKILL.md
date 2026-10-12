---
name: kuzco-sentiment
description: Analyze the sentiment or mood conveyed by an image with a local vision LLM. Wraps kuzco's tool_llm_image_sentiment() ellmer tool. Use when the task needs the emotional tone of an image, e.g. for content moderation, marketing, or curation.
---

# kuzco-sentiment

Analyze the sentiment or mood conveyed by an image using a local vision language
model, exposed as an [ellmer](https://ellmer.tidyverse.org/) tool by the kuzco R
package.

## When to use

The user wants the emotional tone of an image: cheerful, somber, threatening,
calm. Useful for content moderation triage, marketing asset selection, or photo
curation. For factual descriptions of image contents, use kuzco-classification.

## Setup

```r
library(kuzco)
library(ellmer)

chat <- chat_ollama(model = "qwen2.5vl")
chat$register_tool(tool_llm_image_sentiment())
```

## Tool arguments (LLM-controlled)

- `image` (required): local file path to a jpeg, jpg, or png image.
- `additional_prompt` (optional): extra instructions, e.g. "consider cultural context".
- `language` (optional): output language, e.g. "English".

## Result

Compact JSON text with `image_sentiment`, `image_score`, `sentiment_description`,
and `image_keywords`. Lead with the sentiment label and score, then the description.
Present sentiment as the model's reading, not as ground truth.

## Example

> User: "What mood does img/sunset.jpg convey?"
> 1. Call `kuzco_image_sentiment` with `image = "img/sunset.jpg"`.
> 2. Report the sentiment, score, and description.
