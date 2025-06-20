% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/llm_image_sentiment.R
\name{llm_image_sentiment}
\alias{llm_image_sentiment}
\title{Image Sentiment using LLMs}
\usage{
llm_image_sentiment(
  llm_model = "llava-phi3",
  image = system.file("img/test_img.jpg", package = "kuzco"),
  backend = "ellmer",
  additional_prompt = "",
  ...
)
}
\arguments{
\item{llm_model}{a local LLM model pulled from ollama}

\item{image}{a local image path that has a jpeg, jpg, or png}

\item{backend}{either 'ollamar' or 'ellmer', note that 'ollamar' suggests structured outputs while 'ellmer' enforces structured outputs}

\item{additional_prompt}{text to append to the image prompt}

\item{...}{a pass through for other generate args and model args like temperature. set the temperature to 0 for more deterministic output}
}
\value{
a df with image_sentiment, image_score, sentiment_description, image_keywords
}
\description{
Image Sentiment using LLMs
}
