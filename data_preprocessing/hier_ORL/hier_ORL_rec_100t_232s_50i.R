#install and load packages
install.packages(c('R2jags', 'ggpubr', 'extraDistr', 'truncnorm', 'tidyverse', 'parallel', 'pacman'))
pacman::p_load(R2jags, parallel, ggpubr, extraDistr, truncnorm, tidyverse)

set.seed(1982)

getwd()
setwd("/work/exam/dm_exam/data_preprocessing/hier_ORL")
getwd()

# defining a function for calculating the maximum of the posterior density (not exactly the same as the mode)
MPD <- function(x) {
  density(x)$x[which(density(x)$y==max(density(x)$y))]
}

#------ create task environment -------------------
# NB! mod(ntrials, nstruct) (aka. ntrials %% nstruct) must be 0
ntrials <- 100 # total number of trials in our payoff structure
nstruct <- 10 # size of our subdivisions for pseudorandomization
freq <- 0.5 # probability of our frequent losses (we have losses half of the time)
infreq <- 0.1 # probability of our infrequent losses (we have losses 1/10th of the time)
bad_r <- 100 # "bad" winnings
bad_freq_l <- -250 # "bad" frequent loss
bad_infreq_l <- -1250 # "bad" infrequent loss
good_r <- 50 # "good" winnings
good_freq_l <- -50 # "good" frequent loss
good_infreq_l <- -250 # "good" infrequent loss

# Bad frequent
A_R <- rep(bad_r, nstruct) # we win on every trials
A_L <- c(rep(bad_freq_l, nstruct*freq),rep(0,nstruct*(1-freq))) # we have losses half of the time

# Bad infrequent
B_R <- rep(bad_r, nstruct)
B_L <- c(rep(bad_infreq_l, nstruct*infreq),rep(0,nstruct*(1-infreq))) # we have losses 1/10th of the time

# Good frequent
C_R <- rep(good_r, nstruct)
C_L <- c(rep(good_freq_l, nstruct*freq),rep(0,nstruct*(1-freq)))

# Good infrequent
D_R <- rep(good_r, nstruct)
D_L <- c(rep(good_infreq_l, nstruct*infreq),rep(0,nstruct*(1-infreq)))

# create the pseudorandomized full payoff structure
A <- array(NA,ntrials) # setting up and empty array to be filled
B <- array(NA,ntrials)
C <- array(NA,ntrials)
D <- array(NA,ntrials)
for (i in 1:(ntrials/nstruct)) {
  A[(1+(i-1)*nstruct):(i*nstruct)] <- (A_R + sample(A_L)) # randomly shuffling the loss-array for every ten trials (and adding those losses to the winnings)
  B[(1+(i-1)*nstruct):(i*nstruct)] <- (B_R + sample(B_L))
  C[(1+(i-1)*nstruct):(i*nstruct)] <- (C_R + sample(C_L))
  D[(1+(i-1)*nstruct):(i*nstruct)] <- (D_R + sample(D_L))
}

# "less generic" code
# A <- c()
# B <- c()
# C <- c()
# D <- c()
# for (i in 1:10) {
#   A <- (append(A,A_R + sample(A_L)))
#   B <- (append(B,B_R + sample(B_L)))
#   C <- (append(C,C_R + sample(C_L)))
#   D <- (append(D,D_R + sample(D_L)))
# }

payoff <- cbind(A,B,C,D)/100 # combining all four decks as columns with each 100 trials - dividing our payoffs by 100 to make the numbers a bit easier to work with

# let's look at the payoff
colSums(payoff) # the two bad decks should sum to -25 (i.e. -2500), and the two good ones to 25 (i.e. 2500)

#################
# cut the last 5 rows of payoff 
# payoff <- as_tibble(payoff)
# payoff <- payoff %>% slice(1:95)
# payoff <- data.matrix(payoff)

#############

###--------------Run full parameter recovery -------------
niterations <- 50 # fewer because it takes too long
nsubs <- 232 # mimicking the data structure from Ahn et al.
ntrials_all <- rep(100, 232) # all 48 simulated subs have 100 trials each
ntrials <- 100

# mu
true_mu_a_rew <- array(NA,c(niterations))
true_mu_a_pun <- array(NA,c(niterations))
true_mu_K <- array(NA,c(niterations))
true_mu_theta <- array(NA,c(niterations))
true_mu_omega_f <- array(NA,c(niterations))
true_mu_omega_p <- array(NA,c(niterations))

infer_mu_a_rew <- array(NA,c(niterations))
infer_mu_a_pun <- array(NA,c(niterations))
infer_mu_K <- array(NA,c(niterations))
infer_mu_theta <- array(NA,c(niterations))
infer_mu_omega_f <- array(NA,c(niterations))
infer_mu_omega_p <- array(NA,c(niterations))

# sigma (SD for R) / lambda (precision for JAGS)
true_lambda_a_rew <- array(NA,c(niterations))
true_lambda_a_pun <- array(NA,c(niterations))
true_lambda_K <- array(NA,c(niterations))
true_lambda_theta <- array(NA,c(niterations))
true_lambda_omega_f <- array(NA,c(niterations))
true_lambda_omega_p <- array(NA,c(niterations))

