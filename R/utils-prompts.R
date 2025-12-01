#' list prompts
#' @description
#' list prompts installed with kuzco
#'
#' @export
list_prompts <- \() {
	list.files(system.file("prompts", package = "kuzco"))
}

#' edit prompt
#' @description
#' edit a listed prompt installed with kuzco
#'
#' @export
edit_prompt <- \(prompt) {
	file.edit(system.file("prompts", prompt, package = "kuzco"))
}
