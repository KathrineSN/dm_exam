# install.packages('pacman')
# library('pacman')
# pacman::p_load(tidyverse, ggpubr, ggpmisc)
# 
# getwd()
#setwd("/work/exam/dm_exam/data_preprocessing/hier_ORL")

# read infer og true values

true_mu_a_rew <- readRDS("jags_output_95t_247s_50i/true_mu_a_rew.rds")
true_mu_a_pun <- readRDS("jags_output_95t_247s_50i/true_mu_a_pun.rds")
true_mu_K <- readRDS("jags_output_95t_247s_50i/true_mu_K.rds")
true_mu_theta <- readRDS("jags_output_95t_247s_50i/true_mu_theta.rds")
true_mu_omega_f <- readRDS("jags_output_95t_247s_50i/true_mu_omega_f.rds")
true_mu_omega_p <- readRDS("jags_output_95t_247s_50i/true_mu_omega_p.rds")
#infer mu
infer_mu_a_rew <- readRDS("jags_output_95t_247s_50i/infer_mu_a_rew.rds")
infer_mu_a_pun <- readRDS("jags_output_95t_247s_50i/infer_mu_a_pun.rds")
infer_mu_K <- readRDS("jags_output_95t_247s_50i/infer_mu_K.rds")
infer_mu_theta <- readRDS("jags_output_95t_247s_50i/infer_mu_theta.rds")
infer_mu_omega_f <- readRDS("jags_output_95t_247s_50i/infer_mu_omega_f.rds")
infer_mu_omega_p <- readRDS("jags_output_95t_247s_50i/infer_mu_omega_p.rds")
#true lambda
true_lambda_a_rew <- readRDS("jags_output_95t_247s_50i/true_lambda_a_rew.rds")
true_lambda_a_pun <- readRDS("jags_output_95t_247s_50i/true_lambda_a_pun.rds")
true_lambda_K <- readRDS("jags_output_95t_247s_50i/true_lambda_K.rds")
true_lambda_theta <- readRDS("jags_output_95t_247s_50i/true_lambda_theta.rds")
true_lambda_omega_f <- readRDS("jags_output_95t_247s_50i/true_lambda_omega_f.rds")
true_lambda_omega_p <- readRDS("jags_output_95t_247s_50i/true_lambda_omega_p.rds")
#infer lambda
infer_lambda_a_rew <- readRDS("jags_output_95t_247s_50i/infer_lambda_a_rew.rds")
infer_lambda_a_pun <- readRDS("jags_output_95t_247s_50i/infer_lambda_a_pun.rds")
infer_lambda_K <- readRDS("jags_output_95t_247s_50i/infer_lambda_K.rds")
infer_lambda_theta <- readRDS("jags_output_95t_247s_50i/infer_lambda_theta.rds")
infer_lambda_omega_f <- readRDS("jags_output_95t_247s_50i/infer_lambda_omega_f.rds")
infer_lambda_omega_p <- readRDS("jags_output_95t_247s_50i/infer_lambda_omega_p.rds")

# plot
source('../../PVL/PVL_recovery/recov_plot.R')
pl1 <- recov_plot(true_mu_a_rew, infer_mu_a_rew, c("true mu_a_rew", "infer mu_a_rew"), 'smoothed linear fit')
pl1 <- pl1 + font("title", size=10) + font("ylab", size = 8) + font("xlab", size = 8) 
pl2 <- recov_plot(true_mu_a_pun, infer_mu_a_pun, c("true mu_a_pun", "infer mu_a_pun"), 'smoothed linear fit')
pl2 <- pl2 + font("title", size=10) + font("ylab", size = 8) + font("xlab", size = 8) 
pl3 <- recov_plot(true_mu_K, infer_mu_K, c("true mu_K", "infer mu_K"), 'smoothed linear fit')
pl3 <- pl3 + font("title", size=10) + font("ylab", size = 8) + font("xlab", size = 8) 
pl4 <- recov_plot(true_mu_theta, infer_mu_theta, c("true mu_theta", "infer mu_theta"), 'smoothed linear fit')
pl4 <- pl4 + font("title", size=10) + font("ylab", size = 8) + font("xlab", size = 8) 
pl5 <- recov_plot(true_mu_omega_f, infer_mu_omega_f, c("true mu_omega_f", "infer mu_omega_f"), 'smoothed linear fit')
pl5 <- pl5 + font("title", size=10) + font("ylab", size = 8) + font("xlab", size = 8) 
pl6 <- recov_plot(true_mu_omega_p, infer_mu_omega_p, c("true mu_omega_p", "infer mu_omega_p"), 'smoothed linear fit')
pl6 <- pl6 + font("title", size=10) + font("ylab", size = 8) + font("xlab", size = 8) 
ggarrange(pl1, pl2, pl3, pl4, pl5, pl6)
ggsave("plots_all_params_R_sq/jags_output_95t_247s_50i/hier_ORL_rec_95t_247s_50i_mu.png", width = 2000, height = 1150, units = 'px', dpi = 150) ##### CHANGE HERE

