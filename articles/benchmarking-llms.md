# benchmarking-llms

``` r

library(kuzco)
library(dplyr)
library(tidyr)
library(purrr)
```

## Benchmarking LLMs on the Same Image Task

Different vision models have different strengths, speeds, and price
tags. Before committing to one for a production workflow, it pays to run
them head-to-head on *your* images and *your* task. This vignette shows
a simple benchmarking pattern: same images, same prompt, several models,
one comparison table.

We’ll benchmark image classification across three setups: a local model
via Ollama, another local model, and a cloud model. Swap in whatever you
actually have pulled.

### The task and the images

We’ll classify a small set of images with
[`llm_image_classification()`](https://frankiethull.github.io/kuzco/reference/llm_image_classification.md).
Use the bundled test image to follow along, or point `image_files` at
your own folder.

``` r

image_files <- c(
  system.file("img/test_img.jpg", package = "kuzco")
  # add more: list.files("path/to/images", full.names = TRUE, pattern = "\\.(jpg|png)$")
)
```

### Define the contenders

Each contender is just a model + backend + provider combo. Keep the task
identical so the comparison is fair.

``` r

contenders <- tibble::tibble(
  label = c("qwen2.5vl (ollama)", "pixtral-12b (mistral)"),
  llm_model = c("qwen2.5vl", "pixtral-12b"),
  provider = c("ollama", "mistral")
)
```

### Run the benchmark

Loop over models x images, timing each call. We keep it sequential here
so timings are comparable; for real throughput numbers, see the parallel
patterns in the batch-image-processing vignette.

``` r

benchmark_one <- function(img, llm_model, provider, label) {
  tictoc::tic()
  res <- kuzco::llm_image_classification(
    image = img,
    llm_model = llm_model,
    provider = provider,
    backend = "ellmer"
  )
  elapsed <- tictoc::toc(quiet = TRUE)
  tibble::tibble(
    model = label,
    file = basename(img),
    image_classification = res$image_classification,
    primary_object = res$primary_object,
    seconds = unname(elapsed$toc - elapsed$tic)
  )
}

grid <- tidyr::expand_grid(img = image_files, contenders)

results <- purrr::pmap_dfr(
  grid,
  ~ benchmark_one(..1, ..2, ..3, ..4)
)

results
```

### Compare

With results in a tidy data frame, the comparison writes itself: do the
models agree on the classification? Which is fastest?

``` r

# agreement across models per image
results |>
  dplyr::select(file, model, image_classification) |>
  tidyr::pivot_wider(names_from = model, values_from = image_classification)

# speed comparison
results |>
  dplyr::group_by(model) |>
  dplyr::summarise(
    mean_seconds = mean(seconds),
    .groups = "drop"
  )
```

### What to look for

- **Agreement**: if two models disagree on your images, inspect the
  disagreements; they tell you where each model is weak.
- **Speed**: local models cost nothing per call but tie up your GPU;
  cloud models bill per token. Multiply mean seconds (or mean tokens,
  via `res` metadata) by your expected volume.
- **Stability**: run the grid twice. If a model’s answers wobble run to
  run, it may need a lower temperature or a tighter prompt (see the
  custom prompt vignette pattern via
  [`llm_image_custom()`](https://frankiethull.github.io/kuzco/reference/llm_image_custom.md)).

Once you’ve picked a winner, the batch-image-processing vignette shows
how to scale it up.