infer_lambda_a_rew <- array(NA,c(niterations))
infer_lambda_a_pun <- array(NA,c(niterations))
infer_lambda_K <- array(NA,c(niterations))
infer_lambda_theta <- array(NA,c(niterations))
infer_lambda_omega_f <- array(NA,c(niterations))
infer_lambda_omega_p <- array(NA,c(niterations))

start_time = Sys.time()
for (i in 1:niterations) {
  ntrials <- ntrials_all
  
  # let's see how robust the model is. Does it recover all sorts of values?
  mu_a_rew <- runif(1,0,1)
  mu_a_pun <- runif(1,0,1)
  mu_K <- runif(1,0,2)
  mu_theta <- runif(1,.2,2) # could also just be a set value (e.g. 1) to simplify the model a bit
  mu_omega_f <- runif(1,-2,2)
  mu_omega_p <- runif(1,-2,2)
  
  sigma_a_rew <- runif(1,0,0.1)
  sigma_a_pun <- runif(1,0,0.1)
  sigma_K <- runif(1,0,0.2)
  sigma_theta <- runif(1,0,0.2) # if theta is just a set value (e.g. 1), then this isn't relevant anymore
  sigma_omega_f <- runif(1,0,0.4)
  sigma_omega_p <- runif(1,0,0.4)
  
  # sigma_a_rew <- runif(1,0,.5)
  # sigma_a_pun <- runif(1,0,.5)
  # sigma_K <- runif(1,0,.5)
  # sigma_theta <- runif(1,0,.5)
  # sigma_omega_f <- runif(1,0,.5)
  # sigma_omega_p <- runif(1,0,.5)
  
  source('hier_ORL_sim.R')
  ORL_sims <- hier_ORL_sim(payoff,nsubs,ntrials,mu_a_rew,mu_a_pun,
                           mu_K,mu_theta,mu_omega_f,mu_omega_p,
                           sigma_a_rew,sigma_a_pun,sigma_K,sigma_theta,
                           sigma_omega_f,sigma_omega_p)
  
  x <- ORL_sims$x
  X <- ORL_sims$X
  
  # set up jags and run jags model
  data <- list("x","X","ntrials","nsubs") 
  params<-c("mu_a_rew","mu_a_pun",
            "mu_K","mu_theta","mu_omega_f","mu_omega_p",
            "lambda_a_rew","lambda_a_pun","lambda_K","lambda_theta",
            "lambda_omega_f","lambda_omega_p")
  samples <- jags.parallel(data, inits=NULL, params,
                           model.file ="hier_ORL.txt", n.chains=3, 
                           n.iter=5000, n.burnin=1000, n.thin=1, n.cluster=4)
  
  # mu
  true_mu_a_rew[i] <- mu_a_rew
  true_mu_a_pun[i] <- mu_a_pun
  true_mu_K[i] <- mu_K
  true_mu_theta[i] <- mu_theta
  true_mu_omega_f[i] <- mu_omega_f
  true_mu_omega_p[i] <- mu_omega_p
  
  # find maximum a posteriori
  Y <- samples$BUGSoutput$sims.list
  infer_mu_a_rew[i] <- MPD(Y$mu_a_rew)
  infer_mu_a_pun[i] <- MPD(Y$mu_a_pun)
  infer_mu_K[i] <- MPD(Y$mu_K)
  infer_mu_theta[i] <- MPD(Y$mu_theta)
  infer_mu_omega_f[i] <- MPD(Y$mu_omega_f)
  infer_mu_omega_p[i] <- MPD(Y$mu_omega_p)
  
  # lambda
  true_lambda_a_rew[i] <- sigma_a_rew
  true_lambda_a_pun[i] <- sigma_a_pun
  true_lambda_K[i] <- sigma_K
  true_lambda_theta[i] <- sigma_theta
  true_lambda_omega_f[i] <- sigma_omega_f
  true_lambda_omega_p[i] <- sigma_omega_p
  
  # find maximum a posteriori
  infer_lambda_a_rew[i] <- MPD(Y$lambda_a_rew)
  infer_lambda_a_pun[i] <- MPD(Y$lambda_a_pun)
  infer_lambda_K[i] <- MPD(Y$lambda_K)
  infer_lambda_theta[i] <- MPD(Y$lambda_theta)
  infer_lambda_omega_f[i] <- MPD(Y$lambda_omega_f)
  infer_lambda_omega_p[i] <- MPD(Y$lambda_omega_p)
  
  print(i)
  
}

end_time = Sys.time()
end_time - start_time

