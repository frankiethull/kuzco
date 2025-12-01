# multilingual-support

``` r
library(kuzco)
test_img <- file.path(system.file(package = "kuzco"), "img/test_img.jpg") 
```

### multilingual support

Some models are capable of returning outputs in multiple languages. As a
result, it became necessary to include a language specification to
ensure certain models responded in English. Once this step was in place,
switching the output language for specific computer vision tasks became
straightforward & easy to implement.

#### English Results

``` r
llm_image_classification(
  llm_model = "qwen2.5vl", 
  image = test_img, 
  backend = 'ellmer',
  provider = 'ollama',
  language = 'English'
  )
```

``` r
#>   image_classification primary_object secondary_object
#> 1  Portrait of a puppy          puppy                 
#>                                                                                                          image_description
#> 1 A close-up portrait of a puppy with black and white fur is the main subject, with a red plaid blanket in the background.
#>                                              image_colors image_proba_names
#> 1 ["#000000", "#FFFFFF", "#FF0000", "#0000FF", "#A52A2A"]                  
#>              image_proba_values
#> 1 [0.6, 0.15, 0.08, 0.07, 0.02]
```

#### Spanish Results

``` r
llm_image_classification(
  llm_model = "qwen2.5vl", 
  image = test_img, 
  backend = 'ellmer',
  provider = 'ollama',
  language = 'Spanish'
  )
```

``` r
#>   image_classification primary_object secondary_object
#> 1              perrito        perrito            pañal
#>                                                                                                                                                                                   image_description
#> 1 Un adorable perrito de color negro y blanco está echado en la cama. El perrito está mirando directamente a la cámara. Se ven texturas sutiles en el pelaje y un fondo de colcha de cuadros rojos.
#>                                    image_colors image_proba_names
#> 1 [#000000, #FFFFFF, #D60000, #FF0000, #0000FF]           perrito
#>       image_proba_values
#> 1 :[0.8,0.0,0.0,0.0,0.0]
```

#### German Results

``` r
llm_image_classification(
  llm_model = "qwen2.5vl", 
  image = test_img, 
  backend = 'ellmer',
  provider = 'ollama',
  language = 'German'
  )
```

``` r
#>   image_classification primary_object secondary_object
#> 1         Kinderbetten           Hund                 
#>                                                           image_description
#> 1 Der Bildinhalt zeigt einen Hund, der in der Nähe eines Kinderbetts liegt.
#>                                                  image_colors
#> 1 [⌘A87, ⌘AADE, ⌘545417, ⌘545417, ⌘AADE, ⌘A87, ⌘38182A, ⌘A87]
#>                                                       image_proba_names
#> 1 Hund, Bett, Tier, Kind, Hundebett, Tiergesicht, Fell, Haar, Tieraugen
#>                                            image_proba_values
#> 1 [0.42, 0.106, 0.08, 0.075, 0.045, 0.035, 0.034, 0.09, 0.07]
```

#### Chinese Results

``` r
llm_image_classification(
  llm_model = "qwen2.5vl", 
  image = test_img, 
  backend = 'ellmer',
  provider = 'ollama',
  language = 'Mandarin Chinese'
  )
```

``` r
#>   image_classification primary_object secondary_object
#> 1         pet portrait          puppy                 
#>                                                  image_description
#> 1 这是一张黑白相间的小狗的特写照片，它有着独特的眼睛和湿润的鼻子。
#>                                              image_colors image_proba_names
#> 1 ["#990000", "#0000FF", "#FFC0CB", "#000000", "#FFFFFF"]                 [
#>   image_proba_values
#> 1                  [
```
