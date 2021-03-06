% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/peaklist_browser.R
\name{peaklist_browser_prep}
\alias{peaklist_browser_prep}
\title{Prepare peaklist for interactive browser}
\usage{
peaklist_browser_prep(peaklist, collapse_col = "features",
  modal_col = "anno")
}
\arguments{
\item{peaklist}{A \code{\link{tibble}} peaklist with nested columns for pcgroup and the feauture annotations}

\item{collapse_col}{A string. The first nesting for pcgroups.}

\item{modal_col}{A string. The second nesting for feature annotations.}
}
\value{
A \code{\link{tibble}} containing the same columns as the input table but with extra hmtl.
}
\description{
This function adds some html that is needed for the interactive browser.
It adds a plus button to open the first nesting (collapse_col) and a View button to view the second nesting (modal_col).
}
