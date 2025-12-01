# cloud-providers

``` r
library(kuzco)
```

## local LLMs

kuzco was originally designed to work with local LLMs through “ollamar.”
These models are run using Ollama, which supports both “ollamar” and
“ellmer” backends. After installing Ollama on your system, you need to
pull a model to use locally.

1.  install Ollama
2.  pull a model (preferably a vision model) such as qwen2.5vl
3.  install kuzco
4.  run your AI enabled computer vision tasks

Ollama has served as the default provider for some time, check out
getting-started or the README for local examples. But kuzco can now also
utilize cloud-based providers.

## cloud LLMs

In recent months, kuzco has **attracted significant interest** from
organizations like
[R-Consortium](https://r-consortium.org/posts/exploring-kuzco-making-computer-vision-for-r-easily-accessible/)
and
[Posit](https://posit.co/blog/kuzco-computer-vision-with-llms-in-r/), as
well as from individuals curating lists of LLM and AI projects for R and
open-source communities. Many users have highlighted the need for
supporting non-local LLMs, whether due to hardware limitations or a
desire to leverage their API account with Mistral, Google, OpenAI, etc.
Given this feedback, adding non-local LLM functionality to kuzco is a
logical next step.

#### cloud example

Note that `provider = "ollama"` is the default, so this change does not
interfere with legacy processes. However, when the “ellmer” backend is
selected (which is also the default), you have the option to change the
provider as needed.

Note below showcases the use of the Mistral provider.

Since cloud providers require an API key, the API key can be set like
so:

``` r
# via base R:
Sys.setenv(MISTRAL_API_KEY = "the_api_key_via_the_provider")
# or usethis:
usethis::edit_r_environ()
```

This is the same exact environment variable that you would use via
ellmer.

If you’re unsure how to name your API key, refer to the documentation
for each provider in the
[ellmer](https://ellmer.tidyverse.org/reference/chat_anthropic.html#arg-api-key)
documentation for each chat provider.

Once you’ve set the environment variable, running computer vision tasks
becomes straightforward:

``` r
kuzco::llm_image_classification(provider = "mistral", llm_model = "pixtral-12b", image = test_img)
```

#### cloud provider dictionary

For your reference, here is a complete list of “providers” available in
kuzco, along with their corresponding ellmer “chat” functions:

| provider      | ellmer..function           |
|---------------|----------------------------|
| ollama        | ellmer::chat_ollama        |
| anthropic     | ellmer::chat_anthropic     |
| aws_bedrock   | ellmer::chat_aws_bedrock   |
| azure_openai  | ellmer::chat_azure_openai  |
| claude        | ellmer::chat_claude        |
| cloudfare     | ellmer::chat_cloudflare    |
| databricks    | ellmer::chat_databricks    |
| deepseek      | ellmer::chat_deepseek      |
| github        | ellmer::chat_github        |
| google_gemini | ellmer::chat_google_gemini |
| google_vertex | ellmer::chat_google_vertex |
| groq          | ellmer::chat_groq          |
| huggingface   | ellmer::chat_huggingface   |
| mistral       | ellmer::chat_mistral       |
| openai        | ellmer::chat_openai        |
| openrouter    | ellmer::chat_openrouter    |
| perplexity    | ellmer::chat_perplexity    |
| portkey       | ellmer::chat_portkey       |
| snowflake     | ellmer::chat_snowflake     |
| vllm          | ellmer::chat_vllm          |
