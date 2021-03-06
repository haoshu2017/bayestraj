#' traj
#'
#' Estimate the single trajectory model using a Gibbs Sampler
#'
#' @param X: Matrix, design matrix. 1st column should be the id.
#' @param y: Vector, outcomes
#' @param K: Integer, number of latent classes 
#' @param z: Matrix, K x dim(X)[2] indicator matrix indicating which variables to include in each group.
#' @param iterations: Integer, number of MCMC iterations
#' @param W: Matrix, design matrix for group membership. Use this if you want to directly model the group membership probabilities using covariates
#' @param thin: Integer, store every 'thin' iteration
#' @param dispIter: Integer, frequency of printing the iteration number
#' @param ll: Boolean, Set to TRUE to display the maximum log-likelihood over all the draws.
#' @param lambda: Numeric, prior for beta coefficients are N(0,lambda*I) where I is identity matrix
#'
#' @importFrom MCMCpack rdirichlet riwish rinvgamma
#' @importFrom mvtnorm rmvnorm
#'
#' @export

traj = function(X,y,K,z,iterations,W=matrix(),thin=1,dispIter=10,ll=FALSE,lambda=100) {

#extract ids from design matrices
id = X[,1]

#relabel id's to begin at 1
uniqueIDs = sort(unique(c(id)))
id = match(id,uniqueIDs)

#number of units
N = length(unique(id))

#length of data
N_ = length(id)

#replace id with intercept column
X[,1]=1

#dimensions of theta
d = dim(X)[2]

#number of group membership covariates
P = dim(W)[2]

#hyperparameters
alpha = rep(1,K)
nu0 = 0.001
sigma0 = 1
Sigma = list()
for (j in 1:K)
  Sigma[[j]] = lambda*diag(sum(z[j,])) #Beta prior. Scale identity matrix by lambda coefficient to make non-informative

#initialize parameters
c = sample(c(1:K),N,replace=TRUE) #randomly assign groups
pi = as.vector(rdirichlet(1,alpha)) #randomly draw group membership probabilities
sigma = 1 #arbitrarily set to 1
beta=matrix(0,nrow=K,ncol=d,byrow=TRUE) #initialize to 0
mu = list() #set to 0
for (j in 1:K)
  mu[[j]] = rep(0,sum(z[j,]))
#If modeling group membership probabilities, zeta are the logit coefficients
zeta=matrix(0,nrow=P,ncol=K,byrow=TRUE) #set to 0

#initialize storage
cStore = matrix(nrow=iterations/thin, ncol=N)
piStore = matrix(nrow=iterations/thin, ncol=K)
betaStore = list()
zetaStore = list()
for (j in 1:K) {
  betaStore[[j]] = matrix(nrow=iterations/thin, ncol=sum(z[j,]))
  zetaStore[[j]] = matrix(nrow=iterations/thin, ncol=P)
}
sigmaStore = rep(NA,iterations/thin)

maxll = -Inf

#MCMC
for (q in 1:iterations) {
  if (q %% dispIter == 0) {
    print(q)
  }

  if (P == 1) {
    #draw groups
    c = drawgroup(X,y,N,id,pi,beta,sigma,K)
    
    #reindex according to new groups
    index = c[id]
    
    #draw group/transition probabilities
    pi = drawpi(c, alpha, K)
  }
  else {
    #draw pi
    zeta = drawzeta(c,W,zeta,N,P,K)
    u = W %*% zeta
    pi = exp(u)/rowSums(exp(u))
    
    #draw group
    c = drawgroup(X,y,N,id,pi,beta,sigma,K)
    
    #reindex according to new groups
    index = c[id]
  }
  
  
  #draw beta
  for (j in 1:K) {
    beta[j,] = rep(0,d)
    beta[j,z[j,]==1] = drawbeta(X[index==j,z[j,]==1], y[index==j], sigma, mu[[j]], Sigma[[j]])
  }
  
  #draw variance
  sigma = drawsigma(X, y, beta, index, nu0, sigma0, N_)
  
  if (ll == TRUE) {
    ll.c = log_lik(X,y,pi,beta,sigma,id)
    maxll = max(maxll,ll.c)
  }
  
  #store results
  if (q %% thin == 0) {
    store = q/thin
    if (P == 1)
      piStore[store,] = pi
    else{
      for (j in 1:K) {
        zetaStore[[j]][store,] = zeta[,j]
      }
    }
    for (j in 1:K)
      betaStore[[j]][store,] = beta[j,z[j,]==1]
    cStore[store,] = c
    sigmaStore[store] = sigma
  }
}

if (ll == TRUE) {
  print(maxll)
}

#return draws
return(list(beta  = betaStore,
            c     = cStore,
            pi    = piStore,
            sigma = sigmaStore,
            zeta     = zetaStore))
}
