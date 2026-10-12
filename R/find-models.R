#' Find GGUF models on this machine
#'
#' @description
#' Scans the machine for GGUF model files, which can be loaded directly by
#' `llama.cpp` (`./llama-server -m /path/to/model.gguf`). GGUF files are
#' identified by their magic bytes, so files without a `.gguf` extension
#' (such as Ollama's blob store) are found too.
#'
#' By default the scan covers common model locations:
#' * the Ollama blob store (`~/.ollama/models/blobs/`, or `%USERPROFILE%\\.ollama\\models\\blobs\\`
#'   on Windows, or `$OLLAMA_MODELS/blobs` when that variable is set),
#' * the `llama.cpp` download cache (`~/.cache/llama.cpp/`),
#' * `~/models/`,
#' * any extra directories passed via `dirs`.
#'
#' With `include_ollama = TRUE` (default), models in the local Ollama library
#' are also resolved to their underlying GGUF blob paths by reading Ollama's
#' manifest files, so every row has a directly usable `path`. This works from
#' the filesystem alone; the Ollama server does not need to be running.
#'
#' @param dirs additional directories to scan (in addition to the defaults).
#'   Non-existent directories are silently skipped.
#' @param include_ollama resolve Ollama library models to GGUF paths as well.
#'   Defaults to `TRUE`.
#' @param recursive scan directories recursively. Defaults to `TRUE`.
#'
#' @returns a data frame with columns `name`, `path`, `size_mb`, `modified`,
#'   and `source` (`"disk"` for files found by scanning, `"ollama"` for
#'   models resolved from the Ollama library). Empty data frame when nothing
#'   is found.
#' @export
#' @examples
#' \donttest{
#' find_gguf_models()
#' }
find_gguf_models <- function(dirs = NULL, include_ollama = TRUE, recursive = TRUE) {
  disk <- .scan_gguf_dirs(.default_gguf_dirs(dirs), recursive = recursive)

  ollama <- if (isTRUE(include_ollama)) {
    .ollama_gguf_models()
  } else {
    .empty_gguf_df()
  }

  res <- rbind(disk, ollama)

  # the ollama blob store is also a default scan dir: drop disk rows whose
  # path was already resolved from an ollama manifest (keep the named row)
  dup <- res$source == "disk" & res$path %in% res$path[res$source == "ollama"]
  res <- res[!dup, , drop = FALSE]

  res[order(res$source, res$name), , drop = FALSE]
}

#' Default directories to scan for GGUF files
#' @noRd
.default_gguf_dirs <- function(dirs = NULL) {
  home <- Sys.getenv("HOME", "~")
  if (.is_windows()) {
    home <- Sys.getenv("USERPROFILE", home)
  }

  ollama_models <- Sys.getenv("OLLAMA_MODELS", "")
  if (!nzchar(ollama_models)) {
    ollama_models <- file.path(home, ".ollama", "models")
  }

  candidates <- c(
    file.path(ollama_models, "blobs"),
    file.path(home, ".cache", "llama.cpp"),
    file.path(home, "models"),
    dirs
  )

  unique(candidates[dir.exists(candidates)])
}

#' Scan directories for GGUF files (magic bytes "GGUF")
#' @noRd
.scan_gguf_dirs <- function(dirs, recursive = TRUE) {
  if (length(dirs) == 0L) {
    return(.empty_gguf_df())
  }

  files <- unlist(
    lapply(dirs, function(d) {
      list.files(d, full.names = TRUE, recursive = recursive, all.files = FALSE)
    }),
    use.names = FALSE
  )
  files <- files[!dir.exists(files)]
  is_gguf <- vapply(files, .is_gguf_file, logical(1), USE.NAMES = FALSE)
  files <- files[is_gguf]

  if (length(files) == 0L) {
    return(.empty_gguf_df())
  }

  info <- file.info(files)
  data.frame(
    name = basename(files),
    path = files,
    size_mb = round(info$size / 1024^2, 1),
    modified = info$mtime,
    source = "disk",
    stringsAsFactors = FALSE,
    row.names = NULL
  )
}

#' Check GGUF magic bytes (first 4 bytes are "GGUF")
#' @noRd
.is_gguf_file <- function(path) {
  con <- tryCatch(
    suppressWarnings(file(path, "rb")),
    error = function(e) NULL
  )
  if (is.null(con)) {
    return(FALSE)
  }
  on.exit(tryCatch(close(con), error = function(e) NULL), add = TRUE)
  magic <- tryCatch(readBin(con, "raw", n = 4L), error = function(e) raw(0))
  length(magic) == 4L && all(magic == charToRaw("GGUF"))
}

#' Resolve Ollama library models to GGUF blob paths via manifest files
#' @noRd
.ollama_gguf_models <- function() {
  manifests <- .ollama_path("manifests")
  blobs <- .ollama_path("blobs")
  if (!dir.exists(manifests) || !dir.exists(blobs)) {
    return(.empty_gguf_df())
  }

  # manifests/registry.ollama.ai/library/<model>/<tag>
  manifest_files <- list.files(manifests, full.names = TRUE, recursive = TRUE)
  # keep only files two levels below a namespace dir (model/tag)
  rows <- lapply(manifest_files, function(mf) {
    rel <- sub(paste0("^", manifests, "/?"), "", mf)
    parts <- strsplit(rel, "/")[[1]]
    if (length(parts) < 3L) {
      return(NULL)
    }
    model <- paste(utils::tail(parts, 2L), collapse = ":")
    manifest <- tryCatch(
      jsonlite::fromJSON(mf, simplifyVector = FALSE),
      error = function(e) NULL
    )
    if (is.null(manifest) || is.null(manifest$layers)) {
      return(NULL)
    }
    weight_layer <- Filter(
      function(l) identical(l$mediaType, "application/vnd.ollama.image.model"),
      manifest$layers
    )
    if (length(weight_layer) == 0L) {
      return(NULL)
    }
    digest <- sub("^sha256:", "sha256-", weight_layer[[1]]$digest)
    blob_path <- file.path(blobs, digest)
    if (!file.exists(blob_path) || !.is_gguf_file(blob_path)) {
      return(NULL)
    }
    info <- file.info(blob_path)
    data.frame(
      name = model,
      path = blob_path,
      size_mb = round(info$size / 1024^2, 1),
      modified = info$mtime,
      source = "ollama",
      stringsAsFactors = FALSE
    )
  })
  rows <- Filter(Negate(is.null), rows)
  if (length(rows) == 0L) {
    return(.empty_gguf_df())
  }
  do.call(rbind, rows)
}

#' Ollama models/blobs/manifests base path for an entry
#' @noRd
.ollama_path <- function(entry) {
  home <- Sys.getenv("HOME", "~")
  if (.is_windows()) {
    home <- Sys.getenv("USERPROFILE", home)
  }
  base <- Sys.getenv("OLLAMA_MODELS", "")
  if (!nzchar(base)) {
    base <- file.path(home, ".ollama", "models")
  }
  file.path(base, entry)
}

#' @noRd
.is_windows <- function() {
  identical(.Platform$OS.type, "windows")
}

#' Empty GGUF result data frame (consistent columns)
#' @noRd
.empty_gguf_df <- function() {
  data.frame(
    name = character(0),
    path = character(0),
    size_mb = numeric(0),
    modified = as.POSIXct(character(0)),
    source = character(0),
    stringsAsFactors = FALSE
  )
}
