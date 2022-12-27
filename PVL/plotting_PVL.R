install.packages('pacman')
library('pacman')
pacman::p_load(tidyverse, ggpubr, ggpmisc)

getwd()
setwd("/work/exam/dm_exam/PVL/PVL_recovery")

# read infer og true values - arrays (list? )
infer_A <- readRDS("jags_output_100t_100i/infer_A_risk.rds")
infer_a <- readRDS("jags_output_100t_100i/infer_alpha.rds")
infer_w <- readRDS("jags_output_100t_100i/infer_w.rds")
infer_theta <- readRDS("jags_output_100t_100i/infer_theta.rds")

true_A <- readRDS("jags_output_100t_100i/true_A_risk.rds")
true_a <- readRDS("jags_output_100t_100i/true_alpha.rds")
true_w <- readRDS("jags_output_100t_100i/true_w.rds")
true_theta <- readRDS("jags_output_100t_100i/true_theta.rds")
 
# plot
source('recov_plot.R')
pl1 <- recov_plot(true_w, infer_w, c("true w", "infer w"), 'smoothed linear fit')
pl2 <- recov_plot(true_A, infer_A, c("true A", "infer A"), 'smoothed linear fit')
pl3 <- recov_plot(true_a, infer_a, c("true a", "infer a"), 'smoothed linear fit')
pl4 <- recov_plot(true_theta, infer_theta, c("true theta", "infer theta"), 'smoothed linear fit')
ggarrange(pl1, pl2, pl3, pl4)

#+ coord_cartesian(xlim = c(0,7), ylim = c(0,11))

#ggsave("plots_all_params_R_sq/PVL_rec_100t_100i_all_params.png", width = 2000, height = 1150, units = 'px', dpi = 150)

