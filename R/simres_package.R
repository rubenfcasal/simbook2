# PENDIENTE:
#  -


#' simres: Simulation and resampling techniques
#'
#' Functions and datasets used in the books:
#' * [Simulacion Estadistica](https://rubenfcasal.github.io/simbook)
#' * [Tecnicas de Remuestreo](https://rubenfcasal.github.io/book_remuestreo)
#'
#' For more information visit <https://rubenfcasal.github.io/simres.html>.
#' @keywords simulation bootstrap Monte-Carlo
#' @name simres-package
#' @aliases simres
#' @docType package
#' @import graphics
#' @import stats
#' @importFrom utils flush.console
#' @importFrom grDevices dev.interactive devAskNewPage
#' @references
#' Cao R. y Fernández-Casal R. (2021). *[Técnicas de Remuestreo](https://rubenfcasal.github.io/book_remuestreo)*,  ([github](https://github.com/rubenfcasal/book_remuestreo)).
#'
#' Fernández-Casal R. y Cao R. (2022). *[Simulación Estadística](https://rubenfcasal.github.io/simbook)*, ([github](https://github.com/rubenfcasal/simbook)).
#'
NULL




if(getRversion() >= "2.15.1")
    utils::globalVariables(c(".rng"))

# #' UDC WoS Core Collection 2015 data
# #'
# #' The data set consists of 856 registros vinculados a la UDC por el campo Organización-Nombre preferido
# #' (Organization-Enhaced: OG = Universidade da Coruna)
# #' de los siguientes índices de la Web of Science Core Collection:
# #' \itemize{
# #'   \item{Science Citation Index Expanded (SCI-EXPANDED).}
# #'   \item{Social Sciences Citation Index (SSCI).}
# #'   \item{Arts & Humanities Citation Index (A&HCI).}
# #' }
# #' correspondientes al año 2015.
# #' @name wosdf
# #' @docType data
# #' @format A data frame with 856 observations on the following 62 variables:
# #' \describe{
# #'   \item{UT}{Access number.}
# #'   \item{PM}{Pub Med ID.}
# #' }
# #' @source Thomson Reuters' Web of Science: \cr
# #' \url{http://www.webofknowledge.com}.
# #' @keywords datasets
# # @examples
# # str(wosdf)
# NULL



#--------------------------------------------------------------------
.onAttach <- function(libname, pkgname){
  #--------------------------------------------------------------------
  #   pkg.info <- utils::packageDescription(pkgname, libname, fields = c("Title", "Version", "Date"))
  pkg.info <- drop( read.dcf( file = system.file("DESCRIPTION", package = "simres"),
                              fields = c("Title", "Version", "Date") ))
  packageStartupMessage(
    paste0(" simres: ", pkg.info["Title"], ",\n"),
    paste0(" version ", pkg.info["Version"], " (built on ", pkg.info["Date"], ").\n"),
    " Copyright (C) R. Fernandez-Casal 2022.\n",
    " Type `help(simres)` for an overview of the package or\n",
    " visit https://rubenfcasal.github.io/simres.\n")
}
