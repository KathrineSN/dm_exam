install.packages("pacman")
library('pacman')
pacman::p_load(hesim, extraDistr, R2jags, parallel, ggpubr, tidyverse, R2jags)
# setting seed
set.seed(1982)

# change to your path 
getwd()
setwd("/work/exam/dm_exam/PVL/PVL_recovery")
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

# "less generic" code
A <- c()
B <- c()
C <- c()
D <- c()
for (i in 1:10) {
  A <- (append(A,A_R + sample(A_L)))
  B <- (append(B,B_R + sample(B_L)))
  C <- (append(C,C_R + sample(C_L)))
  D <- (append(D,D_R + sample(D_L)))
}

payoff <- cbind(A,B,C,D)/100 # combining all four decks as columns with each 100 trials - dividing our payoffs by 100 to make the numbers a bit easier to work with

# let's look at the payoff
colSums(payoff) # the two bad decks should sum to -25 (i.e. -2500), and the two good ones to 25 (i.e. 2500)


###--------------Run full parameter recovery -------------
niterations <- 50 # fewer because it takes too long

true_w <- array(NA,c(niterations))
true_A <- array(NA,c(niterations))
true_a <- array(NA,c(niterations))
true_theta <- array(NA,c(niterations))

infer_w <- array(NA,c(niterations))
infer_A <- array(NA,c(niterations))
infer_a <- array(NA,c(niterations))
infer_theta <- array(NA,c(niterations))


source("../PVL.R")


start_time = Sys.time()

for (i in 1:niterations) {
  
  # let's see how robust the model is. Does it recover all sorts of values?
  w <- runif(1,.5,2.5)
  A <- runif(1,0,1)
  a <- runif(1,0,1)
  theta <- runif(1,0,5) 
  
  PVL_sims <- PVL(payoff,ntrials,w,A,a,theta)
  
  x <- PVL_sims$x
  X <- PVL_sims$X
  
  # set up jags and run jags model
  data <- list("x","X","ntrials") 
  params<-c("w","A","a","theta")
  samples <- jags.parallel(data, inits=NULL, params,
                           model.file ="../PVL.txt", n.chains=3, 
                           n.iter=5000, n.burnin=1000, n.thin=1, n.cluster=64)
  
  
  true_w[i] <- w
  true_A[i] <- A
  true_a[i] <- a
  true_theta[i] <- theta
  
  # find maximum a posteriori
  Y <- samples$BUGSoutput$sims.list
  infer_w[i] <- MPD(Y$w)
  infer_A[i] <- MPD(Y$A)
  infer_a[i] <- MPD(Y$a)
  infer_theta[i] <- MPD(Y$theta)
  
  print(i)
  
}

end_time = Sys.time()
end_time - start_time


# save infer og true values - arrays (list? )
saveRDS(infer_A, file = "jags_output_100t_50i/infer_A_risk.rds")
saveRDS(infer_a, file = "jags_output_100t_50i/infer_alpha.rds")
saveRDS(infer_w, file = "jags_output_100t_50i/infer_w.rds")
saveRDS(infer_theta, file = "jags_output_100t_50i/infer_theta.rds")

saveRDS(true_A, file = "jags_output_100t_50i/true_A_risk.rds")
saveRDS(true_a, file = "jags_output_100t_50i/true_alpha.rds")
saveRDS(true_w, file = "jags_output_100t_50i/true_w.rds")
saveRDS(true_theta, file = "jags_output_100t_50i/true_theta.rds")


source('recov_plot.R')
pl1 <- recov_plot(true_w, infer_w, c("true w", "infer w"), 'smoothed linear fit')
pl2 <- recov_plot(true_A, infer_A, c("true A", "infer A"), 'smoothed linear fit')
pl3 <- recov_plot(true_a, infer_a, c("true a", "infer a"), 'smoothed linear fit')
pl4 <- recov_plot(true_theta, infer_theta, c("true theta", "infer theta"), 'smoothed linear fit')
ggarrange(pl1, pl2, pl3, pl4)

ggsave("jags_output_100t_50i/PVL_rec_100t_232_50i_all_params.png", width = 2000, height = 1150, units = 'px', dpi = 150)

ggsave("jags_output_100t_50i/PVL_rec_100t_232_50i_w.png",pl1, width = 2000, height = 1150, units = 'px', dpi = 150)
ggsave("jags_output_100t_50i/PVL_rec_100t_232_50i_A_risk.png",pl2, width = 2000, height = 1150, units = 'px', dpi = 150)
ggsave("jags_output_100t_50i/PVL_rec_100t_232_50i_alpha.png",pl3, width = 2000, height = 1150, units = 'px', dpi = 150)
ggsave("jags_output_100t_50i/PVL_rec_100t_232_50i_theta.png",pl4, width = 2000, height = 1150, units = 'px', dpi = 150)
