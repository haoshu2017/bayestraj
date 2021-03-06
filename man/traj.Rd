% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/traj.R
\name{traj}
\alias{traj}
\title{traj}
\usage{
traj(X, y, K, z, iterations, W = matrix(), thin = 1, dispIter = 10,
  ll = FALSE)
}
\arguments{
\item{X:}{Matrix, design matrix. 1st column should be the id.}

\item{y:}{Vector, outcomes}

\item{K:}{Integer, number of latent classes}

\item{z:}{Matrix, K x dim(X)[2] indicator matrix indicating which variables to include in each group.}

\item{iterations:}{Integer, number of MCMC iterations}

\item{W:}{Matrix, design matrix for group membership}

\item{thin:}{Integer, store every 'thin' iteration}

\item{dispIter:}{Integer, frequency of printing the iteration number}

\item{ll:}{Boolean, Set to TRUE to display the maximum log-likelihood over all the draws.}
}
\description{
Estimate the single trajectory model using a Gibbs Sampler
}
