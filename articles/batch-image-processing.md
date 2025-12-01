# batch-image-processing

``` r
library(kuzco)
library(purrr)
library(mirai)
```

## Workflows for Many Images

There are many situations where you would need to analyze multiple
images. Or apply multiple functions to the same image.

Below we’ll use qwen2.5vl to handle the computer vision. qwen2.5vl is a
local model that does well with vision tasks. Maybe you are surveying
private information, sorting family photos, looping over CCTV cameras,
or trying to classify –whatever–, this vignette will help guide you
towards standardized computer vision workflows with other tidyverse
packages.

### applying a llm vision instruct to many images

Below we’ll showcase how to loop over the images in a dynamic routine
that can handle various images and leverage kuzco for classification
tasks.

I’m going to use purrr to apply the function to each image given the
map() function. We’ll also leverage purrr’s in_parallel and mirai to
setup multiple processes to do so.

``` r

mirai::daemons(20, .compute = "gpu")
llm_results <- purrr::map(image_files, 
                          purrr::in_parallel(\(img) kuzco::llm_image_classification(image = img)))
mirai::daemons(0)
```

### applying many llm vision instructs to an image

Other instances may require you to run multiple functions for the same
exact image. You’ll eventually run into a situation where you want to
classify but also understand the sentiment of an image. You may also
want to run multiple models. Below showcases a simple way to leverage
multiple functions for one image.

``` r
odin <- system.file("img/test_img.jpg", package = "kuzco")
kuzco::view_image(odin)
```

``` r

vision_workflow <- \(img){
  
  qwen_classifier <- kuzco::llm_image_classification(
    image = img,
    llm_model = "qwen2.5vl",
    backend = 'ellmer'
  )
  
  pixtral_classifier <- kuzco::llm_image_classification(
    image = img,
    llm_model = "pixtral-12b",
    provider = 'mistral',
    backend = 'ellmer'
  )
  
  pixtral_sentiment <- kuzco::llm_image_sentiment(
    image = img,
    llm_model = "pixtral-12b",
    provider = 'mistral',
    backend = "ellmer"
  )
}

mirai::daemons(20, .compute = "gpu")
llm_results <- purrr::map(odin, 
                          purrr::in_parallel(\(img) vision_workflow(image = img)))
mirai::daemons(0)
```

### applying many instructs to many images

You may have multiple images and need to examine the class, sentiment,
and look for a particular object within the image. This is showcased
below:

``` r
# Written by Mete Akcaoglu, edited by Frank Hull
# https://github.com/meteakca
# https://github.com/frankiethull/kuzco/issues/22#issuecomment-2957159732

process_image <- function(img_path) {
  # Classification
  classification <- llm_image_classification(
    llm_model = "qwen2.5vl",
    image = img_path,
    backend = 'ellmer'
  )
  
  # Object detection (e.g., detecting people)
  detection <- llm_image_recognition(
    llm_model = "qwen2.5vl",
    image = img_path,
    recognize_object = "dogs",
    backend = 'ellmer'
  )
  
  # Return as tibble
  tibble::tibble(
    file = img_path,
    image_classification = classification$image_classification,
    primary_object = classification$primary_object,
    secondary_object = classification$secondary_object,
    image_description = classification$image_description,
    image_colors = classification$image_colors,
    image_proba_names = paste(unlist(classification$image_proba_names), collapse = ", "),
    image_proba_values = paste(unlist(classification$image_proba_values), collapse = ", "),
    object_recognized = detection$object_recognized,
    object_count = detection$object_count,
    object_description = detection$object_description,
    object_location = detection$object_location
  )
}

tictoc::tic()
# Apply to all images and combine into one data frame
results_df <- map_dfr(image_files, process_image)
tictoc::toc()
```

Using parallelized processes via mirai & purrr’s new `in_parallel`
function.

``` r
tictoc::tic()
mirai::daemons(20, .compute = "gpu")
results_df <- map_dfr(image_files, 
                      purrr::in_parallel(\(img) process_image(img_path = jmg)))
mirai::daemons(0)
tictoc::toc()
```

Lastly, crossing images & functions using mirai may be of use.

``` r
tictoc::tic()
image_tasks <- list(classify  = kuzco::llm_image_classification,
                    sentiment = kuzco::llm_image_sentiment
                    )

grid <- expand.grid(files = image_files, tasks = image_tasks)

mirai::daemons(20, .compute = "gpu")
llm_results <- purrr::map2(as.character(grid$files), 
                           grid$tasks,
                           purrr::in_parallel(\(img, task) (task(image = img))))
mirai::daemons(0)
tictoc::toc()
```
