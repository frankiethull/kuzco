#' chat ellmer
#' @description
#' a minimal wrapper function to switch which provider is used for each llm_image* function
#' when ellmer backend is selected, ollamar only supports ollama
#'
#' @param provider a provider, such as "ollama", or "claude", or "github"
#'
chat_ellmer <- \(provider = "ollama"){

  # fmt: skip
  chat_providers <- list(
    # ~ LOCAL ~
    "ollama"           = ellmer::chat_ollama,
    # ~ CLOUD ~
    "anthropic"        = ellmer::chat_anthropic,
    "aws_bedrock"      = ellmer::chat_aws_bedrock,
    "azure"            = ellmer::chat_azure,
    "azure_openai"     = ellmer::chat_azure_openai,
    "bedrock"          = ellmer::chat_bedrock,
    "claude"           = ellmer::chat_claude,
    "cloudfare"        = ellmer::chat_cloudflare,
    "cortex"           = ellmer::chat_cortex,
    "databricks"       = ellmer::chat_databricks,
    "deepseek"         = ellmer::chat_deepseek,
    "gemini"           = ellmer::chat_gemini,
    "github"           = ellmer::chat_github,
    "google_gemini"    = ellmer::chat_google_gemini,
    "google_vertex"    = ellmer::chat_google_vertex,
    "groq"             = ellmer::chat_groq,
    "huggingface"      = ellmer::chat_huggingface,
    "mistral"          = ellmer::chat_mistral,
    "openai"           = ellmer::chat_openai,
    "openrouter"       = ellmer::chat_openrouter,
    "perplexity"       = ellmer::chat_perplexity,
    "portkey"          = ellmer::chat_portkey,
    "snowflake"        = ellmer::chat_snowflake,
    "vllm"             = ellmer::chat_vllm
  )

 chat_host <- chat_providers[[provider]]

 return(chat_host)
}