# saving jags output
# true mu
saveRDS(true_mu_a_rew, "jags_output_100t_232s_50i/true_mu_a_rew.rds")
saveRDS(true_mu_a_pun, "jags_output_100t_232s_50i/true_mu_a_pun.rds")
saveRDS(true_mu_K, "jags_output_100t_232s_50i/true_mu_K.rds")
saveRDS(true_mu_theta, "jags_output_100t_232s_50i/true_mu_theta.rds")
saveRDS(true_mu_omega_f, "jags_output_100t_232s_50i/true_mu_omega_f.rds")
saveRDS(true_mu_omega_p, "jags_output_100t_232s_50i/true_mu_omega_p.rds")
#infer mu
saveRDS(infer_mu_a_rew, "jags_output_100t_232s_50i/infer_mu_a_rew.rds")
saveRDS(infer_mu_a_pun, "jags_output_100t_232s_50i/infer_mu_a_pun.rds")
saveRDS(infer_mu_K, "jags_output_100t_232s_50i/infer_mu_K.rds")
saveRDS(infer_mu_theta, "jags_output_100t_232s_50i/infer_mu_theta.rds")
saveRDS(infer_mu_omega_f, "jags_output_100t_232s_50i/infer_mu_omega_f.rds")
saveRDS(infer_mu_omega_p, "jags_output_100t_232s_50i/infer_mu_omega_p.rds")
#true lambda
saveRDS(true_lambda_a_rew, "jags_output_100t_232s_50i/true_lambda_a_rew.rds")
saveRDS(true_lambda_a_pun, "jags_output_100t_232s_50i/true_lambda_a_pun.rds")
saveRDS(true_lambda_K, "jags_output_100t_232s_50i/true_lambda_K.rds")
saveRDS(true_lambda_theta, "jags_output_100t_232s_50i/true_lambda_theta.rds")
saveRDS(true_lambda_omega_f, "jags_output_100t_232s_50i/true_lambda_omega_f.rds")
saveRDS(true_lambda_omega_p, "jags_output_100t_232s_50i/true_lambda_omega_p.rds")
#infer lambda
saveRDS(infer_lambda_a_rew, "jags_output_100t_232s_50i/infer_lambda_a_rew.rds")
saveRDS(infer_lambda_a_pun, "jags_output_100t_232s_50i/infer_lambda_a_pun.rds")
saveRDS(infer_lambda_K, "jags_output_100t_232s_50i/infer_lambda_K.rds")
saveRDS(infer_lambda_theta, "jags_output_100t_232s_50i/infer_lambda_theta.rds")
saveRDS(infer_lambda_omega_f, "jags_output_100t_232s_50i/infer_lambda_omega_f.rds")
saveRDS(infer_lambda_omega_p, "jags_output_100t_232s_50i/infer_lambda_omega_p.rds")

##
# let's look at some scatter plots
# plotting code courtesy of Lasse
source('../../PVL/PVL_recovery/recov_plot.R')
pl1 <- recov_plot(true_mu_a_rew, infer_mu_a_rew, c("true mu_a_rew", "infer mu_a_rew"), 'smoothed linear fit')
pl2 <- recov_plot(true_mu_a_pun, infer_mu_a_pun, c("true mu_a_pun", "infer mu_a_pun"), 'smoothed linear fit')
pl3 <- recov_plot(true_mu_K, infer_mu_K, c("true mu_K", "infer mu_K"), 'smoothed linear fit')
pl4 <- recov_plot(true_mu_theta, infer_mu_theta, c("true mu_theta", "infer mu_theta"), 'smoothed linear fit')
pl5 <- recov_plot(true_mu_omega_f, infer_mu_omega_f, c("true mu_omega_f", "infer mu_omega_f"), 'smoothed linear fit')
pl6 <- recov_plot(true_mu_omega_p, infer_mu_omega_p, c("true mu_omega_p", "infer mu_omega_p"), 'smoothed linear fit')
ggarrange(pl1, pl2, pl3, pl4, pl5, pl6)
ggsave("jags_output_100t_232s_50i/hier_ORL_rec_100t_232s_50i_mu.png", width = 2000, height = 1150, units = 'px', dpi = 150) ##### CHANGE HERE
getwd()

pl1 <- recov_plot(true_lambda_a_rew, infer_lambda_a_rew, c("true lambda_a_rew", "infer lambda_a_rew"), 'smoothed linear fit')
pl2 <- recov_plot(true_lambda_a_pun, infer_lambda_a_pun, c("true lambda_a_pun", "infer lambda_a_pun"), 'smoothed linear fit')
pl3 <- recov_plot(true_lambda_K, infer_lambda_K, c("true lambda_K", "infer lambda_K"), 'smoothed linear fit')
pl4 <- recov_plot(true_lambda_theta, infer_lambda_theta, c("true lambda_theta", "infer lambda_theta"), 'smoothed linear fit')
pl5 <- recov_plot(true_lambda_omega_f, infer_lambda_omega_f, c("true lambda_omega_f", "infer lambda_omega_f"), 'smoothed linear fit')
pl6 <- recov_plot(true_lambda_omega_p, infer_lambda_omega_p, c("true lambda_omega_p", "infer lambda_omega_p"), 'smoothed linear fit')
ggarrange(pl1, pl2, pl3, pl4, pl5, pl6)
ggsave("jags_output_100t_232s_50i/hier_ORL_rec_100t_232s_50i_lambda.png", width = 2000, height = 1150, units = 'px', dpi = 150) ##### CHANGE HERE

#traceplot(samples, mfrow=c(7,2))

