#' list prompts
#' @description
#' list prompts installed with kuzco
#'
#' @export
#' @returns a list of prompts stored within kuzco
#' @examples
#' list_prompts()
#'
list_prompts <- \() {
	list.files(system.file("prompts", package = "kuzco"))
}

#' edit prompt
#' @description
#' edit a listed prompt installed with kuzco
#' @param prompt a prompt from list_prompts()
#' @returns a prompt markdown file to edit
#' @export
#' @examples
#' \dontrun{
#' edit_prompt("system-prompt-alt-text.md")
#'}
edit_prompt <- \(prompt) {
	utils::file.edit(system.file("prompts", prompt, package = "kuzco"))
}
