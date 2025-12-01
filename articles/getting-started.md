# getting-started

``` r
library(kuzco)
```

## a typical workflow for a single image

#### define a path to an image

we have an image within kuzco to get started. But feel free to
substitute this image with any image of your choice.

``` r
my_image <- file.path(system.file(package = "kuzco", "img/test_img.jpg"))
```

#### view the input image

to make things easy, there is a new function in kuzco to see an image,
`view_image`.

``` r
my_image |>
  view_image()
```

![](getting-started_files/figure-html/unnamed-chunk-2-1.png)

#### apply computer vision

decide on an llm_image\_\* function to call:  
- llm_image_alt_text  
- llm_image_classification  
- llm_image_extract_text  
- llm_image_recognition  
- llm_image_sentiment  
- llm_image_custom

``` r
 llm_results <- 
   my_image |>
    llm_image_classification(llm_model = "qwen2.5vl")
```

#### view the output results

easily view the results from kuzco:

``` r
llm_results |>
  view_llm_results() 
```

## computer vision app

in addtion, kuzco has a shiny app implementation within the package. the
entire workflow above can be ran within a GUI like so:

``` r
kuzco_app()
```
