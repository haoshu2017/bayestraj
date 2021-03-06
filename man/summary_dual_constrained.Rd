% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/summary.R
\name{summary_dual_constrained}
\alias{summary_dual_constrained}
\title{summary_dual_constrained}
\usage{
summary_dual_constrained(model, X1, X2, y1, y2, z, burn)
}
\arguments{
\item{model:}{List, output from dualtraj or dualtrajMS}

\item{X1:}{Matrix, design matrix for series 1. 1st column should be the id.}

\item{X2:}{Matrix, design matrix for series 2. 1st column should be the id.}

\item{y1:}{Vector, outcomes for series 1}

\item{y2:}{Vector, outcomes for series 2}

\item{z:}{Matrix, K x dim(X1)[2] indicator matrix indicating which variables to inlcude}

\item{burn:}{float, fraction of draws to keep for post burn-in period.}
}
\description{
Summarize output of dual trajectory model
}
