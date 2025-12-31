#' view llm results as a tidy great table
#'
#' @param llm_results results from one of the llm_image_* functions
#'
#' @returns a great table to view the results neatly
#' @export
#' @examples
#' \dontrun{
#' view_llm_results(llm_image_alt_text())
#' }
view_llm_results <- \(llm_results) {
	# create a long data.frame for the llm_results
	llm_results_long <-
		llm_results |>
		dplyr::mutate(
			dplyr::across(
				dplyr::everything(),
				as.character
			)
		) |>
		tidyr::pivot_longer(
			cols = dplyr::everything(),
			names_to = "Context",
			values_to = "LLM Response"
		)

	# TODO: what-if llm_results contains multiple results?
	# if, n = 1 ?
	# else, create a different table for n > 1 ?
	llm_results_long |>
		dplyr::mutate(
			Context = stringr::str_replace_all(Context, "_", " "),
			Context = stringr::str_to_title(Context)
		) |>
		gt::gt() |>
		gt::tab_header(
			title = gtExtras::add_text_img(
				"LLM Computer Vision ",
				url = "https://raw.githubusercontent.com/frankiethull/kuzco/main/man/figures/logo.png",
				height = 30
			)
		) |>
		gt::tab_options(
			column_labels.background.color = "#7FC8CE"
		) |>
		gt::tab_style(
			style = gt::cell_text(
				color = '#B1501D',
				weight = 'bold'
			),
			locations = gt::cells_title(groups = 'title')
		)
}
