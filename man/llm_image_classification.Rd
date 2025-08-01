% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/llm_image_classification.R
\name{llm_image_classification}
\alias{llm_image_classification}
\title{Image Classification using LLMs}
\usage{
llm_image_classification(
  llm_model = "qwen2.5vl",
  image = system.file("img/test_img.jpg", package = "kuzco"),
  backend = "ellmer",
  additional_prompt = "",
  provider = "ollama",
  language = "English",
  ...
)
}
\arguments{
\item{llm_model}{a local LLM model either pulled from ollama or hosted}

\item{image}{a local image path that has a jpeg, jpg, or png}

\item{backend}{either 'ollamar' or 'ellmer', note that 'ollamar' suggests structured outputs while 'ellmer' enforces structured outputs}

\item{additional_prompt}{text to append to the image prompt}

\item{provider}{for \code{backend = 'ollamar'}, \code{provider} is ignored. for \code{backend = 'ellmer'},
\code{provider} refers to the \verb{ellmer::chat_*} providers and can be used to switch
from "ollama" to other providers such as "perplexity"}

\item{language}{a language to guide the LLM model outputs}

\item{...}{a pass through for other generate args and model args like temperature}
}
\value{
a df with image_classification, primary_object, secondary_object, image_description, image_colors, image_proba_names, image_proba_values
}
\description{
Image Classification using LLMs
}
