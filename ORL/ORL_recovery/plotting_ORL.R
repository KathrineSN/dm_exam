# install.packages('pacman')
# library('pacman')
# pacman::p_load(tidyverse, ggpubr, ggpmisc)
# 
# getwd()
# setwd("/work/exam/dm_exam/ORL/ORL_recovery")

# read infer og true values
infer_a_rew <- readRDS("jags_output_100t_100i_no_theta/infer_a_rew.rds")
infer_a_pun <- readRDS("jags_output_100t_100i_no_theta/infer_a_pun.rds")
infer_K <- readRDS("jags_output_100t_100i_no_theta/infer_K.rds")
infer_omega_f <- readRDS("jags_output_100t_100i_no_theta/infer_omega_f.rds")
infer_omega_p <- readRDS("jags_output_100t_100i_no_theta/infer_omega_p.rds")
infer_theta <- readRDS("jags_output_100t_100i_no_theta/infer_theta.rds")

true_a_rew <- readRDS("jags_output_100t_100i_no_theta/true_a_rew.rds")
true_a_pun <- readRDS("jags_output_100t_100i_no_theta/true_a_pun.rds")
true_K <- readRDS("jags_output_100t_100i_no_theta/true_K.rds")
true_omega_f <- readRDS("jags_output_100t_100i_no_theta/true_omega_f.rds")
true_omega_p <- readRDS("jags_output_100t_100i_no_theta/true_omega_p.rds")
true_theta <- readRDS("jags_output_100t_100i_no_theta/true_theta.rds")

# plot
source('../../PVL/PVL_recovery/recov_plot.R')
pl1 <- recov_plot(true_a_rew, infer_a_rew, c("true a_rew", "infer a_rew"), 'smoothed linear fit')
pl2 <- recov_plot(true_a_pun, infer_a_pun, c("true a_pun", "infer a_pun"), 'smoothed linear fit')
pl3 <- recov_plot(true_K, infer_K, c("true K", "infer K"), 'smoothed linear fit')
#pl4 <- recov_plot(true_theta, infer_theta, c("true theta", "infer theta"), 'smoothed linear fit')
pl5 <- recov_plot(true_omega_f, infer_omega_f, c("true omega_f", "infer omega_f"), 'smoothed linear fit')
pl6 <- recov_plot(true_omega_p, infer_omega_p, c("true omega_p", "infer omega_p"), 'smoothed linear fit')
#ggarrange(pl1, pl2, pl3, pl4, pl5, pl6)
ggarrange(pl1, pl2, pl3, pl5,pl6)
#ggsave("plots_all_params_R_sq/ORL_rec_100t_100i_no_theta_all_params.png", width = 2000, height = 1150, units = 'px', dpi = 150)




