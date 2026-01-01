# chat ellmer helper (predates ellmer::chat)

a minimal wrapper function to switch which provider is used for each
llm_image\* function when ellmer backend is selected, ollamar only
supports ollama

## Usage

``` r
chat_ellmer(provider = "ollama")
```

## Arguments

- provider:

  a provider, such as "ollama", or "claude", or "github"

## Value

which ellmer function (provider) to use for kuzco llm_image\_\* when
backend is ellmer
