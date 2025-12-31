#' View Images quickly and easily
#'
#' @param image an image to view
#'
#' @returns a plot of the image in a Plots pane
#' @export
#' @examples
#' view_image(image = system.file("img/test_img.jpg", package = "kuzco"))
#'
view_image <- \(image = system.file("img/test_img.jpg", package = "kuzco")) {
	plot(imager::load.image(image), axes = FALSE)
}
