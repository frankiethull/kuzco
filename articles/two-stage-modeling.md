# two-stage-modeling

``` r

library(kuzco)
library(maize)
library(dplyr)
library(purrr)
```

## Two-Stage Modeling: AI Vision + ML Classification

kuzco’s LLM functions are great at turning pixels into words:
descriptions, labels, object lists. But sometimes you want a *trained*
classifier on top — one with calibrated probabilities, cross-validation,
and no per-prediction API bill. That’s the two-stage pattern:

1.  **Stage 1 (AI)**: use kuzco to describe a batch of images with an
    LLM.
2.  **Stage 2 (ML)**: train a {maize} string-kernel SVM (`svm_string()`)
    on those descriptions to predict a downstream label.

The string kernel compares texts by shared substrings, so similar
descriptions land near each other — a natural fit for LLM-generated
text.

### Stage 1: describe the images

We’ll classify each image and keep the free-text description. Here we
use the bundled test image twice for illustration; in practice, point
`image_files` at a labeled folder of images.

``` r

image_files <- c(
  system.file("img/test_img.jpg", package = "kuzco")
)

descriptions <- purrr::map_chr(
  image_files,
  ~ kuzco::llm_image_classification(
    image = .x,
    llm_model = "qwen2.5vl",
    backend = "ellmer"
  )$image_description
)

# pair each description with a downstream label you care about
# (e.g. "keep" vs "discard", a product category, a moderation flag)
labeled <- tibble::tibble(
  text = descriptions,
  label = factor(c("keep"))  # replace with your real labels
)

labeled
```

### Stage 2: train the string SVM

`maize::svm_string()` fits a support vector machine with a string kernel
directly on text — no embeddings, no tokenization pipeline.

``` r

set.seed(123)

string_spec <- maize::svm_string(
  mode = "classification",
  cost = 1
) |>
  parsnip::set_engine("kernlab")

# with a real labeled set you would split, resample, and tune here;
# this shows the fit interface
string_fit <- string_spec |>
  parsnip::fit(label ~ text, data = labeled)

string_fit
```

### Predict on new images

New image comes in? Run it through the same two stages: describe with
kuzco, classify the description with the fitted SVM.

``` r

new_description <- kuzco::llm_image_classification(
  image = system.file("img/test_img.jpg", package = "kuzco"),
  llm_model = "qwen2.5vl",
  backend = "ellmer"
)$image_description

predict(
  string_fit,
  new_data = tibble::tibble(text = new_description)
)
```

### Why two stages?

- **Cost**: the LLM runs once per image at featurization time; the SVM
  predicts for free forever after.
- **Calibration**: SVM probabilities and resampling give you honest
  uncertainty; raw LLM labels don’t.
- **Control**: the second stage is a regular parsnip model, so the whole
  tidymodels tuning machinery (dials, workflows, yardstick) applies
  unchanged.
- **Auditability**: when the pipeline errs, you can read the description
  that caused it.
