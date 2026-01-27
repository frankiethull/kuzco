.check_ollama_connection <- function() {
	ok <- tryCatch(
		ollamar::test_connection(logical = TRUE),
		error = function(e) FALSE
	)

	if (!isTRUE(ok)) {
		stop(
			"Could not connect to the local Ollama server via ollamar::test_connection().\n",
			"Make sure the Ollama server is running (default: http://localhost:11434).",
			call. = FALSE
		)
	}

	invisible(TRUE)
}