font("title", size = 14, color = "red", face = "bold.italic")+

# sigma (aka. true_lambda) re-coded as precision
pl1 <- recov_plot(1/(true_lambda_a_rew^2),infer_lambda_a_rew, c("true lambda_a_rew", "infer lambda_a_rew"), 'smoothed linear fit')
pl1 <- pl1 + font("title", size=10) + font("ylab", size = 8) + font("xlab", size = 8) 
pl2 <- recov_plot(1/(true_lambda_a_pun^2), infer_lambda_a_pun, c("true lambda_a_pun", "infer lambda_a_pun"), 'smoothed linear fit')
pl2 <- pl2 + font("title", size=10) + font("ylab", size = 8) + font("xlab", size = 8) 
pl3 <- recov_plot(1/(true_lambda_K^2), infer_lambda_K, c("true lambda_K", "infer lambda_K"), 'smoothed linear fit')
pl3 <- pl3 + font("title", size=10) + font("ylab", size = 8) + font("xlab", size = 8) 
pl4 <- recov_plot(1/(true_lambda_theta^2), infer_lambda_theta, c("true lambda_theta", "infer lambda_theta"), 'smoothed linear fit')
pl4 <- pl4 + font("title", size=10) + font("ylab", size = 8) + font("xlab", size = 8) 
pl5 <- recov_plot(1/(true_lambda_omega_f^2), infer_lambda_omega_f, c("true lambda_omega_f", "infer lambda_omega_f"), 'smoothed linear fit')
pl5 <- pl5 + font("title", size=10) + font("ylab", size = 8) + font("xlab", size = 8) 
pl6 <- recov_plot(1/(true_lambda_omega_p^2), infer_lambda_omega_p, c("true lambda_omega_p", "infer lambda_omega_p"), 'smoothed linear fit')
pl6 <- pl6 + font("title", size=10) + font("ylab", size = 8) + font("xlab", size = 8) 
ggarrange(pl1, pl2, pl3, pl4, pl5, pl6)
ggsave("plots_all_params_R_sq/jags_output_95t_247s_50i/hier_ORL_rec_95t_247s_50i_lambda.png", width = 2000, height = 1150, units = 'px', dpi = 150) ##### CHANGE HERE

# recoded as SD 
pl1 <- recov_plot(true_lambda_a_rew, 1/sqrt(infer_lambda_a_rew), c("true lambda_a_rew", "infer lambda_a_rew"), 'smoothed linear fit')
pl1 <- pl1 + font("title", size=10) + font("ylab", size = 8) + font("xlab", size = 8) 
pl2 <- recov_plot(true_lambda_a_pun, 1/sqrt(infer_lambda_a_pun), c("true lambda_a_pun", "infer lambda_a_pun"), 'smoothed linear fit')
pl2 <- pl2 + font("title", size=10) + font("ylab", size = 8) + font("xlab", size = 8) 
pl3 <- recov_plot(true_lambda_K, 1/sqrt(infer_lambda_K), c("true lambda_K", "infer lambda_K"), 'smoothed linear fit')
pl3 <- pl3 + font("title", size=10) + font("ylab", size = 8) + font("xlab", size = 8) 
pl4 <- recov_plot(true_lambda_theta, 1/sqrt(infer_lambda_theta), c("true lambda_theta", "infer lambda_theta"), 'smoothed linear fit')
pl4 <- pl4 + font("title", size=10) + font("ylab", size = 8) + font("xlab", size = 8) 
pl5 <- recov_plot(true_lambda_omega_f, 1/sqrt(infer_lambda_omega_f), c("true lambda_omega_f", "infer lambda_omega_f"), 'smoothed linear fit')
pl5 <- pl5 + font("title", size=10) + font("ylab", size = 8) + font("xlab", size = 8) 
pl6 <- recov_plot(true_lambda_omega_p, 1/sqrt(infer_lambda_omega_p), c("true lambda_omega_p", "infer lambda_omega_p"), 'smoothed linear fit')
pl6 <- pl6 + font("title", size=10) + font("ylab", size = 8) + font("xlab", size = 8) 
ggarrange(pl1, pl2, pl3, pl4, pl5, pl6)
ggsave("plots_all_params_R_sq/jags_output_95t_247s_50i/hier_ORL_rec_95t_247s_50i_lambda_sd.png", width = 2000, height = 1150, units = 'px', dpi = 150) ##### CHANGE HERE

