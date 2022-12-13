PVL <- function(payoff,ntrials,w,A,a,theta) {
  
  # arrays to populate for simulation
  x <- array(0,c(ntrials))
  X <- array(0,c(ntrials))
  u <- array(0,c(ntrials,4))
  Ev <- array(0,c(ntrials,4))
  Ev_update <- array(0,c(ntrials,4))
  exp_p <- array(0,c(ntrials,4))
  p <- array(0,c(ntrials,4))
  
  # free parameters - turn back on when constructing
  #w <- 2
  #A <- .5
  #theta <- 3
  #a <- .1
  #--- plot prospect theory function
  #x <- seq(1,100,1)
  #y <- x^A
  #plot(x,y)
  
  x[1] <- rcat(1,c(.25,.25,.25,.25)) # assigning a "flat" probability structure to the first choice (i.e. random choice between the four decks)
  
  X[1] <- payoff[1, x[1]] # assigning the payoff to first random choice
  
  Ev[1,] <- rep(0,4) # assigning zero as the expected value for all four decks at the first "random" choice 
  
  for (t in 2:ntrials) {
    
    for (d in 1:4) {
      
      u[t,d] <- ifelse(X[t-1]<0,-w*abs(X[t-1])^A,X[t-1]^A)
      
      Ev_update[t,d] <- Ev[t-1,d] + (a * (u[t] - Ev[t-1,d]))
      
      Ev[t,d] <- ifelse(x[t-1]==d,Ev_update[t,d],Ev[t-1,d])
      
      exp_p[t,d] <- exp(theta*Ev[t,d])
      
    }
    
    for (d in 1:4) {
      p[t,d] <- exp_p[t,d]/sum(exp_p[t,])
    }
    
    x[t] <- rcat(1,p[t,])
    
    X[t] <- payoff[t,x[t]]
    
  }
  
  result <- list(x=x,
                 X=X,
                 Ev=Ev)
  
  return(result)
  
  
  #turn back on when building
  #par(mfrow=c(2,2))
  #plot(Ev[,1])
  #plot(Ev[,2])
  #plot(Ev[,3])
  #plot(Ev[,4])
  #plot(x)
  
}
